import SwiftUI

enum AppTab: Hashable {
    case today, checkIn, counter, meetings, resources, events
}

struct ContentView: View {
    @StateObject private var store = Store()
    @State private var tab: AppTab = .today
    @State private var crisisOpen = false

    var body: some View {
        let s = store.language == "es" ? es : en
        let lang = store.language

        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    switch tab {
                    case .today:
                        TodayView(store: store, s: s, lang: lang, goTo: { tab = $0 }, openCrisis: { crisisOpen = true })
                    case .checkIn:
                        CheckInView(store: store, s: s, lang: lang, goTo: { tab = $0 }, openCrisis: { crisisOpen = true })
                    case .counter:
                        CounterView(store: store, s: s, lang: lang, goTo: { tab = $0 })
                    case .meetings:
                        MeetingsView(store: store, s: s, lang: lang, goTo: { tab = $0 })
                    case .resources:
                        ResourcesView(store: store, s: s, lang: lang, goTo: { tab = $0 })
                    case .events:
                        EventsView(store: store, s: s, goTo: { tab = $0 })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.cream)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Text("🌅").font(.title2)
                        Text(s.appName).font(.title3).fontWeight(.bold).foregroundColor(.deepTeal)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        let newLang = store.language == "en" ? "es" : "en"
                        store.language = newLang
                    } label: {
                        Text(s.language)
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.deepTeal)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(50)
                            .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.softBorder))
                    }
                    Button { crisisOpen = true } label: {
                        Text(s.getHelp)
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color.helpOrange).cornerRadius(50)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .safeAreaInset(edge: .bottom) {
            tabBar(s: s)
        }
        .sheet(isPresented: $crisisOpen) {
            CrisisSheet(store: store, s: s, onClose: { crisisOpen = false }, goTo: { tab = $0 })
        }
    }

    @ViewBuilder
    private func tabBar(s: AppStrings) -> some View {
        let items: [(AppTab, String, String)] = [
            (.today, s.tabToday, "house.fill"),
            (.checkIn, s.tabCheckIn, "clipboard.fill"),
            (.counter, s.tabCounter, "medal.fill"),
            (.meetings, s.tabMeetings, "calendar"),
            (.resources, s.tabResources, "book.fill"),
            (.events, s.tabEvents, "megaphone.fill"),
        ]
        HStack(spacing: 0) {
            ForEach(items, id: \.0) { t, label, icon in
                Button { tab = t } label: {
                    VStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.system(size: 22))
                        Text(label).font(.caption2)
                    }
                    .foregroundColor(tab == t ? .deepTeal : .warmGray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(tab == t ? Color.deepTeal.opacity(0.12) : Color.clear)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white)
        .overlay(Divider(), alignment: .top)
    }
}
