# Manual Android Build Pipeline

Gradle's daemon doesn't work in this environment, so the APK is built manually:

1. `fetch_deps.py` - Download AAR/JAR deps from Maven Central (+ compiler jars)
2. `extract_aars.py` - Extract the highest-version AAR per artifact dir
   (Gradle-style max-version resolution; fetch does NOT extract)
3. `step1_res.py` - Compile resources with aapt2, link APK, generate R.java stubs
4. `step1b_r.py` - Generate R.java for app + libraries from aapt2 symbols
5. `step2_kotlinc.py` - Compile Kotlin sources with kotlinc + Compose plugin
   (NOTE: kotlinc 2.0.21 silently skips Java sources; R.java MUST be compiled separately)
6. Compile R.java with javac:
   `javac -cp $ANDROID_JAR -d work/r-classes @work/gen_all_files.txt`
7. `step3_d8.py` - Dex app classes + R classes + libraries with D8
8. `step4_package.py` - Package fresh APK, zipalign, sign

Signing: the debug keystore lives at `~/workspace/recovery-app/debug.keystore`
(PERSISTENT - never move it to /tmp). Losing it changes the APK signature and
forces users to uninstall, wiping their local app data.

Toolchain: Temurin JDK 17 at ~/jdk, Kotlin 2.0.21 at ~/kotlin (both wiped on VM
replacement - reinstall from GitHub releases if missing).

material-icons-extended is a KMP stub on Google Maven; the real Android AAR is
`androidx.compose.material:material-icons-extended-android` (in ROOTS).
