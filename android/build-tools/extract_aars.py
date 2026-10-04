#!/usr/bin/env python3
"""Extract the highest-version AAR per artifact dir (Gradle-style max-version
resolution). Produces res/, classes.jar, assets/, AndroidManifest.xml in each dir,
which step1_res.py and step2_kotlinc.py glob for."""
import os, re, zipfile, glob, shutil

AARS = "/tmp/build/aars"

def version_key(v):
    parts = re.split(r"[.\-]", v)
    return [(0, int(p)) if p.isdigit() else (1, p) for p in parts]

def ver_of(path):
    m = re.search(r"-(\d[\d.\-]*)\.aar$", os.path.basename(path))
    return m.group(1) if m else "0"

n = 0
for d in sorted(glob.glob(f"{AARS}/*")):
    if not os.path.isdir(d):
        continue
    # skip if already extracted (classes.jar present and newer than any aar)
    aars = glob.glob(f"{d}/*.aar")
    if not aars:
        continue
    best = max(aars, key=lambda p: version_key(ver_of(p)))
    cj = os.path.join(d, "classes.jar")
    if os.path.exists(cj) and os.path.getmtime(cj) >= os.path.getmtime(best):
        continue
    # clean previous extraction leftovers (res/assets/manifest from another version)
    for leftover in ("res", "assets", "classes.jar", "AndroidManifest.xml",
                     "R.txt", "public.txt", "lint.jar", "jni"):
        p = os.path.join(d, leftover)
        if os.path.isdir(p):
            shutil.rmtree(p)
        elif os.path.isfile(p):
            os.remove(p)
    with zipfile.ZipFile(best) as z:
        z.extractall(d)
    n += 1
    print("extracted", os.path.basename(d), os.path.basename(best))
print(f"done, extracted {n} AARs")
