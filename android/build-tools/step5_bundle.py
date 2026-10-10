#!/usr/bin/env python3
"""Step 5: build a release Android App Bundle (.aab) with bundletool.

Expects BUNDLE_PROTO=1 + TARGET_SDK=35 pipeline output:
  /tmp/build/work/base-module.zip  (proto resources + manifest from step1_res)
  /tmp/build/work/dex/*.dex        (from step3_d8)

Produces a release-signed AAB:
  ~/workspace/recovery-app/turning-point-recovery-1.1.9.aab
"""
import glob
import os
import shutil
import subprocess
import sys
import zipfile

APP_DIR = os.path.expanduser("~/workspace/recovery-app")
WORK = "/tmp/build/work"
JAVA = os.path.expanduser("~/jdk/bin/java")
JARSIGNER = os.path.expanduser("~/jdk/bin/jarsigner")
BUNDLETOOL = f"{APP_DIR}/build-tools/bundletool.jar"
KEYSTORE = f"{APP_DIR}/release.keystore"
PWFILE = f"{APP_DIR}/release-keystore.pw"
AAB = f"{APP_DIR}/turning-point-recovery-1.1.9.aab"


def run(cmd, **kw):
    r = subprocess.run(cmd, capture_output=True, text=True, **kw)
    if r.returncode != 0:
        print("FAILED:", " ".join(cmd))
        print((r.stderr or r.stdout or "")[-3000:])
        sys.exit(1)
    return r


module_src = f"{WORK}/base-module.zip"
module = f"{WORK}/base.zip"  # bundletool module layout
dexes = sorted(glob.glob(f"{WORK}/dex/*.dex"))
if not os.path.isfile(module_src):
    sys.exit("base-module.zip missing — run the pipeline with BUNDLE_PROTO=1")
if not dexes:
    sys.exit("no dex files — run step3_d8.py first")
if not os.path.isfile(KEYSTORE):
    sys.exit("release.keystore missing")
with open(PWFILE) as f:
    pw = f.read().strip()

# 1. restructure aapt2's proto output into bundletool's module layout:
#    manifest/AndroidManifest.xml, resources.pb, res/**, dex/*.dex
if os.path.exists(module):
    os.remove(module)
with zipfile.ZipFile(module_src) as zin, \
     zipfile.ZipFile(module, "w", zipfile.ZIP_DEFLATED) as zout:
    for info in zin.infolist():
        name = info.filename
        data = zin.read(name)
        if name == "AndroidManifest.xml":
            zout.writestr("manifest/AndroidManifest.xml", data)
        elif name == "resources.pb" or name.startswith("res/") or name.startswith("assets/"):
            zout.writestr(name, data)
        # ignore anything else (e.g.kotlin/META-INF from link)
    for dex in dexes:
        zout.write(dex, "dex/" + os.path.basename(dex))
        print(f"added dex/{os.path.basename(dex)}")
with zipfile.ZipFile(module) as z:
    names = z.namelist()
print("module entries:", len(names))
assert "manifest/AndroidManifest.xml" in names, "manifest missing from module"
assert "resources.pb" in names, "resources.pb missing — was --proto-format used?"
assert any(n.startswith("dex/") for n in names), "no dex in module"

# 2. build the bundle
if os.path.exists(AAB):
    os.remove(AAB)
run([JAVA, "-jar", BUNDLETOOL, "build-bundle",
     f"--modules={module}", f"--output={AAB}"])
print(f"bundle built: {AAB} ({os.path.getsize(AAB)} bytes)")

# 3. sign with the release key (jarsigner reads passphrases from stdin)
r = subprocess.run(
    [JARSIGNER, "-keystore", KEYSTORE, "-signedjar", AAB, AAB, "turningpoint"],
    input=f"{pw}\n{pw}\n", capture_output=True, text=True)
if r.returncode != 0:
    print("JARSIGNER FAILED")
    print((r.stderr or r.stdout or "")[-3000:])
    sys.exit(1)
print("signed with release key")

# 4. verify
r = run([JARSIGNER, "-verify", AAB])
print(r.stdout.strip().splitlines()[-1] if r.stdout.strip() else "verify done")
print(f"AAB: {AAB}")
