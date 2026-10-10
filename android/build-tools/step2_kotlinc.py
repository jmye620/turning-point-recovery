#!/usr/bin/env python3
"""Step 2: compile app Kotlin + R.java with kotlinc + compose plugin."""
import os, subprocess, sys, glob, re

SDK = os.path.expanduser("~/android-sdk")
TARGET_SDK = os.environ.get("TARGET_SDK", "34")
ANDROID_JAR = f"{SDK}/platforms/android-{TARGET_SDK}/android.jar"
SRC = os.path.expanduser("~/workspace/recovery-app/app/src/main/java")
WORK = "/tmp/build/work"
AARS = "/tmp/build/aars"
LIBS = "/tmp/deps/libs"
KOTLINC_EMBEDDABLE = f"{LIBS}/kotlin-compiler-embeddable-2.0.21.jar"
KOTLINC_LIB = "/home/hatch/kotlin/kotlinc/lib"
# compiler JVM classpath: embeddable compiler + its runtime needs
COMPILER_CP = ":".join([
    KOTLINC_EMBEDDABLE,
    f"{KOTLINC_LIB}/kotlin-stdlib.jar",
    f"{KOTLINC_LIB}/kotlin-reflect.jar",
    f"{KOTLINC_LIB}/kotlin-script-runtime.jar",
    f"{KOTLINC_LIB}/trove4j.jar",
    f"{LIBS}/kotlinx-coroutines-core-jvm-1.8.1.jar",
    f"{LIBS}/annotations-23.0.0.jar",
])
PLUGIN = f"{LIBS}/kotlin-compose-compiler-plugin-embeddable-2.0.21.jar"
# jars that live in LIBS but must NOT go on the app compile classpath
EXCLUDE_LIBS = {os.path.basename(PLUGIN), "kotlin-compiler-embeddable-2.0.21.jar"}

cp = [ANDROID_JAR]
for d in sorted(glob.glob(f"{AARS}/*/classes.jar")):
    cp.append(d)

def artifact_key(path):
    # group jars by artifact name, keep highest version
    base = os.path.basename(path)
    m = re.match(r"^(.+?)-(\d[\d.\-]*)\.jar$", base)
    if m:
        return m.group(1), m.group(2)
    return base, "0"

def version_key(v):
    parts = re.split(r"[.\-]", v)
    return [(0, int(p)) if p.isdigit() else (1, p) for p in parts]

best = {}
for j in sorted(glob.glob(f"{LIBS}/*.jar")):
    if os.path.basename(j) in EXCLUDE_LIBS:
        continue
    name, ver = artifact_key(j)
    if name not in best or version_key(ver) > version_key(best[name][1]):
        best[name] = (j, ver)
for j, _ in sorted(best.values()):
    cp.append(j)

sources = []
for root, _, files in os.walk(SRC):
    for fn in files:
        if fn.endswith(".kt"):
            sources.append(os.path.join(root, fn))
with open(f"{WORK}/gen_all_files.txt") as f:
    r_files = [l.strip() for l in f if l.strip()]
sources += r_files
print(f"sources: {len(sources)} ({len(r_files)} R.java)")

out = f"{WORK}/classes"
os.makedirs(out, exist_ok=True)

cmd = ["java", "-Xmx700m",
       "-cp", COMPILER_CP,
       "org.jetbrains.kotlin.cli.jvm.K2JVMCompiler",
       "-jvm-target", "17",
       "-Xplugin=" + PLUGIN,
       "-cp", ":".join(cp),
       "-d", out] + sources
print("kotlinc args:", len(cmd), "classpath entries:", len(cp))

env = dict(os.environ)
r = subprocess.run(cmd, capture_output=True, text=True, env=env)
print(r.stdout[-2000:] if r.stdout else "")
if r.returncode != 0:
    print("KOTLINC FAILED")
    print(r.stderr[-6000:])
    sys.exit(1)
print("kotlinc OK")
n = sum(1 for _, _, fs in os.walk(out) for x in fs if x.endswith(".class"))
print(f"compiled {n} classes")
