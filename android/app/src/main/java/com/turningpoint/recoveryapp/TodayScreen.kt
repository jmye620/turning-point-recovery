package com.turningpoint.recoveryapp

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Assignment
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.Spa
import androidx.compose.material.icons.filled.VolunteerActivism
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import java.time.LocalDate
import java.time.LocalDateTime

@Composable
fun TodayScreen(
    store: Store, s: AppStrings, lang: String,
    goTo: (Tab) -> Unit, openCrisis: () -> Unit,
) {
    val now = remember { LocalDateTime.now(ZONE) }
    var qi by remember { mutableStateOf(store.quoteIndex()) }
    val quote = QUOTES[qi % QUOTES.size]
    val nextMeeting = nextUpcomingMeeting(now, lang)

    Column(Modifier.fillMaxWidth()) {
        Text(
            "${greeting(now, s)},",
            style = MaterialTheme.typography.displaySmall,
        )
        Text(
            formatFullDate(LocalDate.now(ZONE), lang),
            style = MaterialTheme.typography.bodyLarge, color = WarmGray,
        )
        val status = openStatus(now, s)
        Spacer(Modifier.height(6.dp))
        if (status != null) {
            Surface(shape = RoundedCornerShape(50), color = DeepTeal.copy(alpha = 0.12f)) {
                Text(status, Modifier.padding(horizontal = 14.dp, vertical = 7.dp),
                    style = MaterialTheme.typography.labelLarge, color = DeepTeal, fontWeight = FontWeight.Bold)
            }
        } else {
            Surface(shape = RoundedCornerShape(50), color = WarmGray.copy(alpha = 0.15f)) {
                Text(s.closedNow, Modifier.padding(horizontal = 14.dp, vertical = 7.dp),
                    style = MaterialTheme.typography.labelLarge, color = WarmGray, fontWeight = FontWeight.Bold)
            }
        }

        Spacer(Modifier.height(16.dp))
        // Event banner
        RecoveryCard {
            Text("🎃", style = MaterialTheme.typography.displaySmall)
            Spacer(Modifier.height(4.dp))
            Text(s.halloweenTitle, style = MaterialTheme.typography.titleLarge)
            Text(s.halloweenWhen, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Text(s.halloweenWhere, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Spacer(Modifier.height(8.dp))
            TextButton(onClick = { goTo(Tab.Events) }) {
                Text(s.seeAllEvents, color = DeepTeal, fontWeight = FontWeight.Bold)
            }
        }

        Spacer(Modifier.height(16.dp))
        SectionTitle(s.todaysInspiration)
        RecoveryCard {
            Text(
                "“${if (lang == "es") quote.textEs else quote.textEn}”",
                style = MaterialTheme.typography.titleMedium,
            )
            Spacer(Modifier.height(4.dp))
            Text("— Recovery wisdom", style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Spacer(Modifier.height(8.dp))
            TextButton(onClick = { qi = (qi + 1) % QUOTES.size; store.nextQuote(QUOTES.size) }) {
                Text(s.anotherOne, color = DeepTeal, fontWeight = FontWeight.Bold)
            }
        }

        Spacer(Modifier.height(16.dp))
        SectionTitle(s.nextMeeting)
        if (nextMeeting != null) {
            val (meeting, dayLabel) = nextMeeting
            RecoveryCard {
                Text(meeting.time, style = MaterialTheme.typography.labelLarge, color = HelpOrange, fontWeight = FontWeight.Bold)
                Text(if (lang == "es") meeting.nameEs else meeting.nameEn, style = MaterialTheme.typography.titleLarge)
                Text(if (lang == "es") meeting.descEs else meeting.descEn, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                Text("${s.atTheCenter} · 415 Broadway, Paducah", style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                if (dayLabel != null) Text(dayLabel, style = MaterialTheme.typography.labelSmall, color = WarmGray)
                Spacer(Modifier.height(6.dp))
                TextButton(onClick = { goTo(Tab.Meetings) }) {
                    Text(s.seeFullSchedule + " →", color = DeepTeal, fontWeight = FontWeight.Bold)
                }
            }
        }

        Spacer(Modifier.height(16.dp))
        SectionTitle(s.whatDoYouNeed)
        val shortcuts = listOf(
            Quad(s.shortcutCheckIn, s.shortcutCheckInSub, Icons.Filled.Assignment) { goTo(Tab.CheckIn) },
            Quad(s.shortcutCounter, s.shortcutCounterSub, Icons.Filled.EmojiEvents) { goTo(Tab.Counter) },
            Quad(s.shortcutCoping, s.shortcutCopingSub, Icons.Filled.Spa) { goTo(Tab.Resources) },
            Quad(s.shortcutHelp, s.shortcutHelpSub, Icons.Filled.VolunteerActivism) { openCrisis() },
        )
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            shortcuts.chunked(2).forEach { row ->
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    row.forEach { q ->
                        RecoveryCard(Modifier.weight(1f).clickable(onClick = q.onClick)) {
                            Icon(q.icon, contentDescription = null, tint = DeepTeal, modifier = Modifier.size(28.dp))
                            Spacer(Modifier.height(8.dp))
                            Text(q.title, style = MaterialTheme.typography.titleMedium)
                            Text(q.sub, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                        }
                    }
                    if (row.size == 1) Spacer(Modifier.weight(1f))
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        Footer(store, s) { goTo(Tab.Today) }
    }
}

private data class Quad(val title: String, val sub: String, val icon: ImageVector, val onClick: () -> Unit)

/** Finds the next meeting today or later this week. Returns meeting + optional day note. */
private fun nextUpcomingMeeting(now: LocalDateTime, lang: String): Pair<Meeting, String?>? {
    for (offset in 0..6) {
        val date = now.toLocalDate().plusDays(offset.toLong())
        val meetings = WEEKLY_MEETINGS[date.dayOfWeek] ?: continue
        val upcoming = meetings.filter {
            offset > 0 || it.hour24 * 60 + it.minute > now.hour * 60 + now.minute
        }
        if (upcoming.isNotEmpty()) {
            val label = if (offset == 0) null else date.dayOfWeek
                .getDisplayName(java.time.format.TextStyle.FULL, localeFor(lang))
                .replaceFirstChar { it.uppercase() }
            return upcoming.first() to label
        }
    }
    return null
}
