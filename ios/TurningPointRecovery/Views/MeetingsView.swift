import SwiftUI
import EventKit

struct MeetingsView: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let lang: String
    let goTo: (AppTab) -> Void

    private let today = Date()
    @State private var calendarMessage: String? = nil

    /// Monday(2) … Saturday(7), mirroring the Android order.
    private let order = [2, 3, 4, 5, 6, 7]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: s.meetingsTitle)
            Text(s.meetingsSub).font(.body).foregroundColor(.warmGray)
            Text(s.freeNoSignup).font(.subheadline).fontWeight(.semibold).foregroundColor(.warmGray)
                .padding(.top, 2)
            Button(action: {
                if let url = URL(string: "tel:2704443621") { UIApplication.shared.open(url) }
            }) {
                Text(s.centerPhoneLabel).fontWeight(.bold).foregroundColor(.deepTeal)
            }
            .padding(.top, 2)
            .padding(.bottom, 14)

            let todayWeekday = chicagoCalendar.component(.weekday, from: today)

            ForEach(order, id: \.self) { weekday in
                let dayDate = nearestDate(for: weekday)
                HStack(spacing: 8) {
                    Text(weekdayName(dayDate, lang: lang))
                        .font(.titleLargeRecovery)
                    if weekday == todayWeekday {
                        Text(s.todayBadge)
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                            .padding(.horizontal, 12).padding(.vertical, 4)
                            .background(Color.deepTeal).cornerRadius(50)
                    }
                }
                .padding(.vertical, 6)

                if let meetings = WEEKLY_MEETINGS[weekday] {
                    ForEach(meetings, id: \.nameEn) { m in
                        RecoveryCard {
                            Text(m.time)
                                .font(.subheadline).fontWeight(.bold).foregroundColor(.helpOrange)
                            Text(lang == "es" ? m.nameEs : m.nameEn).font(.headline)
                            Text(lang == "es" ? m.descEs : m.descEn)
                                .font(.subheadline).foregroundColor(.warmGray)
                            Button {
                                addToCalendar(meeting: m, on: dayDate)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar.badge.plus")
                                    Text(s.addToCalendar).fontWeight(.bold)
                                }
                                .foregroundColor(.deepTeal)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.bottom, 10)
                    }
                } else {
                    RecoveryCard {
                        Text("🌿").font(.title)
                        Text(s.noMeetingsSaturday).font(.subheadline).foregroundColor(.warmGray)
                            .padding(.top, 4)
                    }
                }
                Spacer(minLength: 8)
            }

            if let msg = calendarMessage {
                Text(msg).font(.subheadline).foregroundColor(.deepTeal)
                    .padding(.vertical, 6)
            }

            RecoveryCard {
                Text("📦").font(.title)
                Text(s.takeBackDayTitle).font(.headline).padding(.top, 4)
                Text(s.takeBackDayWhen).font(.subheadline).foregroundColor(.warmGray)
                Text(s.takeBackDayWhere).font(.subheadline).foregroundColor(.warmGray)
                Text(s.takeBackDayBody).font(.body).padding(.top, 6)
            }
            .padding(.top, 12)

            Text(s.schedulesChangeNote).font(.subheadline).foregroundColor(.warmGray)
                .padding(.top, 12)

            Footer(store: store, s: s) { goTo(.meetings) }
        }
    }

    private func nearestDate(for weekday: Int) -> Date {
        let todayWeekday = chicagoCalendar.component(.weekday, from: today)
        let daysAhead = (weekday - todayWeekday + 7) % 7
        return chicagoCalendar.date(byAdding: .day, value: daysAhead, to: today)!
    }

    private func addToCalendar(meeting: Meeting, on date: Date) {
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToEvents { granted, _ in
            DispatchQueue.main.async {
                guard granted else { return }
                var comps = chicagoCalendar.dateComponents([.year, .month, .day], from: date)
                comps.hour = meeting.hour24; comps.minute = meeting.minute
                guard let start = chicagoCalendar.date(from: comps) else { return }
                let event = EKEvent(eventStore: eventStore)
                event.title = lang == "es" ? meeting.nameEs : meeting.nameEn
                event.location = "Turning Point, 415 Broadway, Paducah, KY"
                event.notes = lang == "es" ? meeting.descEs : meeting.descEn
                event.startDate = start
                event.endDate = start.addingTimeInterval(3600)
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                    calendarMessage = "✓ \(event.title ?? "")"
                } catch {
                    calendarMessage = nil
                }
            }
        }
    }
}
