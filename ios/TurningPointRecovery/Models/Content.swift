import Foundation

let zone = TimeZone(identifier: "America/Chicago")!
let CENTER_PHONE = "2704443621"
let CRISIS_LINE = "8005923980"
let CENTER_PHONE_PRETTY = "270.444.3621"
let CRISIS_LINE_PRETTY = "800.592.3980"
let WEBSITE = "https://4rbh.org"

struct CheckIn: Codable {
    let date: String      // "yyyy-MM-dd"
    let mood: Int         // 0..4
    let cravings: Int     // 0..2
    let gratitude: String
    let hasCall: Bool
    let time: String      // "HH:mm"
}

struct JournalEntry: Codable, Identifiable {
    let id: Int64
    let dateTime: Date
    let text: String
}

struct SupportContact: Codable, Equatable {
    let name: String
    let phone: String
}

struct Quote { let en: String; let es: String }

let QUOTES: [Quote] = [
    Quote(en: "Yesterday you said tomorrow.", es: "Ayer dijiste mañana."),
    Quote(en: "Recovery is possible — and you're living proof.", es: "La recuperación es posible, y tú eres la prueba viviente."),
    Quote(en: "One day at a time.", es: "Un día a la vez."),
    Quote(en: "You don't have to be perfect to be worthy of recovery.", es: "No tienes que ser perfecto para merecer la recuperación."),
    Quote(en: "Courage is showing up, especially on the hard days.", es: "El valor es presentarse, especialmente en los días difíciles."),
    Quote(en: "Every sunrise is a second chance.", es: "Cada amanecer es una segunda oportunidad."),
    Quote(en: "Progress, not perfection.", es: "Progreso, no perfección."),
    Quote(en: "You survived every hard day so far. That's a perfect record.", es: "Sobreviviste cada día difícil hasta ahora. Ese es un récord perfecto."),
    Quote(en: "Ask for help. It's the bravest thing you'll do today.", es: "Pide ayuda. Es lo más valiente que harás hoy."),
    Quote(en: "Small steps every day lead somewhere beautiful.", es: "Pequeños pasos cada día llevan a un lugar hermoso."),
    Quote(en: "Your future self is cheering for you right now.", es: "Tu yo del futuro te está animando ahora mismo."),
    Quote(en: "Healing isn't linear, but it is happening.", es: "Sanar no es lineal, pero está sucediendo."),
]

struct Meeting { let nameEn: String; let nameEs: String; let descEn: String; let descEs: String; let time: String; let hour24: Int; let minute: Int }

/// 1 = Sunday … 7 = Saturday (Calendar weekday numbering)
let WEEKLY_MEETINGS: [Int: [Meeting]] = [
    2: [ // Monday
        Meeting(nameEn: "Morning Meditation", nameEs: "Meditación matutina", descEn: "Start the day grounded", descEs: "Comienza el día con calma", time: "8:00 AM", hour24: 8, minute: 0),
        Meeting(nameEn: "Narcotics Anonymous", nameEs: "Narcóticos Anónimos", descEn: "12-step fellowship", descEs: "Comunidad de 12 pasos", time: "12:00 PM", hour24: 12, minute: 0),
        Meeting(nameEn: "Alcoholics Anonymous", nameEs: "Alcohólicos Anónimos", descEn: "12-step fellowship", descEs: "Comunidad de 12 pasos", time: "4:00 PM", hour24: 16, minute: 0),
    ],
    3: [ // Tuesday
        Meeting(nameEn: "Morning Meditation", nameEs: "Meditación matutina", descEn: "Start the day grounded", descEs: "Comienza el día con calma", time: "8:00 AM", hour24: 8, minute: 0),
        Meeting(nameEn: "Medication Assisted Recovery Anonymous", nameEs: "Recuperación Anónima con Medicación", descEn: "For MAT journeys", descEs: "Para caminos con MAT", time: "12:00 PM", hour24: 12, minute: 0),
        Meeting(nameEn: "Narcotics Anonymous", nameEs: "Narcóticos Anónimos", descEn: "12-step fellowship", descEs: "Comunidad de 12 pasos", time: "6:00 PM", hour24: 18, minute: 0),
    ],
    4: [ // Wednesday
        Meeting(nameEn: "Morning Meditation", nameEs: "Meditación matutina", descEn: "Start the day grounded", descEs: "Comienza el día con calma", time: "8:00 AM", hour24: 8, minute: 0),
        Meeting(nameEn: "Narcotics Anonymous", nameEs: "Narcóticos Anónimos", descEn: "12-step fellowship", descEs: "Comunidad de 12 pasos", time: "12:00 PM", hour24: 12, minute: 0),
        Meeting(nameEn: "LGBTQ+ All Recovery", nameEs: "Recuperación LGBTQ+", descEn: "An affirming space", descEs: "Un espacio afirmativo", time: "4:00 PM", hour24: 16, minute: 0),
        Meeting(nameEn: "Young People in Recovery (YPR)", nameEs: "Jóvenes en Recuperación", descEn: "For young people in recovery", descEs: "Para jóvenes en recuperación", time: "8:00 PM", hour24: 20, minute: 0),
    ],
    5: [ // Thursday
        Meeting(nameEn: "Morning Meditation", nameEs: "Meditación matutina", descEn: "Start the day grounded", descEs: "Comienza el día con calma", time: "8:00 AM", hour24: 8, minute: 0),
        Meeting(nameEn: "SMART Recovery", nameEs: "SMART Recovery", descEn: "Science-based tools", descEs: "Herramientas basadas en ciencia", time: "12:00 PM", hour24: 12, minute: 0),
        Meeting(nameEn: "Narcotics Anonymous", nameEs: "Narcóticos Anónimos", descEn: "12-step fellowship", descEs: "Comunidad de 12 pasos", time: "6:00 PM", hour24: 18, minute: 0),
    ],
    6: [ // Friday
        Meeting(nameEn: "Morning Meditation", nameEs: "Meditación matutina", descEn: "Start the day grounded", descEs: "Comienza el día con calma", time: "8:00 AM", hour24: 8, minute: 0),
        Meeting(nameEn: "Narcotics Anonymous", nameEs: "Narcóticos Anónimos", descEn: "12-step fellowship", descEs: "Comunidad de 12 pasos", time: "12:00 PM", hour24: 12, minute: 0),
        Meeting(nameEn: "StrongHER Women's All-Recovery Group", nameEs: "StrongHER Mujeres en Recuperación", descEn: "Women's group", descEs: "Grupo de mujeres", time: "6:00 PM", hour24: 18, minute: 0),
    ],
]

struct Service { let en: String; let es: String }

let SERVICES: [Service] = [
    Service(en: "Recovery coaching & support", es: "Acompañamiento y apoyo en recuperación"),
    Service(en: "Resume & job searching", es: "Currículum y búsqueda de empleo"),
    Service(en: "Resources & referrals", es: "Recursos y referencias"),
    Service(en: "On-site computer lab", es: "Laboratorio de computación"),
    Service(en: "Veterans support", es: "Apoyo a veteranos"),
    Service(en: "Relapse refocus", es: "Reenfoque tras recaída"),
    Service(en: "Overdose response", es: "Respuesta a sobredosis"),
    Service(en: "Community outreach", es: "Alcance comunitario"),
    Service(en: "Telephone recovery support", es: "Apoyo telefónico en recuperación"),
    Service(en: "Speaking engagements", es: "Charlas y presentaciones"),
]

struct Milestone { let days: Int; let labelEn: String; let labelEs: String }

let MILESTONES: [Milestone] = [
    Milestone(days: 1, labelEn: "24 hours", labelEs: "24 horas"),
    Milestone(days: 30, labelEn: "30 days", labelEs: "30 días"),
    Milestone(days: 60, labelEn: "60 days", labelEs: "60 días"),
    Milestone(days: 90, labelEn: "90 days", labelEs: "90 días"),
    Milestone(days: 182, labelEn: "6 months", labelEs: "6 meses"),
    Milestone(days: 273, labelEn: "9 months", labelEs: "9 meses"),
    Milestone(days: 365, labelEn: "1 year", labelEs: "1 año"),
    Milestone(days: 547, labelEn: "18 months", labelEs: "18 meses"),
    Milestone(days: 730, labelEn: "2 years", labelEs: "2 años"),
    Milestone(days: 1095, labelEn: "3 years", labelEs: "3 años"),
    Milestone(days: 1460, labelEn: "4 years", labelEs: "4 años"),
    Milestone(days: 1825, labelEn: "5 years", labelEs: "5 años"),
]

// MARK: - Date helpers

var chicagoCalendar: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = zone
    return c
}()

func dateKey(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.timeZone = zone
    return f.string(from: date)
}

func fullDateString(_ date: Date, lang: String) -> String {
    let f = DateFormatter()
    f.dateStyle = .full
    f.timeStyle = .none
    f.locale = Locale(identifier: lang == "es" ? "es" : "en_US")
    f.timeZone = zone
    return f.string(from: date)
}

func shortDateTimeString(_ date: Date, lang: String) -> String {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    f.locale = Locale(identifier: lang == "es" ? "es" : "en_US")
    f.timeZone = zone
    return f.string(from: date)
}

func weekdayName(_ date: Date, lang: String) -> String {
    let f = DateFormatter()
    f.dateFormat = "EEEE"
    f.locale = Locale(identifier: lang == "es" ? "es" : "en_US")
    f.timeZone = zone
    return f.string(from: date).capitalized
}

func greeting(date: Date, s: AppStrings) -> String {
    let hour = chicagoCalendar.component(.hour, from: date)
    switch hour {
    case 5...11: return s.goodMorning
    case 12...17: return s.goodAfternoon
    default: return s.goodEvening
    }
}

/// Center hours: Mon/Wed/Fri 8a–5p, Tue/Thu 8a–7p, closed weekends.
func openStatus(date: Date = Date(), s: AppStrings) -> String? {
    let weekday = chicagoCalendar.component(.weekday, from: date) // 1=Sun
    if weekday == 1 || weekday == 7 { return nil }
    let close = (weekday == 3 || weekday == 5) ? 19 : 17
    let hour = chicagoCalendar.component(.hour, from: date)
    guard hour >= 8 && hour < close else { return nil }
    let t = close == 19 ? "7:00 PM" : "5:00 PM"
    return "\(s.openNowUntil) \(t)"
}

/// Finds the next meeting today or later this week. Returns meeting + optional day note.
func nextUpcomingMeeting(now: Date, lang: String) -> (Meeting, String?)? {
    let nowMinutes = chicagoCalendar.component(.hour, from: now) * 60
        + chicagoCalendar.component(.minute, from: now)
    for offset in 0..<7 {
        guard let date = chicagoCalendar.date(byAdding: .day, value: offset, to: now) else { continue }
        let weekday = chicagoCalendar.component(.weekday, from: date)
        guard let meetings = WEEKLY_MEETINGS[weekday] else { continue }
        let upcoming = meetings.filter { offset > 0 || ($0.hour24 * 60 + $0.minute) > nowMinutes }
        if let first = upcoming.first {
            let label: String? = offset == 0 ? nil : weekdayName(date, lang: lang)
            return (first, label)
        }
    }
    return nil
}

func milestoneBreakdown(days: Int, s: AppStrings) -> String {
    let years = days / 365
    let months = (days % 365) / 30
    let rest = (days % 365) % 30
    var parts: [String] = []
    if years > 0 { parts.append("\(years) \(years == 1 ? s.year : s.years)") }
    if months > 0 { parts.append("\(months) \(months == 1 ? s.month : s.months)") }
    if rest > 0 || parts.isEmpty {
        let dayWord = rest == 1 ? s.day : s.days
        parts.append("\(rest) \(dayWord)")
    }
    return parts.joined(separator: ", ")
}
