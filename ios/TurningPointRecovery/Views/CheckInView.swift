import SwiftUI

struct CheckInView: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let lang: String
    let goTo: (AppTab) -> Void
    let openCrisis: () -> Void

    private let today = Date()
    @State private var submitted = false
    @State private var journalText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: s.checkInTitle)
            Text(s.checkInSubtitle).font(.body).foregroundColor(.warmGray)
                .padding(.bottom, 14)

            if !submitted {
                CheckInForm(store: store, s: s, onDone: { mood, cravings, gratitude, hasCall in
                    let f = DateFormatter(); f.dateFormat = "HH:mm"; f.timeZone = zone
                    store.saveCheckIn(CheckIn(date: dateKey(today), mood: mood, cravings: cravings,
                                              gratitude: gratitude, hasCall: hasCall, time: f.string(from: Date())))
                    submitted = true
                })
            } else if let c = store.getCheckIn(date: today) {
                RecoveryCard {
                    Text("💛").font(.largeTitle)
                    Text(s.checkInDoneTitle).font(.titleLargeRecovery).padding(.top, 6)
                    Text(s.checkInDoneBody).font(.body).foregroundColor(.warmGray).padding(.top, 2)
                    let moods = [s.moodGreat, s.moodGood, s.moodOkay, s.moodLow, s.moodStruggling]
                    let cravs = [s.cravingsNone, s.cravingsMild, s.cravingsStrong]
                    Text("\(s.feeling): \(moods[c.mood]) · \(s.cravings): \(cravs[c.cravings])")
                        .font(.subheadline).foregroundColor(.warmGray).padding(.top, 10)
                    if !c.gratitude.isEmpty {
                        Text("“\(c.gratitude)”").font(.subheadline).fontWeight(.medium).padding(.top, 2)
                    }
                    HStack {
                        Button { goTo(.resources) } label: {
                            Text(s.tryBoxBreathing).fontWeight(.bold).foregroundColor(.deepTeal)
                        }
                        Spacer()
                        Button { goTo(.meetings) } label: {
                            Text(s.seeTodaysMeetings).fontWeight(.bold).foregroundColor(.deepTeal)
                        }
                    }
                    .padding(.top, 12)
                }
            }

            SectionTitle(text: s.recentCheckIns).padding(.top, 16)
            RecoveryCard {
                let streak = store.streak(today: today)
                HStack {
                    Text("🔥").font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text("\(streak) \(streak == 1 ? s.dayStreak : s.daysStreak)")
                            .font(.titleLargeRecovery)
                        Text("Check-in streak").font(.subheadline).foregroundColor(.warmGray)
                    }
                    .padding(.leading, 10)
                }
                let moods = [s.moodGreat, s.moodGood, s.moodOkay, s.moodLow, s.moodStruggling]
                let cravs = [s.cravingsNone, s.cravingsMild, s.cravingsStrong]
                let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"; fmt.timeZone = zone
                ForEach(store.checkInDates().prefix(5), id: \.self) { key in
                    if let d = fmt.date(from: key), let c = store.getCheckIn(date: d) {
                        Text("\(fullDateString(d, lang: lang)) · \(moods[c.mood]) · \(s.cravings): \(cravs[c.cravings])")
                            .font(.subheadline).foregroundColor(.warmGray)
                            .padding(.vertical, 3)
                    }
                }
            }

            SectionTitle(text: s.journalTitle).padding(.top, 16)
            RecoveryCard {
                TextEditor(text: $journalText)
                    .frame(height: 110)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.softBorder))
                    .overlay(alignment: .topLeading) {
                        if journalText.isEmpty {
                            Text(s.journalHint).foregroundColor(.warmGray).padding(8)
                        }
                    }
                Button {
                    let trimmed = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        store.saveJournal(text: trimmed)
                        journalText = ""
                    }
                } label: {
                    Text(s.saveEntry).fontWeight(.bold).foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Color.deepTeal).cornerRadius(50)
                }
                .padding(.top, 10)

                ForEach(store.journalEntries().prefix(10)) { e in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(shortDateTimeString(e.dateTime, lang: lang))
                                .font(.caption).foregroundColor(.warmGray)
                            Text(e.text).font(.body)
                        }
                        Spacer()
                        Button { store.deleteJournal(id: e.id) } label: {
                            Text(s.delete).foregroundColor(.danger)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }

            Footer(store: store, s: s) { goTo(.checkIn) }
        }
        .onAppear { submitted = store.getCheckIn(date: today) != nil }
    }
}

private struct CheckInForm: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let onDone: (Int, Int, String, Bool) -> Void

    @State private var mood = -1
    @State private var cravings = -1
    @State private var gratitude = ""
    @State private var hasCall: Bool? = nil
    @State private var showError = false

    private let moodEmojis = ["😄", "🙂", "😐", "😟", "😞"]

    var body: some View {
        RecoveryCard {
            Text(s.moodLabel).font(.headline)
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { i in
                    let labels = [s.moodGreat, s.moodGood, s.moodOkay, s.moodLow, s.moodStruggling]
                    Button { mood = i } label: {
                        VStack(spacing: 2) {
                            Text(moodEmojis[i]).font(.title)
                                .padding(10)
                                .background(mood == i ? Color.deepTeal.opacity(0.15) : Color.white)
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                    .stroke(mood == i ? Color.deepTeal : Color.softBorder, lineWidth: 1.5))
                            Text(labels[i]).font(.caption).foregroundColor(.warmGray)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)

            Text(s.cravingsLabel).font(.headline).padding(.top, 14)
            HStack(spacing: 8) {
                let labels = [s.cravingsNone, s.cravingsMild, s.cravingsStrong]
                ForEach(0..<3, id: \.self) { i in
                    Button { cravings = i } label: {
                        Text(labels[i]).fontWeight(.semibold)
                            .foregroundColor(cravings == i ? .white : .deepTeal)
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .background(cravings == i ? Color.deepTeal : Color.white)
                            .cornerRadius(50)
                            .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.deepTeal, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)

            Text(s.gratitudeLabel).font(.headline).padding(.top, 14)
            TextField(s.gratitudeHint, text: $gratitude)
                .textFieldStyle(.roundedBorder)
                .padding(.top, 8)

            Text(s.callSomeoneLabel).font(.headline).padding(.top, 14)
            HStack(spacing: 8) {
                ForEach([(true, s.yes), (false, s.no)], id: \.0) { value, label in
                    Button { hasCall = value } label: {
                        Text(label).fontWeight(.semibold)
                            .foregroundColor(hasCall == value ? .white : .deepTeal)
                            .padding(.horizontal, 22).padding(.vertical, 9)
                            .background(hasCall == value ? Color.deepTeal : Color.white)
                            .cornerRadius(50)
                            .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.deepTeal, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)

            if showError {
                Text(s.completeAllFields).foregroundColor(.danger).font(.subheadline)
                    .padding(.top, 12)
            }

            PillButton(s.completeCheckIn) {
                if mood < 0 || cravings < 0 || hasCall == nil {
                    showError = true
                } else {
                    onDone(mood, cravings, gratitude.trimmingCharacters(in: .whitespacesAndNewlines), hasCall == true)
                }
            }
            .padding(.top, 16)
        }
    }
}
