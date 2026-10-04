import SwiftUI

extension Color {
    static let cream = Color(red: 0xF5/255, green: 0xF1/255, blue: 0xE6/255)
    static let deepTeal = Color(red: 0x0E/255, green: 0x5B/255, blue: 0x57/255)
    static let deepTealDark = Color(red: 0x0A/255, green: 0x44/255, blue: 0x41/255)
    static let helpOrange = Color(red: 0xE4/255, green: 0x57/255, blue: 0x2E/255)
    static let warmGray = Color(red: 0x6B/255, green: 0x64/255, blue: 0x55/255)
    static let softBorder = Color(red: 0xE4/255, green: 0xDC/255, blue: 0xC8/255)
    static let gold = Color(red: 0xC9/255, green: 0x96/255, blue: 0x2E/255)
    static let danger = Color(red: 0xB3/255, green: 0x26/255, blue: 0x1E/255)
    static let ink = Color(red: 0x1F/255, green: 0x1B/255, blue: 0x13/255)
}

/// Shared font styles matching the Android theme (serif display/headings).
extension Font {
    static let displaySmall = Font.custom("Georgia-Bold", size: 28).weight(.bold)
    static let headlineRecovery = Font.custom("Georgia-Bold", size: 22).weight(.bold)
    static let titleLargeRecovery = Font.custom("Georgia-Bold", size: 20).weight(.bold)
}
