#!/usr/bin/env python3
"""Download AAR/JAR deps from Maven Central with transitive POM resolution."""
import os, re, sys, urllib.request, xml.etree.ElementTree as ET

MAVEN = "https://repo1.maven.org/maven2"
GOOGLE_MAVEN = "https://dl.google.com/dl/android/maven2"
AARS = "/tmp/build/aars"
LIBS = "/tmp/deps/libs"
os.makedirs(AARS, exist_ok=True)
os.makedirs(LIBS, exist_ok=True)

NS = {"m": "http://maven.apache.org/POM/4.0.0"}

# Root dependencies (group, artifact, version)
ROOTS = [
    ("androidx.activity", "activity-compose", "1.9.0"),
    ("androidx.compose.animation", "animation", "1.6.8"),
    ("androidx.compose.foundation", "foundation", "1.6.8"),
    ("androidx.compose.material", "material", "1.6.8"),
    ("androidx.compose.material", "material-icons-core", "1.6.8"),
    # NOTE: the KMP-published material-icons-extended ships only stub artifacts;
    # the real Android AAR is material-icons-extended-android.
    ("androidx.compose.material", "material-icons-extended-android", "1.6.8"),
    ("androidx.compose.material3", "material3", "1.2.1"),
    ("androidx.compose.runtime", "runtime", "1.6.8"),
    ("androidx.compose.ui", "ui", "1.6.8"),
    ("androidx.core", "core-ktx", "1.13.1"),
    ("androidx.lifecycle", "lifecycle-runtime-compose", "2.8.3"),
    ("androidx.lifecycle", "lifecycle-viewmodel-compose", "2.8.3"),
    ("org.jetbrains.kotlinx", "kotlinx-coroutines-android", "1.8.1"),
    ("org.jetbrains.kotlin", "kotlin-stdlib", "2.0.21"),
    # JAR-only artifact required at runtime by androidx.profileinstaller
    # (ProfileInstallerInitializer runs at startup via androidx.startup).
    # Missing it caused a startup crash: NoClassDefFoundError
    # androidx/concurrent/futures/AbstractResolvableFuture (2026-10-02).
    ("androidx.concurrent", "concurrent-futures", "1.1.0"),
]

SKIP_GROUPS = {"junit", "org.jetbrains.kotlin", "com.google.code.gson"}  # not needed
# kotlin-stdlib handled via kotlinc lib dir; skip re-download but keep for version alignment
seen = set()
queue = list(ROOTS)

def fetch(url, dest):
    if os.path.exists(dest) and os.path.getsize(dest) > 0:
        return True
    try:
        urllib.request.urlretrieve(url, dest)
        return True
    except Exception as e:
        print(f"  FAIL {url}: {e}")
        return False

def gav_path(g, a, v, ext):
    base = GOOGLE_MAVEN if (g.startswith("androidx.") or g.startswith("com.google.")) else MAVEN
    return f"{base}/{g.replace('.', '/')}/{a}/{v}/{a}-{v}.{ext}"

while queue:
    g, a, v = queue.pop(0)
    key = (g, a, v)
    if key in seen:
        continue
    seen.add(key)
    if g in SKIP_GROUPS:
        continue
    print(f"{g}:{a}:{v}")
    # Prefer AAR, fall back to JAR
    dest_dir = os.path.join(AARS, f"{g}.{a}")
    os.makedirs(dest_dir, exist_ok=True)
    aar_dest = os.path.join(dest_dir, f"{a}-{v}.aar")
    jar_dest = os.path.join(LIBS, f"{a}-{v}.jar")
    is_aar = fetch(gav_path(g, a, v, "aar"), aar_dest)
    if not is_aar:
        if os.path.exists(aar_dest):
            os.remove(aar_dest)
        if not fetch(gav_path(g, a, v, "jar"), jar_dest):
            print(f"  WARNING: neither aar nor jar for {g}:{a}:{v}")
            continue
    # Parse POM for transitive deps
    pom_dest = os.path.join(dest_dir, f"{a}-{v}.pom")
    if not fetch(gav_path(g, a, v, "pom"), pom_dest):
        continue
    try:
        tree = ET.parse(pom_dest)
        root = tree.getroot()
        props = {}
        for p in root.findall("m:properties", NS):
            for child in p:
                tag = child.tag.replace("{http://maven.apache.org/POM/4.0.0}", "")
                props[tag] = child.text
        # parent version for property resolution (simplified)
        for dep in root.findall("m:dependencies/m:dependency", NS):
            dg = dep.find("m:groupId", NS).text
            da = dep.find("m:artifactId", NS).text
            dv_el = dep.find("m:version", NS)
            scope_el = dep.find("m:scope", NS)
            scope = scope_el.text if scope_el is not None else "compile"
            if scope not in ("compile", "runtime"):
                continue
            if dv_el is None or not dv_el.text:
                continue
            dv = dv_el.text
            # resolve ${...} properties
            m = re.match(r"\$\{(.+)\}", dv)
            if m:
                dv = props.get(m.group(1), dv)
                if dv.startswith("${"):
                    continue
            # resolve Maven version ranges [x] or [x,) to base version x
            rm = re.match(r"\[\s*([0-9][^,\]\)]*)\s*(?:,.*)?\]", dv)
            if rm:
                dv = rm.group(1)
            if dg in SKIP_GROUPS:
                continue
            queue.append((dg, da, dv))
    except Exception as e:
        print(f"  pom parse fail: {e}")

print(f"\nDone. AARs: {len(os.listdir(AARS))}")

# Compiler jars skipped by SKIP_GROUPS but required by step2_kotlinc.py:
# the embeddable compiler needs kotlin-stdlib next to it, and the Compose
# plugin jar is passed explicitly via -Xplugin.
_EXTRA = [
    ("org.jetbrains.kotlin", "kotlin-compiler-embeddable", "2.0.21"),
    ("org.jetbrains.kotlin", "kotlin-compose-compiler-plugin-embeddable", "2.0.21"),
    # Required at runtime by concurrent-futures (AbstractResolvableFuture
    # implements Guava's ListenableFuture). JAR-only, Maven Central only —
    # the Google-Maven AAR/JAR fallback in the main loop misses it.
    # Missing it caused the ProfileInstaller startup crash (2026-10-02).
    ("com.google.guava", "listenablefuture", "1.0"),
]
for g, a, v in _EXTRA:
    dest = os.path.join(LIBS, f"{a}-{v}.jar")
    if not (os.path.exists(dest) and os.path.getsize(dest) > 100):
        fetch(f"{MAVEN}/{g.replace('.', '/')}/{a}/{v}/{a}-{v}.jar", dest)
import shutil as _sh
_std = "/home/hatch/kotlin/kotlinc/lib/kotlin-stdlib.jar"
if os.path.exists(_std):
    _sh.copy(_std, os.path.join(LIBS, "kotlin-stdlib.jar"))
print("compiler jars ready")
