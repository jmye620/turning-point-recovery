import Foundation
import SwiftUI

/// All personal data lives in UserDefaults on this phone only — mirrors the
/// web app's "saved on this phone only" privacy promise.
final class Store: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var language: String {
        didSet { defaults.set(language, forKey: "lang") }
    }
    @Published var cleanDate: Date? {
        didSet {
            if let d = cleanDate { defaults.set(dateKey(d), forKey: "clean_date") }
            else { defaults.removeObject(forKey: "clean_date") }
        }
    }

    init() {
        self.language = defaults.string(forKey: "lang") ?? "en"
        if let key = defaults.string(forKey: "clean_date") {
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.timeZone = zone
            self.cleanDate = f.date(from: key)
        } else { self.cleanDate = nil }
    }

    // MARK: - Check-ins

    func saveCheckIn(_ c: CheckIn) {
        var dates = Set(defaults.stringArray(forKey: "checkin_dates") ?? [])
        dates.insert(c.date)
        defaults.set(Array(dates), forKey: "checkin_dates")
        let value = "\(c.mood)|\(c.cravings)|\(c.hasCall ? 1 : 0)|\(c.time)|\(c.gratitude.replacingOccurrences(of: "|", with: " "))"
        defaults.set(value, forKey: "checkin_\(c.date)")
        objectWillChange.send()
    }

    func checkInDates() -> [String] {
        (defaults.stringArray(forKey: "checkin_dates") ?? []).sorted(by: >)
    }

    func getCheckIn(date: Date) -> CheckIn? {
        let key = dateKey(date)
        guard let raw = defaults.string(forKey: "checkin_\(key)") else { return nil }
        let parts = raw.split(separator: "|", maxSplits: 4, omittingEmptySubsequences: false).map(String.init)
        guard parts.count == 5, let mood = Int(parts[0]), let cravings = Int(parts[1]) else { return nil }
        return CheckIn(date: key, mood: mood, cravings: cravings,
                       gratitude: parts[4], hasCall: parts[2] == "1", time: parts[3])
    }

    /// Consecutive-day streak ending today (or yesterday if today isn't done yet).
    func streak(today: Date = Date()) -> Int {
        let dates = Set(checkInDates())
        guard !dates.isEmpty else { return 0 }
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"; fmt.timeZone = zone
        var cursor = dates.contains(dateKey(today)) ? today
            : chicagoCalendar.date(byAdding: .day, value: -1, to: today)!
        var n = 0
        while dates.contains(dateKey(cursor)) {
            n += 1
            cursor = chicagoCalendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        return n
    }

    // MARK: - Journal

    func saveJournal(text: String) {
        let id = Int64(Date().timeIntervalSince1970 * 1000)
        defaults.set("\(Date().timeIntervalSince1970)|\(text)", forKey: "journal_\(id)")
        var ids = Set(defaults.stringArray(forKey: "journal_ids") ?? [])
        ids.insert("\(id)")
        defaults.set(Array(ids), forKey: "journal_ids")
        objectWillChange.send()
    }

    func journalEntries() -> [JournalEntry] {
        (defaults.stringArray(forKey: "journal_ids") ?? []).compactMap { id in
            guard let raw = defaults.string(forKey: "journal_\(id)"),
                  let idNum = Int64(id) else { return nil }
            let parts = raw.split(separator: "|", maxSplits: 1).map(String.init)
            guard parts.count == 2, let ts = Double(parts[0]) else { return nil }
            return JournalEntry(id: idNum, dateTime: Date(timeIntervalSince1970: ts), text: parts[1])
        }.sorted { $0.dateTime > $1.dateTime }
    }

    func deleteJournal(id: Int64) {
        defaults.removeObject(forKey: "journal_\(id)")
        var ids = Set(defaults.stringArray(forKey: "journal_ids") ?? [])
        ids.remove("\(id)")
        defaults.set(Array(ids), forKey: "journal_ids")
        objectWillChange.send()
    }

    // MARK: - Support contacts

    func addContact(name: String, phone: String) {
        var list = contacts()
        list.append(SupportContact(name: name, phone: phone))
        persistContacts(list)
    }

    func contacts() -> [SupportContact] {
        let raw = defaults.string(forKey: "contacts") ?? ""
        guard !raw.isEmpty else { return [] }
        return raw.components(separatedBy: ";;").compactMap {
            let p = $0.components(separatedBy: "||")
            guard p.count == 2, !p[0].isEmpty else { return nil }
            return SupportContact(name: p[0], phone: p[1])
        }
    }

    func removeContact(_ c: SupportContact) {
        persistContacts(contacts().filter { $0 != c })
    }

    private func persistContacts(_ list: [SupportContact]) {
        defaults.set(list.map { "\($0.name)||\($0.phone)" }.joined(separator: ";;"), forKey: "contacts")
        objectWillChange.send()
    }

    // MARK: - Quotes

    func quoteIndex() -> Int { defaults.integer(forKey: "quote_idx") }
    func nextQuote(total: Int) { defaults.set((quoteIndex() + 1) % total, forKey: "quote_idx") }

    // MARK: - Nuclear option

    func deleteEverything() {
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }
        language = "en"
        cleanDate = nil
        objectWillChange.send()
    }
}
