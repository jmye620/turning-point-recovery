import SwiftUI

struct TodayView: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let lang: String
    let goTo: (AppTab) -> Void
    let openCrisis: () -> Void

    @State private var qi: Int = 0
    private let now = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(greeting(date: now, s: s)),")
                .font(.displaySmall).foregroundColor(.ink)
            Text(fullDateString(now, lang: lang))
                .font(.body).foregroundColor(.warmGray)
                .padding(.top, 2)

            if let status = openStatus(date: now, s: s) {
                Text(status)
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.deepTeal)
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(Color.deepTeal.opacity(0.12))
                    .cornerRadius(50)
                    .padding(.top, 8)
            } else {
                Text(s.closedNow)
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.warmGray)
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(Color.warmGray.opacity(0.15))
                    .cornerRadius(50)
                    .padding(.top, 8)
            }

            // Event banner
            RecoveryCard {
                Text("🎃").font(.largeTitle)
                Text(s.halloweenTitle).font(.titleLargeRecovery).padding(.top, 4)
                Text(s.halloweenWhen).font(.subheadline).foregroundColor(.warmGray)
                Text(s.halloweenWhere).font(.subheadline).foregroundColor(.warmGray)
                Button { goTo(.events) } label: {
                    Text(s.seeAllEvents).fontWeight(.bold).foregroundColor(.deepTeal)
                }
                .padding(.top, 8)
            }
            .padding(.top, 16)

            SectionTitle(text: s.todaysInspiration).padding(.top, 16)
            RecoveryCard {
                let quote = QUOTES[qi % QUOTES.count]
                Text("“\(lang == "es" ? quote.es : quote.en)”")
                    .font(.headline)
                Text("— Recovery wisdom").font(.subheadline).foregroundColor(.warmGray)
                    .padding(.top, 4)
                Button {
                    qi = (qi + 1) % QUOTES.count
                    store.nextQuote(total: QUOTES.count)
                } label: {
                    Text(s.anotherOne).fontWeight(.bold).foregroundColor(.deepTeal)
                }
                .padding(.top, 8)
            }
            .onAppear { qi = store.quoteIndex() }

            SectionTitle(text: s.nextMeeting).padding(.top, 16)
            if let (meeting, dayLabel) = nextUpcomingMeeting(now: now, lang: lang) {
                RecoveryCard {
                    Text(meeting.time)
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.helpOrange)
                    Text(lang == "es" ? meeting.nameEs : meeting.nameEn)
                        .font(.titleLargeRecovery).padding(.top, 2)
                    Text(lang == "es" ? meeting.descEs : meeting.descEn)
                        .font(.subheadline).foregroundColor(.warmGray)
                    Text("\(s.atTheCenter) · 415 Broadway, Paducah")
                        .font(.subheadline).foregroundColor(.warmGray)
                    if let dayLabel = dayLabel {
                        Text(dayLabel).font(.caption).foregroundColor(.warmGray).padding(.top, 2)
                    }
                    Button { goTo(.meetings) } label: {
                        Text(s.seeFullSchedule + " →").fontWeight(.bold).foregroundColor(.deepTeal)
                    }
                    .padding(.top, 6)
                }
            }

            SectionTitle(text: s.whatDoYouNeed).padding(.top, 16)
            let shortcuts: [(String, String, String, () -> Void)] = [
                (s.shortcutCheckIn, s.shortcutCheckInSub, "clipboard.fill") { goTo(.checkIn) },
                (s.shortcutCounter, s.shortcutCounterSub, "medal.fill") { goTo(.counter) },
                (s.shortcutCoping, s.shortcutCopingSub, "leaf.fill") { goTo(.resources) },
                (s.shortcutHelp, s.shortcutHelpSub, "heart.handshake.fill") { openCrisis() },
            ]
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(0..<shortcuts.count, id: \.self) { i in
                    let (title, sub, icon, action) = shortcuts[i]
                    Button(action: action) {
                        RecoveryCard {
                            Image(systemName: icon)
                                .font(.title2).foregroundColor(.deepTeal)
                            Text(title).font(.headline).foregroundColor(.ink)
                                .padding(.top, 8)
                            Text(sub).font(.subheadline).foregroundColor(.warmGray)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Footer(store: store, s: s) { goTo(.today) }
        }
    }
}
