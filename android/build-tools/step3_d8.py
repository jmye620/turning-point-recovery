#!/usr/bin/env python3
"""Step 3: dex app classes + all library bytecode with d8."""
import os, subprocess, sys, glob, re

SDK = os.path.expanduser("~/android-sdk")
D8 = f"{SDK}/build-tools/34.0.0/d8"
ANDROID_JAR = f"{SDK}/platforms/android-34/android.jar"
WORK = "/tmp/build/work"
AARS = "/tmp/build/aars"
LIBS = "/tmp/deps/libs"

# exclude compiler-only jars and superseded stdlibs from dex input
EXCLUDE = {
    "kotlin-compiler-embeddable-2.0.21.jar",
    "kotlin-compose-compiler-plugin-embeddable-2.0.21.jar",
    "kotlin-stdlib-1.8.22.jar", "kotlin-stdlib-common-1.8.22.jar",
    "kotlin-stdlib-jdk7-1.8.20.jar", "kotlin-stdlib-jdk8-1.8.20.jar",
    # duplicate classes: keep the dependency-resolved versions
    "kotlinx-coroutines-core-jvm-1.8.1.jar",  # keep 1.7.1 (resolved dep)
    "collection-ktx-1.2.0.jar",               # keep collection-jvm-1.4.0
}

# AAR dirs to skip (D8 crashes on these; nothing references them)
EXCLUDE_AARS = {
    "androidx.lifecycle.lifecycle-livedata-core",  # D8 NPE; app uses Compose, not LiveData
    "androidx.lifecycle.lifecycle-viewmodel-ktx",  # dup ViewModelKt; superseded by viewmodel-android
}

inputs = []
# d8 does not accept a raw classes dir -> jar it up.
# Merge kotlinc output (classes/) and javac-compiled R classes (r-classes/)
# into a single app jar so library R classes (e.g. poolingcontainer R$id)
# referenced by Compose/Activity static initializers are present at runtime.
app_jar = f"{WORK}/app-classes.jar"
import zipfile as _zf
with _zf.ZipFile(app_jar, "w", _zf.ZIP_DEFLATED) as z:
    for srcdir in (f"{WORK}/classes", f"{WORK}/r-classes"):
        if not os.path.isdir(srcdir):
            continue
        for root, _, files in os.walk(srcdir):
            for fn in files:
                p = os.path.join(root, fn)
                arc = os.path.relpath(p, srcdir)
                # last writer wins; both dirs should be disjoint
                z.write(p, arc)
n_app = sum(1 for _ in _zf.ZipFile(app_jar).infolist())
print(f"app jar: {n_app} entries")
inputs.append(app_jar)
for d in sorted(glob.glob(f"{AARS}/*/classes.jar")):
    # skip excluded AARs (e.g. livedata-core crashes D8)
    aar_dir = os.path.basename(os.path.dirname(d))
    if aar_dir in EXCLUDE_AARS:
        continue
    inputs.append(d)

def _artifact_key(path):
    base = os.path.basename(path)
    m = re.match(r"^(.+?)-(\d[\d.\-]*)\.jar$", base)
    if m:
        return m.group(1), m.group(2)
    return base, "0"

def _version_key(v):
    parts = re.split(r"[.\-]", v)
    return [(0, int(p)) if p.isdigit() else (1, p) for p in parts]

_best = {}
for j in sorted(glob.glob(f"{LIBS}/*.jar")):
    if os.path.basename(j) in EXCLUDE:
        continue
    _name, _ver = _artifact_key(j)
    if _name not in _best or _version_key(_ver) > _version_key(_best[_name][1]):
        _best[_name] = (j, _ver)
for j, _ in sorted(_best.values()):
    inputs.append(j)
print(f"dex inputs: {len(inputs)}")

out = f"{WORK}/dex"
os.makedirs(out, exist_ok=True)
cmd = ["java", "-Xmx700m", "-cp", f"{SDK}/build-tools/34.0.0/lib/d8.jar",
       "com.android.tools.r8.D8",
       "--lib", ANDROID_JAR,
       "--min-api", "26",
       "--release",
       "--output", out] + inputs
r = subprocess.run(cmd, capture_output=True, text=True)
if r.returncode != 0:
    print("D8 FAILED")
    print(r.stderr[-5000:])
    print(r.stdout[-2000:])
    sys.exit(1)
print("d8 OK")
for f in sorted(os.listdir(out)):
    p = os.path.join(out, f)
    print(f"  {f} {os.path.getsize(p)//1024} KB")
