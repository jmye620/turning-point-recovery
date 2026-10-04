package com.turningpoint.recoveryapp

import android.content.Intent
import android.provider.CalendarContract
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId

@Composable
fun MeetingsScreen(store: Store, s: AppStrings, lang: String, goTo: (Tab) -> Unit) {
    val ctx = LocalContext.current
    val today = remember { LocalDate.now(ZONE) }
    val order = listOf(
        DayOfWeek.MONDAY, DayOfWeek.TUESDAY, DayOfWeek.WEDNESDAY,
        DayOfWeek.THURSDAY, DayOfWeek.FRIDAY, DayOfWeek.SATURDAY,
    )

    Column(Modifier.fillMaxWidth()) {
        SectionTitle(s.meetingsTitle)
        Text(s.meetingsSub, style = MaterialTheme.typography.bodyLarge, color = WarmGray)
        Text(s.freeNoSignup, style = MaterialTheme.typography.bodyMedium, color = WarmGray, fontWeight = FontWeight.SemiBold)
        TextButton(onClick = { dial(ctx, "2704443621") }, modifier = Modifier.padding(vertical = 2.dp)) {
            Text(s.centerPhoneLabel, color = DeepTeal, fontWeight = FontWeight.Bold)
        }
        Spacer(Modifier.height(14.dp))

        order.forEach { dow ->
            val isToday = dow == today.dayOfWeek
            val dayName = dow.getDisplayName(java.time.format.TextStyle.FULL, localeFor(lang))
                .replaceFirstChar { it.uppercase() }
            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(vertical = 6.dp)) {
                Text(dayName, style = MaterialTheme.typography.titleLarge)
                if (isToday) {
                    Spacer(Modifier.width(8.dp))
                    Surface(shape = RoundedCornerShape(50), color = DeepTeal) {
                        Text(s.todayBadge, Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                            style = MaterialTheme.typography.labelLarge, color = CardWhite, fontWeight = FontWeight.Bold)
                    }
                }
            }
            val meetings = WEEKLY_MEETINGS[dow]
            if (meetings == null) {
                RecoveryCard {
                    Text("🌿", style = MaterialTheme.typography.titleLarge)
                    Spacer(Modifier.height(4.dp))
                    Text(s.noMeetingsSaturday, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                }
            } else {
                meetings.forEach { m ->
                    RecoveryCard(Modifier.padding(bottom = 10.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Column(Modifier.weight(1f)) {
                                Text(m.time, style = MaterialTheme.typography.labelLarge, color = HelpOrange, fontWeight = FontWeight.Bold)
                                Text(if (lang == "es") m.nameEs else m.nameEn, style = MaterialTheme.typography.titleMedium)
                                Text(if (lang == "es") m.descEs else m.descEn,
                                    style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                            }
                        }
                        Spacer(Modifier.height(8.dp))
                        TextButton(onClick = {
                            val intent = Intent(Intent.ACTION_INSERT).apply {
                                data = CalendarContract.Events.CONTENT_URI
                                putExtra(CalendarContract.Events.TITLE, if (lang == "es") m.nameEs else m.nameEn)
                                putExtra(CalendarContract.Events.EVENT_LOCATION, "Turning Point, 415 Broadway, Paducah, KY")
                                putExtra(CalendarContract.Events.DESCRIPTION, if (lang == "es") m.descEs else m.descEn)
                                val daysAhead = (dow.value - today.dayOfWeek.value + 7) % 7
                                val meetingDate = today.plusDays(daysAhead.toLong())
                                val start = LocalDateTime.of(meetingDate, java.time.LocalTime.of(m.hour24, m.minute))
                                    .atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                                putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, start)
                                putExtra(CalendarContract.EXTRA_EVENT_END_TIME, start + 60 * 60 * 1000)
                            }
                            runCatching { ctx.startActivity(intent) }
                        }) {
                            Icon(Icons.Filled.CalendarMonth, contentDescription = null, tint = DeepTeal)
                            Spacer(Modifier.width(6.dp))
                            Text(s.addToCalendar, color = DeepTeal, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }
            Spacer(Modifier.height(8.dp))
        }

        RecoveryCard {
            Text("📦", style = MaterialTheme.typography.titleLarge)
            Spacer(Modifier.height(4.dp))
            Text(s.takeBackDayTitle, style = MaterialTheme.typography.titleMedium)
            Text(s.takeBackDayWhen, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Text(s.takeBackDayWhere, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Text(s.takeBackDayBody, style = MaterialTheme.typography.bodyMedium)
        }
        Spacer(Modifier.height(12.dp))
        Text(s.schedulesChangeNote, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
        Spacer(Modifier.height(8.dp))
        Footer(store, s) { goTo(Tab.Meetings) }
    }
}
