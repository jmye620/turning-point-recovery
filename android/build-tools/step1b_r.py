#!/usr/bin/env python3
"""Step 1b: generate R.java for app + every AAR package from the final table."""
import os, re, shutil, glob, xml.etree.ElementTree as ET
from collections import defaultdict

WORK = "/tmp/build/work"
AARS = "/tmp/build/aars"
GEN = f"{WORK}/gen_all"
shutil.rmtree(GEN, ignore_errors=True)

# final table: (type, name) -> id or [ids]
final = {}
with open(f"{WORK}/symbols.txt") as f:
    for line in f:
        line = line.strip()
        m = re.match(r"^int\[\] styleable (\S+) \{ ([^}]*) \}$", line)
        if m:
            ids = [x.strip() for x in m.group(2).split(",")]
            final[("styleable", m.group(1))] = ids
            continue
        m = re.match(r"^int styleable (\S+)_(\S+) (\d+)$", line)
        if m:
            final[("styleable", f"{m.group(1)}_{m.group(2)}")] = m.group(3)
            continue
        m = re.match(r"^int (\S+) (\S+) (0x[0-9a-fA-F]+)$", line)
        if m:
            final[(m.group(1), m.group(2))] = m.group(3)

print(f"final table: {len(final)} symbols")

def pkg_of(aar_dir):
    mfile = os.path.join(aar_dir, "AndroidManifest.xml")
    try:
        root = ET.parse(mfile).getroot()
        return root.get("package")
    except Exception:
        return None

def parse_rtxt(path):
    syms = defaultdict(dict)
    with open(path) as f:
        for line in f:
            line = line.strip()
            m = re.match(r"^int\[\] styleable (\S+) \{ ([^}]*) \}$", line)
            if m:
                syms["styleable"][m.group(1)] = ("array", None)
                continue
            m = re.match(r"^int styleable (\S+) (\S+)$", line)
            if m:
                # R.txt: "int styleable Foo_bar 3" -> field Foo_bar = index 3
                syms["styleable"][m.group(1)] = ("index", None)
                continue
            m = re.match(r"^int (\S+) (\S+) \S+$", line)
            if m:
                syms[m.group(1)][m.group(2)] = ("id", None)
    return syms

def lookup(rtype, name, pkg):
    """Map an AAR's (type, name) to the final ID, following aapt2 renames."""
    if (rtype, name) in final:
        return final[(rtype, name)]
    # aapt2 renames collided resources as <pkg>_<name>; the resource was deduped
    own = pkg.replace(".", "_") + "_" + name
    if (rtype, own) in final:
        return final[(rtype, own)]
    suffix = "_" + name
    for (t, n), v in final.items():
        if t == rtype and n.endswith(suffix):
            return v
    return None

missing = defaultdict(list)
count = 0
# app package first (from its own symbols: everything in final table)
targets = [("com.turningpoint.recoveryapp", None)]
for d in sorted(glob.glob(f"{AARS}/*")):
    if os.path.isdir(d) and os.path.exists(os.path.join(d, "R.txt")):
        pkg = pkg_of(d)
        if pkg:
            targets.append((pkg, os.path.join(d, "R.txt")))

for pkg, rtxt in targets:
    if rtxt:
        syms = parse_rtxt(rtxt)
    else:
        # app: use every final symbol
        syms = defaultdict(dict)
        for (t, n) in final:
            syms[t][n] = ("x", None)
    d = os.path.join(GEN, *pkg.split("."))
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "R.java"), "w") as f:
        f.write(f"package {pkg};\n\npublic final class R {{\n")
        for rtype in sorted(syms):
            f.write(f"    public static final class {rtype} {{\n")
            for name in sorted(syms[rtype]):
                val = lookup(rtype, name, pkg)
                if val is None:
                    missing[pkg].append(f"{rtype}/{name}")
                    continue
                if isinstance(val, list):
                    f.write(f"        public static int[] {name} = {{{', '.join(val)}}};\n")
                elif rtype == "styleable" and not val.startswith("0x"):
                    f.write(f"        public static final int {name} = {val};\n")
                else:
                    f.write(f"        public static final int {name} = {val};\n")
            f.write("    }\n")
        f.write("}\n")
    count += 1

print(f"wrote {count} R.java files")
if missing:
    print("MISSING symbols (not in final table):")
    for pkg, names in missing.items():
        print(f"  {pkg}: {len(names)} e.g. {names[:3]}")
with open(f"{WORK}/gen_all_files.txt", "w") as f:
    for root, _, files in os.walk(GEN):
        for fn in files:
            if fn.endswith(".java"):
                f.write(os.path.join(root, fn) + "\n")
