#!/usr/bin/env python3
"""Step 1: merge manifest, compile + link resources with aapt2."""
import os, re, shutil, subprocess, sys, glob

APP_ID = "com.turningpoint.recoveryapp"
SDK = os.path.expanduser("~/android-sdk")
TARGET_SDK = os.environ.get("TARGET_SDK", "34")
AAPT2 = f"{SDK}/build-tools/34.0.0/aapt2"
ANDROID_JAR = f"{SDK}/platforms/android-{TARGET_SDK}/android.jar"
SRC = os.path.expanduser("~/workspace/recovery-app/app/src/main")
WORK = "/tmp/build/work"
AARS = "/tmp/build/aars"
# When BUNDLE_PROTO=1, link resources in protobuf format into a bundle module
# zip (for bundletool) instead of an APK.
BUNDLE_PROTO = os.environ.get("BUNDLE_PROTO") == "1"

shutil.rmtree(WORK, ignore_errors=True)
os.makedirs(f"{WORK}/compiled", exist_ok=True)
os.makedirs(f"{WORK}/gen", exist_ok=True)

# ---- 1. merged manifest ----
with open(f"{SRC}/AndroidManifest.xml") as f:
    manifest = f.read()
manifest = manifest.replace("${applicationId}", APP_ID)
if 'package="' not in manifest.split("<application")[0]:
    manifest = manifest.replace("<manifest ", f'<manifest package="{APP_ID}" ', 1)

merged_components = """
        <provider
            android:name="androidx.startup.InitializationProvider"
            android:authorities="__APPID__.androidx-startup"
            android:exported="false">
            <meta-data
                android:name="androidx.emoji2.text.EmojiCompatInitializer"
                android:value="androidx.startup" />
            <meta-data
                android:name="androidx.lifecycle.ProcessLifecycleInitializer"
                android:value="androidx.startup" />
            <meta-data
                android:name="androidx.profileinstaller.ProfileInstallerInitializer"
                android:value="androidx.startup" />
        </provider>
        <receiver
            android:name="androidx.profileinstaller.ProfileInstallReceiver"
            android:enabled="true"
            android:exported="true"
            android:permission="android.permission.DUMP">
            <intent-filter>
                <action android:name="androidx.profileinstaller.action.INSTALL_PROFILE" />
            </intent-filter>
            <intent-filter>
                <action android:name="androidx.profileinstaller.action.SKIP_FILE" />
            </intent-filter>
            <intent-filter>
                <action android:name="androidx.profileinstaller.action.SAVE_PROFILE" />
            </intent-filter>
            <intent-filter>
                <action android:name="androidx.profileinstaller.action.BENCHMARK_OPERATION" />
            </intent-filter>
        </receiver>
""".replace("__APPID__", APP_ID)

# insert uses-permission after <manifest ...> line and components before </application>
manifest = re.sub(r"(<manifest[^>]*>)",
                  r'\1\n    <uses-permission android:name="%s.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION" />' % APP_ID,
                  manifest, count=1)
manifest = manifest.replace("</application>", merged_components + "    </application>")

with open(f"{WORK}/AndroidManifest.xml", "w") as f:
    f.write(manifest)
print("manifest written")

def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("FAILED:", " ".join(cmd))
        print(r.stderr[-3000:])
        sys.exit(1)
    return r

# ---- 2. aapt2 compile ----
res_dirs = []
app_res = f"{SRC}/res"
if os.path.isdir(app_res):
    res_dirs.append(("app", app_res))
for d in sorted(glob.glob(f"{AARS}/*/res")):
    # skip empty res dirs
    if any(os.scandir(d)):
        res_dirs.append((d.split("/")[-2], d))
print(f"compiling {len(res_dirs)} res dirs")
compiled = []
for name, rd in res_dirs:
    out = f"{WORK}/compiled/{name}.zip"
    run([AAPT2, "compile", "--dir", rd, "-o", out])
    compiled.append(out)
print("aapt2 compile OK")

# ---- 3. aapt2 link ----
link_out = f"{WORK}/base-module.zip" if BUNDLE_PROTO else f"{WORK}/app-unaligned.apk"
assets = [d for d in glob.glob(f"{AARS}/*/assets") if any(os.scandir(d))]
cmd = [AAPT2, "link", "-o", link_out,
       "-I", ANDROID_JAR,
       "--manifest", f"{WORK}/AndroidManifest.xml",
       "--java", f"{WORK}/gen",
       "--output-text-symbols", f"{WORK}/symbols.txt",
       "--min-sdk-version", "26",
       "--target-sdk-version", TARGET_SDK,
       "--version-code", "10",
       "--version-name", "1.1.8"]
if BUNDLE_PROTO:
    cmd.append("--proto-format")
for a in assets:
    cmd += ["-A", a]
cmd += compiled
run(cmd)
print("aapt2 link OK")
gen_files = []
for root, _, files in os.walk(f"{WORK}/gen"):
    for fn in files:
        gen_files.append(os.path.join(root, fn))
print(f"generated {len(gen_files)} R sources:")
pkgs = sorted(set(os.path.relpath(p, f"{WORK}/gen").replace("/", ".")[:-len("/R.java")]
                  for p in gen_files if p.endswith("R.java")))
for p in pkgs[:8]:
    print("  ", p)
if len(pkgs) > 8:
    print(f"  ... and {len(pkgs) - 8} more")
with open(f"{WORK}/gen_files.txt", "w") as f:
    f.write("\n".join(gen_files))
