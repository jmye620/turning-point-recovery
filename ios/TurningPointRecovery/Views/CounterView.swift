import SwiftUI
import UIKit

struct CounterView: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let lang: String
    let goTo: (AppTab) -> Void

    @State private var picked = Date()
    @State private var shareFor: Milestone? = nil
    @State private var shareCleanTime = false
    @State private var changingDate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: s.counterTitle)
            Text(s.counterSubtitle).font(.body).foregroundColor(.warmGray)
                .padding(.bottom, 14)

            if store.cleanDate == nil {
                RecoveryCard {
                    Text(s.cleanDateLabel).font(.headline)
                    DatePicker("", selection: $picked, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .accentColor(.deepTeal)
                    Text("30 · 60 · 90 \(s.daysOfRecovery.split(separator: " ").first.map(String.init) ?? "") · 6 · 9 · 18 \(s.months) · 1 · 2 · 4 · 5 \(s.years)")
                        .font(.subheadline).foregroundColor(.warmGray)
                        .padding(.top, 6)
                    Text(s.milestoneTzNote).font(.subheadline).foregroundColor(.warmGray)
                        .padding(.top, 4)
                    PillButton(s.startCounter) {
                        // Normalize to start of day in Chicago time
                        let comps = chicagoCalendar.dateComponents([.year, .month, .day], from: picked)
                        store.cleanDate = chicagoCalendar.date(from: comps)
                    }
                    .padding(.top, 12)
                }
            } else if let cleanDate = store.cleanDate {
                let days = max(0, chicagoCalendar.dateComponents([.day], from: cleanDate, to: Date()).day ?? 0)
                let earned = MILESTONES.filter { days >= $0.days }
                let next = MILESTONES.first { $0.days > days }

                RecoveryCard {
                    VStack(spacing: 6) {
                        Text("🏅").font(.system(size: 40))
                        Text("\(days)").font(.displaySmall)
                        Text(s.daysOfRecovery).font(.headline).foregroundColor(.warmGray)
                        Text(milestoneBreakdown(days: days, s: s))
                            .font(.body).foregroundColor(.deepTeal)
                        Text("\(s.currentChip): \(earned.last.map { lang == "es" ? $0.labelEs : $0.labelEn } ?? "—")")
                            .font(.headline).padding(.top, 4)
                        if let next = next {
                            let left = next.days - days
                            let dayWord = left == 1 ? s.day : s.days
                            Text("\(s.nextMilestone): \(lang == "es" ? next.labelEs : next.labelEn) — \(s.inDays) \(left) \(dayWord)")
                                .font(.subheadline).foregroundColor(.warmGray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                PillButton(s.shareCleanTime) { shareCleanTime = true }
                    .padding(.top, 14)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(MILESTONES, id: \.days) { m in
                        let isEarned = days >= m.days
                        Button { if isEarned { shareFor = m } } label: {
                            VStack(spacing: 4) {
                                Text(isEarned ? "✓" : "○")
                                    .font(.title2)
                                    .foregroundColor(isEarned ? .gold : .warmGray)
                                Text(lang == "es" ? m.labelEs : m.labelEn)
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundColor(.ink)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(isEarned ? Color.gold.opacity(0.16) : Color.white)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(isEarned ? Color.gold : Color.softBorder, lineWidth: 1.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 14)

                Text(s.chipNote).font(.subheadline).foregroundColor(.warmGray)
                    .padding(.top, 8)
                Button {
                    let comps = chicagoCalendar.dateComponents([.year, .month, .day], from: cleanDate)
                    picked = chicagoCalendar.date(from: comps) ?? Date()
                    changingDate = true
                } label: {
                    Text(s.changeDate).fontWeight(.bold).foregroundColor(.deepTeal)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)
                .sheet(isPresented: $changingDate) {
                    NavigationView {
                        VStack {
                            DatePicker("", selection: $picked, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .accentColor(.deepTeal)
                                .padding()
                            Spacer()
                        }
                        .navigationTitle(s.changeDate)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(s.save) {
                                    let comps = chicagoCalendar.dateComponents([.year, .month, .day], from: picked)
                                    store.cleanDate = chicagoCalendar.date(from: comps)
                                    changingDate = false
                                }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button(s.cancel) { changingDate = false }
                            }
                        }
                    }
                }
            }

            Footer(store: store, s: s) { goTo(.counter) }
        }
        .sheet(item: $shareFor) { m in
            ShareSheetView(s: s, lang: lang, milestone: m)
        }
        .sheet(isPresented: $shareCleanTime) {
            CleanTimeShareSheetView(s: s, lang: lang, store: store)
        }
    }
}

extension Milestone: Identifiable {
    var id: Int { days }
}

// MARK: - Milestone share card

private struct ShareSheetView: View {
    let s: AppStrings
    let lang: String
    let milestone: Milestone
    @Environment(\.dismiss) private var dismiss
    @State private var activityItems: [Any] = []
    @State private var showShare = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(lang == "es" ? milestone.labelEs : milestone.labelEn)
                    .font(.titleLargeRecovery).foregroundColor(.deepTeal)
                MilestoneCardImage(s: s, lang: lang, milestone: milestone)
                    .frame(width: 240, height: 300)
                    .cornerRadius(12)
                Button {
                    if let img = renderMilestoneCard(s: s, lang: lang, milestone: milestone) {
                        let label = lang == "es" ? milestone.labelEs : milestone.labelEn
                        let ofRecovery = lang == "es" ? "de recuperación" : "of recovery"
                        activityItems = [img, "\(label) \(ofRecovery) — \(s.shareCardSubtitle) 💛"]
                        showShare = true
                    }
                } label: {
                    Text(s.saveImage).fontWeight(.bold).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color.deepTeal).cornerRadius(50)
                }
                Spacer()
            }
            .padding()
            .navigationTitle(s.shareMilestone)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(s.close) { dismiss() }
                }
            }
            .sheet(isPresented: $showShare) {
                ActivityView(activityItems: activityItems)
            }
        }
    }
}

/// SwiftUI preview of the share card (the actual shared image is drawn with UIKit).
private struct MilestoneCardImage: View {
    let s: AppStrings
    let lang: String
    let milestone: Milestone
    var body: some View {
        VStack(spacing: 8) {
            Text("TURNING POINT").font(.headline).foregroundColor(.white).fontWeight(.bold)
            Text(s.shareCardTag).font(.caption).foregroundColor(.gold).fontWeight(.bold)
            Text("🏅").font(.system(size: 60)).padding(.top, 8)
            Text(s.shareCardTitle).font(.title).fontWeight(.bold).foregroundColor(.white)
            Text(lang == "es" ? milestone.labelEs : milestone.labelEn)
                .font(.title).fontWeight(.bold).foregroundColor(.white)
            Text(lang == "es" ? "de recuperación" : "of recovery")
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Text(s.shareCardSubtitle).italic().foregroundColor(Color(red: 0xE8/255, green: 0xE0/255, blue: 0xCC/255))
        }
        .padding(20)
        .background(Color.deepTeal)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gold, lineWidth: 4).padding(8))
    }
}

/// Renders the milestone card to a UIImage for sharing (mirrors the Android bitmap card).
private func renderMilestoneCard(s: AppStrings, lang: String, milestone: Milestone) -> UIImage? {
    let size = CGSize(width: 1080, height: 1350)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { ctx in
        let teal = UIColor(red: 0x0E/255, green: 0x5B/255, blue: 0x57/255, alpha: 1)
        let gold = UIColor(red: 0xC9/255, green: 0x96/255, blue: 0x2E/255, alpha: 1)
        let cream = UIColor(red: 0xE8/255, green: 0xE0/255, blue: 0xCC/255, alpha: 1)
        teal.setFill()
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 48).fill()
        gold.setStroke()
        UIBezierPath(roundedRect: CGRect(x: 60, y: 60, width: size.width - 120, height: size.height - 120), cornerRadius: 32).stroke()

        func text(_ str: String, y: CGFloat, fontSize: CGFloat, color: UIColor, bold: Bool) {
            let font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font, .foregroundColor: color,
                .paragraphStyle: { let p = NSMutableParagraphStyle(); p.alignment = .center; return p }()
            ]
            let attrStr = NSAttributedString(string: str, attributes: attrs)
            let w = attrStr.size().width
            attrStr.draw(at: CGPoint(x: (size.width - w) / 2, y: y - fontSize))
        }
        text("TURNING POINT", y: 300, fontSize: 64, color: .white, bold: true)
        text(s.shareCardTag, y: 380, fontSize: 34, color: gold, bold: true)
        text("🏅", y: 620, fontSize: 150, color: .white, bold: false)
        text(s.shareCardTitle, y: 740, fontSize: 72, color: .white, bold: true)
        text(lang == "es" ? milestone.labelEs : milestone.labelEn, y: 880, fontSize: 96, color: .white, bold: true)
        text(lang == "es" ? "de recuperación" : "of recovery", y: 950, fontSize: 44, color: .white, bold: false)
        text(s.shareCardSubtitle, y: 1100, fontSize: 48, color: cream, bold: false)
    }
}

// MARK: - Clean time share

/// Share sheet for the total clean time (image + text), shareable to
/// social apps, text messages, or email via UIActivityViewController.
private struct CleanTimeShareSheetView: View {
    let s: AppStrings
    let lang: String
    @ObservedObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var activityItems: [Any] = []
    @State private var showShare = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if let cleanDate = store.cleanDate {
                    let days = max(0, chicagoCalendar.dateComponents([.day], from: cleanDate, to: Date()).day ?? 0)
                    CleanTimeCardImage(s: s, lang: lang, days: days, store: store)
                        .frame(width: 240, height: 300)
                        .cornerRadius(12)
                    Button {
                        if let img = renderCleanTimeCard(s: s, lang: lang, days: days) {
                            let msg = "\(days) \(s.daysOfRecovery) (\(milestoneBreakdown(days: days, s: s))) — \(s.shareCardSubtitle) 💛"
                            activityItems = [img, msg]
                            showShare = true
                        }
                    } label: {
                        Text(s.shareCleanTime).fontWeight(.bold).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.deepTeal).cornerRadius(50)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle(s.shareCleanTime)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(s.close) { dismiss() }
                }
            }
            .sheet(isPresented: $showShare) {
                ActivityView(activityItems: activityItems)
            }
        }
    }
}

/// SwiftUI preview of the clean-time share card.
private struct CleanTimeCardImage: View {
    let s: AppStrings
    let lang: String
    let days: Int
    @ObservedObject var store: Store
    var body: some View {
        VStack(spacing: 8) {
            Text("TURNING POINT").font(.headline).foregroundColor(.white).fontWeight(.bold)
            Text(s.shareCardTag).font(.caption).foregroundColor(.gold).fontWeight(.bold)
            Text("🏅").font(.system(size: 60)).padding(.top, 8)
            Text("\(days)").font(.system(size: 56)).fontWeight(.bold).foregroundColor(.white)
            Text(s.daysOfRecovery).font(.headline).foregroundColor(.white.opacity(0.9))
            Text(milestoneBreakdown(days: days, s: s)).foregroundColor(Color(red: 0xE8/255, green: 0xE0/255, blue: 0xCC/255))
            Spacer()
            Text(s.shareCardSubtitle).italic().foregroundColor(Color(red: 0xE8/255, green: 0xE0/255, blue: 0xCC/255))
        }
        .padding(20)
        .background(Color.deepTeal)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gold, lineWidth: 4).padding(8))
    }
}

/// Renders the clean-time card to a UIImage for sharing (mirrors the Android bitmap card).
private func renderCleanTimeCard(s: AppStrings, lang: String, days: Int) -> UIImage? {
    let size = CGSize(width: 1080, height: 1350)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { ctx in
        let teal = UIColor(red: 0x0E/255, green: 0x5B/255, blue: 0x57/255, alpha: 1)
        let gold = UIColor(red: 0xC9/255, green: 0x96/255, blue: 0x2E/255, alpha: 1)
        let cream = UIColor(red: 0xE8/255, green: 0xE0/255, blue: 0xCC/255, alpha: 1)
        teal.setFill()
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 48).fill()
        gold.setStroke()
        UIBezierPath(roundedRect: CGRect(x: 60, y: 60, width: size.width - 120, height: size.height - 120), cornerRadius: 32).stroke()

        func text(_ str: String, y: CGFloat, fontSize: CGFloat, color: UIColor, bold: Bool) {
            let font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font, .foregroundColor: color,
                .paragraphStyle: { let p = NSMutableParagraphStyle(); p.alignment = .center; return p }()
            ]
            let attrStr = NSAttributedString(string: str, attributes: attrs)
            let w = attrStr.size().width
            attrStr.draw(at: CGPoint(x: (size.width - w) / 2, y: y - fontSize))
        }
        text("TURNING POINT", y: 300, fontSize: 64, color: .white, bold: true)
        text(s.shareCardTag, y: 380, fontSize: 34, color: gold, bold: true)
        text("🏅", y: 640, fontSize: 150, color: .white, bold: false)
        text("\(days)", y: 820, fontSize: 130, color: .white, bold: true)
        text(s.daysOfRecovery, y: 900, fontSize: 52, color: .white, bold: false)
        text(milestoneBreakdown(days: days, s: s), y: 980, fontSize: 44, color: cream, bold: false)
        text(s.shareCardSubtitle, y: 1130, fontSize: 48, color: cream, bold: false)
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
