import SwiftUI

/// The 12 Steps checklist — progress is saved on this phone only.
struct StepsView: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let lang: String
    let goTo: (AppTab) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: s.stepsTitle)
            Text(s.stepsSubtitle).font(.body).foregroundColor(.warmGray)
                .padding(.bottom, 6)
            let done = store.stepsDone()
            Text("\(done.count) / 12 \(s.stepsCompleted)")
                .font(.headline).fontWeight(.bold).foregroundColor(.deepTeal)
                .padding(.bottom, 14)

            ForEach(Array(TWELVE_STEPS.enumerated()), id: \.offset) { i, step in
                let n = i + 1
                let checked = done.contains(n)
                RecoveryCard {
                    Button { store.toggleStep(n) } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: checked ? "checkmark.square.fill" : "square")
                                .font(.system(size: 26))
                                .foregroundColor(checked ? .deepTeal : .warmGray)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(s.stepWord) \(n)")
                                    .font(.subheadline).fontWeight(.bold)
                                    .foregroundColor(.deepTeal)
                                Text(lang == "es" ? step.es : step.en)
                                    .font(.body).foregroundColor(.ink)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 8)
            }

            Footer(store: store, s: s) { goTo(.steps) }
        }
    }
}
