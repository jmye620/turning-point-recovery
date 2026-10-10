# Turning Point Recovery

Native mobile apps for the **Turning Point Recovery Community Center** — daily recovery support tools for people in recovery and their community.

- **`android/`** — native Android app (Kotlin + Jetpack Compose)
- **`ios/`** — native iPhone app (SwiftUI)
- **`website/`** — standalone website (single self-contained `index.html`, no build step)

Both apps and the website share the same features and stay in sync:

- **Recovery counter** with milestone chips (24 hours → 5 years), shareable milestone cards
- **Share your clean time** — renders a share card and sends it via text, email, or social apps
- **Daily check-in** and **journal**
- **Meeting schedule** for the Turning Point Recovery Community Center (tap the center phone number to call)
- **Coping tools**: box breathing, grounding, HALT check, urge surfing
- **Crisis support** sheet with one-tap call/text
- **Money saved** tracker (alcohol or drug of choice: total = sober days × daily spend)
- **12 Steps** checklist (worded for all addictions, not just alcohol)
- **Sponsors** list with one-tap calling
- **English / Spanish** toggle throughout
- **Local-only storage** — your data never leaves your device

## Website

`website/index.html` is a fully self-contained site (HTML + CSS + JS in one
file, no dependencies, no build step). Open it in any browser, or host it on
any static host.

### Deploy to Netlify (auto-sync from this repo)

1. Push this repo to GitHub (see below).
2. In Netlify: **Add new site → Import an existing project → GitHub**,
   select this repository.
3. Build settings: **build command** empty, **publish directory** `website`.
4. Every push to `main` redeploys the site automatically.

## Android

Package `com.turningpoint.recoveryapp` · min SDK 26 (Android 8) · target/compile SDK 34 · portrait phones.

### Standard build (Android Studio)

1. Open `android/` in Android Studio.
2. Let Gradle sync, then **Run** on a device or emulator (or `./gradlew assembleDebug`).

### Manual build (no Gradle daemon)

The `android/build-tools/` scripts build the APK directly with `aapt2` / `kotlinc` / `d8`
— this is how the release APKs were produced. See
[`android/build-tools/README.md`](android/build-tools/README.md) for the full pipeline:

```
fetch_deps.py → extract_aars.py → step1_res.py → step1b_r.py →
step2_kotlinc.py → javac (R.java) → step3_d8.py → step4_package.py
```

Prerequisites: JDK 17, Kotlin 2.0.21, Android SDK (build-tools 34, platform android-34).

> **Dependency notes**
> - `material-icons-extended-android` is the real Android icons AAR; the plain
>   `material-icons-extended` artifact on Google Maven is a KMP stub.
> - `androidx.concurrent:concurrent-futures` (JAR-only) and
>   `com.google.guava:listenablefuture` (Maven Central only) are required at
>   runtime by `androidx.profileinstaller` — omitting them crashes the app at
>   startup with `NoClassDefFoundError: AbstractResolvableFuture`.

## iOS

Native SwiftUI port: iPhone only, portrait, iOS 17+. Bundle ID `com.turningpoint.recoveryapp`.

1. Open `ios/TurningPointRecovery.xcodeproj` in Xcode on a Mac.
2. Select your team for signing, pick your iPhone as the destination, and **Run**.
3. A free Apple ID installs the app for 7 days at a time; a paid Apple Developer
   account enables TestFlight / App Store distribution.

iOS apps can only be compiled and signed on a Mac — there is no way to produce
an installable `.ipa` without Xcode.

## Signing

APKs are signed with a **debug keystore** for sideloading/testing only — not
release-signed and not Play Store-ready. Keep the same keystore for every build:
changing it forces users to uninstall (which wipes the app's local data).

The debug keystore is intentionally **not** committed to this repo. If you
publish this repo publicly, never commit a release keystore or Play upload key.

### Play Store release (.aab)

A release-signed **Android App Bundle** is built with the manual pipeline plus
`android/build-tools/step5_bundle.py`:

```
TARGET_SDK=35 BUNDLE_PROTO=1 step1_res.py → step1b_r.py → step2_kotlinc.py →
javac (R.java) → step3_d8.py → step5_bundle.py
```

- `TARGET_SDK` / `BUNDLE_PROTO` are optional env vars (default `34` / unset,
  which keeps the regular debug-APK pipeline unchanged).
- `step5_bundle.py` signs with `release.keystore` (upload key, kept next to
  the debug keystore — never commit it) and needs `bundletool.jar` in
  `android/build-tools/` ([download](https://github.com/google/bundletool/releases)).
- The bundle targets SDK 35 (Play's current minimum for new apps) with min SDK
  26 unchanged.

Upload the `.aab` to a **closed testing** track in Play Console for a private
beta; enroll in Play App Signing on first upload using the upload certificate.

## Version history

- 1.1.8 — new "Community resources" section on the Resources tab: SMART
  Recovery (4-Point Program, Thursday 12pm center meeting note, smartrecovery.org),
  Employment (kcc.ky.gov unemployment + 5 Western KY second-chance employers),
  Food (kynect.ky.gov SNAP/Medicaid + 5 Paducah-area kitchens/pantries); new
  Turning Point launcher icon
- 1.1.7 — 12 Steps reworded for all addictions (not just alcohol); money-saved
  tracker gains a drug-of-choice option (drug + average spent/day)
- 1.1.6 — money-saved tracker on the Counter tab; new Steps tab (12-step
  checklist); new Sponsors tab (name + phone, tap to call)
- 1.1.5 — meeting schedule updated to the community center flyer; tappable center phone
- 1.1.4 — fixed startup crash (missing `concurrent-futures` / Guava `listenablefuture`)
- 1.1.3 — crash reporter (saves stack trace, shareable on next launch), version in footer
- 1.1.1 — 4-year milestone chip, "Share your clean time" via system share sheet
- 1.0 — initial native Android release

## License

MIT — see [LICENSE](LICENSE).
