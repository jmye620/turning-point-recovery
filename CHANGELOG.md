# Turning Point Recovery — Android Changelog

Package: `com.turningpoint.recoveryapp` · Min SDK 26 (Android 8.0) · armv8 32/64-bit

## 1.1.9 — 2026-10-10 (versionCode 11)
- App launcher icon reverted to the previous sunrise vector icon (teal background)

## 1.1.8 — 2026-10-10 (versionCode 10)
- New **Community resources** section on the Resources tab, three expandable cards:
  - **SMART Recovery** — the 4-Point Program, note about the Thursday 12:00 PM meeting at the center, link to smartrecovery.org
  - **Employment** — file-for-unemployment button (kcc.ky.gov) plus 5 Western Kentucky second-chance employers: Pella (Murray), People Plus staffing (Paducah/Madisonville/Henderson/Greenville), Goodwill Industries of Kentucky, SCH Services (Calvert City), Dairy Queen (Princeton)
  - **Food** — SNAP & Medicaid application button (kynect.ky.gov) plus 5 Paducah-area food kitchens/pantries with addresses and hours: Community Kitchen, Family Kitchen of Western Kentucky, Paducah Cooperative Ministry, Family Service Society, St. Vincent de Paul
- New app launcher icon — the Turning Point Recovery Community Center logo
- All new content available in English and Spanish

## 1.1.7 — 2026-10-04 (versionCode 9)
- 12 Steps reworded beyond alcohol: Steps 1 and 12 now speak of "addiction" / "addicts" (EN/ES)
- Money-saved tracker gains a **drug of choice** path — enter the drug and average spent per day (the Alcohol path is unchanged)
- First Play Store-ready release bundle (AAB), target SDK 35, release-signed

## 1.1.6 — 2026-10-04 (versionCode 8)
- New **money-saved tracker** on the Counter tab: drinks per day, drink of choice (Beer $2.00 / Wine $3.50 / Liquor $4.50, price editable), running USD total from the clean date
- New **Steps** tab ("Pasos"): full 12 Steps checklist in EN/ES with "X / 12 completed" progress, saved on device
- New **Sponsors** tab ("Padrinos"): name + phone list, tap to call, saved on device

## 1.1.5 — 2026-10-02 (versionCode 7)
- Meeting schedule rewritten to match the community center flyer (Mon–Fri, incl. Wednesday 8 PM Young People in Recovery and Friday 6 PM StrongHER)
- Center phone number (270.444.3621) is now tappable on the Meetings screen

## 1.1.4 — 2026-10-02 (versionCode 6)
- **Fixed the startup crash.** Root cause found: `AbstractResolvableFuture` implements Guava's `ListenableFuture`, and the Guava `listenablefuture` library was missing from the build — so Android couldn't load the class at startup. The library is now bundled and its presence is verified inside every build.

## 1.1.3 — 2026-10-02 (versionCode 5)
- Crash reporter: saves the stack trace when the app crashes and offers to share it on next launch; the report now includes the app version
- App version shown in the footer of every tab (e.g. "v1.1.3")

## 1.1.2 — 2026-10-02 (versionCode 4)
- Internal build; attempted startup-crash fix that did not resolve the issue (superseded by 1.1.3/1.1.4)

## 1.1.1 — 2026-10-01 (versionCode 3)
- 4-year milestone chip added to the Counter tab (chips previously jumped from 3 years to 5)
- "Share your clean time" now uses the system share sheet (total days + year/month/day breakdown card)

## 1.0 — 2026-10-01 (versionCode 1)
- Initial native Android release (Kotlin + Jetpack Compose): 6 tabs — Today, Check-in, Counter, Meetings, Resources, Events — EN/ES toggle, clean-date counter with milestone chips, daily check-ins, journal, coping tools (box breathing, grounding, HALT, urge surfing), crisis resources, support contacts. All data stored on-device only.
- Package renamed to `com.turningpoint.recoveryapp` the same day to resolve an install signature conflict with the first build.
