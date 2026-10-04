import SwiftUI

struct EventsView: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let goTo: (AppTab) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: s.eventsTitle)
            Text(s.eventsSubtitle).font(.body).foregroundColor(.warmGray)
                .padding(.bottom, 14)

            RecoveryCard {
                Text("🎃").font(.largeTitle)
                Text(s.halloweenTitle).font(.titleLargeRecovery).padding(.top, 6)
                Text(s.halloweenWhen).font(.subheadline).foregroundColor(.warmGray)
                Text(s.halloweenWhere).font(.subheadline).foregroundColor(.warmGray)
                Text(s.halloweenBody).font(.body).padding(.top, 6)
            }

            RecoveryCard {
                Text("📦").font(.largeTitle)
                Text(s.takeBackDayTitle).font(.titleLargeRecovery).padding(.top, 6)
                Text(s.takeBackDayWhen).font(.subheadline).foregroundColor(.warmGray)
                Text(s.takeBackDayWhere).font(.subheadline).foregroundColor(.warmGray)
                Text(s.takeBackDayBody).font(.body).padding(.top, 6)
            }
            .padding(.top, 12)

            Footer(store: store, s: s) { goTo(.events) }
        }
    }
}
