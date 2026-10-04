# Turning Point Recovery — iPhone app

Native iOS port of the Turning Point Recovery Android app, written in **Swift + SwiftUI**.
Same 6 tabs (Today, Check-in, Counter, Meetings, Resources, Events), same EN/ES
in-app language toggle, same crisis sheet, same coping tools. All personal data
(check-ins, journal, contacts, clean date) is stored in `UserDefaults` **on the
phone only** — nothing is sent anywhere, mirroring the Android app.

Bundle ID: `com.turningpoint.recoveryapp` (same as the Android app)
Deployment target: **iOS 17.0** (iPhone only)

## Project layout

```
TurningPointRecovery.xcodeproj      ← open this in Xcode
TurningPointRecovery/
├── TurningPointRecoveryApp.swift   ← app entry point
├── ContentView.swift               ← top bar + custom tab bar + crisis sheet
├── Theme.swift                     ← colors & fonts
├── Info.plist
├── Assets.xcassets                 ← app icon + accent color
├── Models/
│   ├── Store.swift                 ← all on-device storage (UserDefaults)
│   ├── Strings.swift               ← every UI string, EN + ES
│   └── Content.swift               ← quotes, meetings, services, milestones, date helpers
└── Views/
    ├── Common.swift                ← shared cards, buttons, call rows, footer
    ├── TodayView.swift
    ├── CheckInView.swift
    ├── CounterView.swift           ← clean-date counter + milestone share card
    ├── MeetingsView.swift          ← weekly schedule + add to Calendar (EventKit)
    ├── ResourcesView.swift         ← box breathing, grounding, HALT, urge surfing…
    ├── EventsView.swift
    └── CrisisSheet.swift           ← crisis lines + personal support contacts
```

## How to build & install on an iPhone

iOS apps **must** be built and signed on a Mac — there is no sideloadable
`.ipa` equivalent of an Android APK. You need:

1. A **Mac** with **Xcode 15 or later** (free from the Mac App Store).
2. An **Apple ID**. A free Apple ID is enough to install on your own iPhone
   (the signing certificate expires after 7 days, so you'd rebuild weekly).
   A paid Apple Developer account ($99/yr) enables TestFlight and the App Store.

Steps:

1. Copy this folder to the Mac and double-click
   `TurningPointRecovery.xcodeproj`.
2. Connect the iPhone with a cable, unlock it, and trust the computer.
3. In Xcode, select the **TurningPointRecovery** target → **Signing & Capabilities**
   → choose your Team (your Apple ID). Xcode may adjust the bundle identifier
   if `com.turningpoint.recoveryapp` is taken — that's fine.
4. Select your iPhone as the run destination and press **Run** (⌘R).
5. On first launch the phone asks for **Calendar** permission only when you tap
   "Add to calendar" on a meeting.

## Notes

- The app targets iPhone only (`TARGETED_DEVICE_FAMILY = 1`), portrait.
- iOS 17+ means iPhone XS/XR and later.
- All iPhones running iOS 17 are 64-bit ARM (Apple dropped 32-bit in iOS 11),
  so there is no 32/64-bit split to worry about like on Android.
- Phone calls use `tel://` links (opens the Phone app's dialer, same behavior
  as the Android version's dial intents); texts use `sms:` links.
- The milestone share card is rendered with `UIGraphicsImageRenderer` and
  shared through the standard iOS share sheet (save to Photos, send, etc.).
