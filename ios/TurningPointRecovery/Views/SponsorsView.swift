import SwiftUI

/// Sponsors list — tap a name to call, all saved on this phone only.
struct SponsorsView: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let lang: String
    let goTo: (AppTab) -> Void

    @State private var name = ""
    @State private var phone = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: s.sponsorsTitle)
            Text(s.sponsorsSubtitle).font(.body).foregroundColor(.warmGray)
                .padding(.bottom, 14)

            let list = store.sponsors()
            if list.isEmpty {
                Text(s.noSponsors).font(.body).foregroundColor(.warmGray)
                    .padding(.bottom, 8)
            }
            ForEach(Array(list.enumerated()), id: \.offset) { _, sp in
                RecoveryCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sp.name).font(.headline).fontWeight(.bold).foregroundColor(.ink)
                                Text(sp.phone).font(.body).foregroundColor(.warmGray)
                            }
                            Spacer()
                            Button { dial(sp.phone) } label: {
                                Text("📞 \(s.call)").fontWeight(.semibold).foregroundColor(.deepTeal)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.deepTeal, lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)
                        }
                        HStack {
                            Spacer()
                            Button { store.removeSponsor(sp) } label: {
                                Text(s.remove).foregroundColor(.warmGray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 8)
            }

            RecoveryCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text(s.addContact).font(.headline).fontWeight(.bold).foregroundColor(.ink)
                    TextField(s.contactNameHint, text: $name)
                        .textFieldStyle(.roundedBorder)
                    TextField(s.contactPhoneHint, text: $phone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                    PillButton(s.addContact) {
                        let n = name.trimmingCharacters(in: .whitespaces)
                        let p = phone.trimmingCharacters(in: .whitespaces)
                        guard !n.isEmpty, !p.isEmpty else { return }
                        store.addSponsor(name: n, phone: p)
                        name = ""; phone = ""
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.top, 6)

            Footer(store: store, s: s) { goTo(.sponsors) }
        }
    }
}
