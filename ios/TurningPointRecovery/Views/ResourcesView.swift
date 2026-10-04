import SwiftUI

struct ResourcesView: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let lang: String
    let goTo: (AppTab) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: s.copingTools)

            ToolCard(emoji: "🫁", title: s.boxBreathing, body: s.boxBreathingBody) {
                BoxBreathingTool(s: s)
            }
            ToolCard(emoji: "👁", title: s.grounding, body: s.groundingBody) {
                GroundingTool(s: s)
            }
            ToolCard(emoji: "⏸", title: s.halt, body: s.haltBody) {
                HaltTool(s: s)
            }
            ToolCard(emoji: "🌊", title: s.urgeSurfing, body: s.urgeSurfingBody) {
                UrgeSurfingTool(s: s)
            }
            ToolCard(emoji: "📞", title: s.callSomeoneTitle, body: s.callSomeoneBody) {
                Button { dial(CENTER_PHONE) } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                        Text("\(s.callTurningPoint): \(CENTER_PHONE_PRETTY)")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(Color.deepTeal).cornerRadius(50)
                }
                .padding(.top, 8)
            }
            ToolCard(emoji: "✍️", title: s.writeItOut, body: s.writeItOutBody) {
                WriteItOutTool(s: s)
            }

            SectionTitle(text: s.freeServices).padding(.top, 18)
            RecoveryCard {
                ForEach(SERVICES, id: \.en) { svc in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.deepTeal).font(.body.weight(.bold))
                        Text(lang == "es" ? svc.es : svc.en).font(.body)
                    }
                    .padding(.vertical, 5)
                }
                Text(s.freeServicesNote)
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.warmGray)
                    .padding(.top, 8)
            }

            RecoveryCard {
                Text("🎙️").font(.title)
                Text(s.podcastTitle).font(.headline).padding(.top, 4)
                Text(s.podcastBody).font(.subheadline).foregroundColor(.warmGray).padding(.top, 2)
            }
            .padding(.top, 16)

            SectionTitle(text: s.visitCenter).padding(.top, 16)
            RecoveryCard {
                Text("TURNING POINT RECOVERY COMMUNITY CENTER")
                    .font(.headline).foregroundColor(.deepTeal).fontWeight(.bold)
                Text(s.visitAddress).font(.body).padding(.top, 2)
                Text(s.visitEnter).font(.subheadline).foregroundColor(.warmGray).padding(.top, 2)
                Text(s.hoursTitle).font(.headline).padding(.top, 10)
                Text(lang == "es"
                     ? "Lun · Mié · Vie 8 a.m.–5 p.m.\nMar · Jue 8 a.m.–7 p.m."
                     : "Mon · Wed · Fri 8 a.m.–5 p.m.\nTue · Thu 8 a.m.–7 p.m.")
                    .font(.body)
                if let status = openStatus(s: s) {
                    Text(status).font(.subheadline).fontWeight(.bold).foregroundColor(.deepTeal)
                        .padding(.top, 6)
                }
                Button { dial(CENTER_PHONE) } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                        Text(s.callTheCenter).fontWeight(.bold)
                    }
                    .foregroundColor(.deepTeal)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.deepTeal, lineWidth: 1.5))
                }
                .padding(.top, 10)
            }

            Footer(store: store, s: s) { goTo(.resources) }
        }
    }
}

// MARK: - Expandable tool card

private struct ToolCard<Content: View>: View {
    let emoji: String
    let title: String
    let body: String
    let content: Content
    init(emoji: String, title: String, body: String, @ViewBuilder content: () -> Content) {
        self.emoji = emoji; self.title = title; self.body = body; self.content = content()
    }
    @State private var open = false

    var body: some View {
        RecoveryCard {
            Button { withAnimation { open.toggle() } } label: {
                HStack(spacing: 12) {
                    Text(emoji).font(.title)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.headline).foregroundColor(.ink)
                        if !open {
                            Text(body).font(.subheadline).foregroundColor(.warmGray)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                    Image(systemName: open ? "chevron.up" : "chevron.down")
                        .foregroundColor(.warmGray)
                }
            }
            .buttonStyle(.plain)

            if open {
                Text(body).font(.subheadline).foregroundColor(.warmGray)
                    .padding(.top, 8)
                content
            }
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Box breathing

private struct BoxBreathingTool: View {
    let s: AppStrings
    @State private var running = false
    @State private var phase = 0   // 0 in, 1 hold, 2 out, 3 hold
    @State private var round = 1
    @State private var count = 4
    @State private var timer: Timer? = nil

    private var phases: [String] { [s.breatheIn, s.breatheHold, s.breatheOut, s.breatheHold] }

    var body: some View {
        VStack(spacing: 8) {
            if running {
                Text("\(s.roundOf) \(round) / 4").font(.subheadline).foregroundColor(.warmGray)
                Text(phases[phase]).font(.title2).foregroundColor(.deepTeal)
                Text("\(count)").font(.system(size: 44, weight: .bold)).foregroundColor(.deepTeal)
                Button { stop() } label: {
                    Text(s.stop).fontWeight(.bold).foregroundColor(.white)
                        .padding(.horizontal, 24).padding(.vertical, 10)
                        .background(Color.helpOrange).cornerRadius(50)
                }
            } else {
                Text("4 · 4 · 4 · 4").font(.headline).foregroundColor(.warmGray)
                PillButton(s.start) { round = 1; phase = 0; start() }
                    .frame(maxWidth: 200)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color.deepTeal.opacity(0.08))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deepTeal.opacity(0.3)))
        .padding(.top, 10)
        .onDisappear { stop() }
    }

    private func start() {
        running = true
        count = 4
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if count > 1 {
                count -= 1
            } else if phase == 3 {
                if round >= 4 { stop() }
                else { round += 1; phase = 0; count = 4 }
            } else {
                phase += 1; count = 4
            }
        }
    }

    private func stop() {
        timer?.invalidate(); timer = nil; running = false
    }
}

// MARK: - Grounding

private struct GroundingTool: View {
    let s: AppStrings
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let steps = [(5, s.groundingSee), (4, s.groundingTouch), (3, s.groundingHear), (2, s.groundingSmell), (1, s.groundingTaste)]
            ForEach(steps, id: \.0) { n, label in
                HStack(spacing: 10) {
                    Text("\(n)").fontWeight(.bold).foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.deepTeal).cornerRadius(50)
                    Text(label).font(.body)
                }
                .padding(.vertical, 5)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - HALT

private struct HaltTool: View {
    let s: AppStrings
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let rows = [("🍽", s.haltHungry, s.haltHungryTip),
                        ("😠", s.haltAngry, s.haltAngryTip),
                        ("💛", s.haltLonely, s.haltLonelyTip),
                        ("😴", s.haltTired, s.haltTiredTip)]
            ForEach(rows, id: \.1) { emoji, title, tip in
                HStack(spacing: 10) {
                    Text(emoji).font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.headline)
                        Text(tip).font(.subheadline).foregroundColor(.warmGray)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Urge surfing

private struct UrgeSurfingTool: View {
    let s: AppStrings
    private let total = 20 * 60
    @State private var running = false
    @State private var secondsLeft = 20 * 60
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 10) {
            if running {
                let mm = secondsLeft / 60
                let ss = secondsLeft % 60
                Text(String(format: "%02d:%02d", mm, ss))
                    .font(.system(size: 44, weight: .bold)).foregroundColor(.deepTeal)
                ProgressView(value: Double(total - secondsLeft), total: Double(total))
                    .tint(.deepTeal)
                let elapsed = total - secondsLeft
                Text(elapsed < total / 3 ? s.urgePhaseRise
                     : elapsed < total * 2 / 3 ? s.urgePhasePeak
                     : s.urgePhaseFall)
                    .font(.body).foregroundColor(.warmGray)
                Button { stop() } label: {
                    Text(s.stop).fontWeight(.bold).foregroundColor(.white)
                        .padding(.horizontal, 24).padding(.vertical, 10)
                        .background(Color.helpOrange).cornerRadius(50)
                }
            } else {
                Text("20:00").font(.system(size: 44, weight: .bold)).foregroundColor(.deepTeal)
                PillButton(s.start) { secondsLeft = total; start() }
                    .frame(maxWidth: 200)
            }
            Button { dial(CRISIS_LINE) } label: {
                Text("\(s.urgeNeedSomeone) \(s.call) \(CRISIS_LINE_PRETTY)")
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.deepTeal)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color.deepTeal.opacity(0.08))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.deepTeal.opacity(0.3)))
        .padding(.top, 10)
        .onDisappear { stop() }
    }

    private func start() {
        running = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if secondsLeft > 0 { secondsLeft -= 1 }
            else { stop() }
        }
    }

    private func stop() {
        timer?.invalidate(); timer = nil; running = false
    }
}

// MARK: - Write it out

private struct WriteItOutTool: View {
    let s: AppStrings
    @State private var text = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $text)
                .frame(height: 120)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.softBorder))
                .overlay(alignment: .topLeading) {
                    if text.isEmpty { Text(s.writeHint).foregroundColor(.warmGray).padding(8) }
                }
            Button { text = "" } label: {
                Text(s.clearPage).fontWeight(.semibold).foregroundColor(.deepTeal)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.softBorder))
            }
        }
        .padding(.top, 8)
    }
}
