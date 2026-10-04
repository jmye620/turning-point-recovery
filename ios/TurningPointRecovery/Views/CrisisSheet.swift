import SwiftUI

struct CrisisSheet: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let onClose: () -> Void
    let goTo: (AppTab) -> Void

    @State private var showNow = false
    @State private var name = ""
    @State private var phone = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(s.crisisTitle).font(.headlineRecovery).padding(.bottom, 4)
                    Text(s.crisisSubtitle).font(.body).foregroundColor(.warmGray)

                    Button(action: { showNow.toggle() }) {
                        Text(s.crisisCallNow).fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.helpOrange).cornerRadius(50)
                    }
                    .padding(.top, 14)

                    if showNow {
                        RecoveryCard {
                            VStack(spacing: 8) {
                                CallRow(label: s.crisisCallLine, prettyNumber: CRISIS_LINE_PRETTY, digits: CRISIS_LINE)
                                HStack(spacing: 8) {
                                    Button { dial("988") } label: {
                                        Text(s.crisisCall988).fontWeight(.bold).foregroundColor(.white)
                                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                                            .background(Color.deepTeal).cornerRadius(50)
                                    }
                                    Button { textTo("988") } label: {
                                        Text(s.crisisText988).fontWeight(.bold).foregroundColor(.white)
                                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                                            .background(Color.deepTeal).cornerRadius(50)
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)
                    }

                    Group {
                        CallRow(label: "24-hour crisis line", prettyNumber: CRISIS_LINE_PRETTY, digits: CRISIS_LINE)
                        CallRow(label: "988 Suicide & Crisis Lifeline", prettyNumber: "988", digits: "988", note: "free, confidential, 24/7")
                        CallRow(label: s.crisisCenter, prettyNumber: CENTER_PHONE_PRETTY, digits: CENTER_PHONE, note: s.crisisCenterHours)
                        CallRow(label: s.crisis911, prettyNumber: "911", digits: "911", note: s.crisis911Note)
                    }
                    .padding(.top, 8)

                    RecoveryCard {
                        Text(s.crisisWhat988).font(.headline)
                        Text(s.crisisWhat988Body).font(.subheadline).foregroundColor(.warmGray)
                            .padding(.top, 4)
                    }
                    .padding(.top, 14)

                    RecoveryCard {
                        Text(s.crisisWorried).font(.headline)
                        Text(s.crisisWorriedBody).font(.subheadline).foregroundColor(.warmGray)
                            .padding(.top, 4)
                    }
                    .padding(.top, 10)

                    PillButton(s.crisisTryBreathing) { onClose(); goTo(.resources) }
                        .padding(.top, 10)

                    Text(s.supportContacts).font(.titleLargeRecovery).padding(.top, 16).padding(.bottom, 8)

                    ForEach(store.contacts(), id: \.phone) { c in
                        RecoveryCard {
                            Text(c.name).font(.headline)
                            Text(c.phone).font(.subheadline).foregroundColor(.warmGray)
                            HStack(spacing: 8) {
                                Button { dial(c.phone) } label: {
                                    Text(s.call).fontWeight(.bold).foregroundColor(.white)
                                        .padding(.horizontal, 18).padding(.vertical, 8)
                                        .background(Color.deepTeal).cornerRadius(50)
                                }
                                Button { textTo(c.phone) } label: {
                                    Text(s.text).fontWeight(.bold).foregroundColor(.white)
                                        .padding(.horizontal, 18).padding(.vertical, 8)
                                        .background(Color.deepTeal).cornerRadius(50)
                                }
                                Button { store.removeContact(c) } label: {
                                    Text(s.remove).foregroundColor(.danger)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.bottom, 8)
                    }

                    RecoveryCard {
                        TextField(s.contactNameHint, text: $name)
                            .textFieldStyle(.roundedBorder)
                        TextField(s.contactPhoneHint, text: $phone)
                            .keyboardType(.phonePad)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 8)
                        Button {
                            if !name.trimmingCharacters(in: .whitespaces).isEmpty,
                               !phone.trimmingCharacters(in: .whitespaces).isEmpty {
                                store.addContact(name: name.trimmingCharacters(in: .whitespaces),
                                                 phone: phone.trimmingCharacters(in: .whitespaces))
                                name = ""; phone = ""
                            }
                        } label: {
                            Text(s.addContact).fontWeight(.bold).foregroundColor(.white)
                                .padding(.horizontal, 20).padding(.vertical, 10)
                                .background(Color.deepTeal).cornerRadius(50)
                        }
                        .padding(.top, 10)
                    }

                    Spacer(minLength: 24)
                }
                .padding(20)
            }
            .background(Color.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { onClose() } label: {
                        Image(systemName: "xmark").foregroundColor(.ink)
                    }
                }
            }
        }
    }
}
