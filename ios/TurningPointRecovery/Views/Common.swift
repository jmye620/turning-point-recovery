import SwiftUI
import UIKit

// MARK: - Shared components

struct RecoveryCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.softBorder, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.04), radius: 2, y: 1)
    }
}

struct SectionTitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.titleLargeRecovery)
            .foregroundColor(.ink)
            .padding(.bottom, 10)
    }
}

struct PillButton: View {
    let text: String
    let primary: Bool
    let action: () -> Void
    init(_ text: String, primary: Bool = true, action: @escaping () -> Void) {
        self.text = text; self.primary = primary; self.action = action
    }
    var body: some View {
        Button(action: action) {
            Text(text)
                .fontWeight(.semibold)
                .foregroundColor(primary ? .white : .deepTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(primary ? Color.deepTeal : Color.white)
                .cornerRadius(50)
                .overlay(
                    primary ? nil :
                        RoundedRectangle(cornerRadius: 50).stroke(Color.deepTeal, lineWidth: 1.5)
                )
        }
    }
}

struct CallRow: View {
    let label: String
    let prettyNumber: String
    let digits: String
    let note: String?
    init(label: String, prettyNumber: String, digits: String, note: String? = nil) {
        self.label = label; self.prettyNumber = prettyNumber; self.digits = digits; self.note = note
    }
    var body: some View {
        Button { dial(digits) } label: {
            HStack(spacing: 10) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.deepTeal)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.headline).foregroundColor(.deepTeal)
                    Text(prettyNumber).font(.body).fontWeight(.bold).foregroundColor(.ink)
                    if let note = note {
                        Text(note).font(.subheadline).foregroundColor(.warmGray)
                    }
                }
                Spacer()
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.softBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Phone / SMS helpers

func dial(_ digits: String) {
    if let url = URL(string: "tel://\(digits)"),
       UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}

func textTo(_ digits: String) {
    if let url = URL(string: "sms:\(digits)"),
       UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}

func openURL(_ string: String) {
    if let url = URL(string: string), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}

// MARK: - Footer

struct DeleteAllSection: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let onDeleted: () -> Void
    @State private var confirm = false

    var body: some View {
        Button(s.deleteEverything) { confirm = true }
            .foregroundColor(.danger)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .alert(s.deleteConfirmTitle, isPresented: $confirm) {
                Button(s.deleteConfirmYes, role: .destructive) {
                    store.deleteEverything()
                    onDeleted()
                }
                Button(s.cancel, role: .cancel) {}
            } message: {
                Text(s.deleteConfirmBody)
            }
    }
}

struct Footer: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let onDeleted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(s.needHelpNow).font(.headline).foregroundColor(.deepTeal)
            HStack(spacing: 8) {
                Button { dial(CRISIS_LINE) } label: {
                    Text(CRISIS_LINE_PRETTY).fontWeight(.bold)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.softBorder))
                }.buttonStyle(.plain)
                Button { dial("988") } label: {
                    Text("988").fontWeight(.bold)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.softBorder))
                }.buttonStyle(.plain)
            }
            .padding(.vertical, 4)
            Text(s.privacyNote).font(.subheadline).foregroundColor(.warmGray)
            Text(s.programOf).font(.caption).foregroundColor(.warmGray)
            DeleteAllSection(store: store, s: s, onDeleted: onDeleted)
        }
        .padding(.top, 18)
        .padding(.bottom, 8)
    }
}
