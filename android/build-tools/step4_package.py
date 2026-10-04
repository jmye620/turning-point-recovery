#!/usr/bin/env python3
"""Step 4: add dex to APK, zipalign, sign with a debug key."""
import os, subprocess, sys, zipfile, shutil

SDK = os.path.expanduser("~/android-sdk")
BT = f"{SDK}/build-tools/34.0.0"
WORK = "/tmp/build/work"
OUT = os.path.expanduser("~/workspace/recovery-app")

def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("FAILED:", " ".join(cmd))
        print(r.stderr[-2000:], r.stdout[-2000:])
        sys.exit(1)

# 1. add dex files into a FRESH apk built from the aapt2-linked apk
#    (strip any previous dex entries so rebuilds are idempotent;
#     delete stale intermediates first so we never append into an old zip)
apk = f"{WORK}/app-unaligned.apk"
tmp_apk = f"{WORK}/app-dex.apk"
aligned = f"{WORK}/app-aligned.apk"
for stale in (tmp_apk, aligned):
    if os.path.exists(stale):
        os.remove(stale)
seen = set()
with zipfile.ZipFile(apk, "r") as zin, \
     zipfile.ZipFile(tmp_apk, "w", zipfile.ZIP_DEFLATED) as zout:
    for item in zin.infolist():
        if item.filename in ("classes.dex", "classes2.dex", "classes3.dex"):
            continue
        if item.filename in seen:
            print(f"WARNING: duplicate entry in base apk skipped: {item.filename}")
            continue
        seen.add(item.filename)
        zout.writestr(item, zin.read(item.filename))
    for dex in ("classes.dex", "classes2.dex"):
        dex_path = f"{WORK}/dex/{dex}"
        if not os.path.exists(dex_path):
            print(f"ERROR: missing {dex_path}")
            sys.exit(1)
        if dex in seen:
            print(f"ERROR: duplicate dex entry would be created: {dex}")
            sys.exit(1)
        zout.write(dex_path, dex)
        seen.add(dex)
# sanity: no duplicate names in the fresh apk
with zipfile.ZipFile(tmp_apk, "r") as z:
    names = z.namelist()
    assert len(names) == len(set(names)), "duplicate ZIP entries in fresh apk!"
print(f"dex added ({len(names)} entries, no duplicates)")

# 2. zipalign (to a separate file, never in place)
run([f"{BT}/zipalign", "-f", "4", tmp_apk, aligned])
run([f"{BT}/zipalign", "-c", "-p", "4", aligned])
print("zipalign OK")

# 3. debug keystore (PERSISTENT: kept in the repo so updates keep the same
# signature; losing it forces users to uninstall and wipes their local data)
ks = os.path.expanduser("~/workspace/recovery-app/debug.keystore")
if not os.path.exists(ks):
    run(["keytool", "-genkeypair", "-keystore", ks, "-storepass", "android",
         "-keypass", "android", "-alias", "androiddebugkey",
         "-keyalg", "RSA", "-keysize", "2048", "-validity", "10950",
         "-dname", "CN=Android Debug,O=Android,C=US"])
    print("keystore created")

# 4. sign to a temp file, then move to final path (never sign in place)
signed = f"{OUT}/turning-point-recovery-debug.apk"
signed_tmp = f"{WORK}/app-signed.apk"
if os.path.exists(signed_tmp):
    os.remove(signed_tmp)
run([f"{BT}/apksigner", "sign", "--ks", ks, "--ks-pass", "pass:android",
     "--key-pass", "pass:android", "--out", signed_tmp, aligned])
shutil.move(signed_tmp, signed)
print("signed")

# 5. verify
run([f"{BT}/apksigner", "verify", "--print-certs", signed])
print("verify OK")
size = os.path.getsize(signed)
print(f"APK: {signed} ({size//1024//1024} MB)")
