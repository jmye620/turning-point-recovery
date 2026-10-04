package com.turningpoint.recoveryapp

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.time.LocalDate
import java.time.LocalTime

@Composable
fun CheckInScreen(store: Store, s: AppStrings, lang: String, goTo: (Tab) -> Unit, openCrisis: () -> Unit) {
    val ctx = LocalContext.current
    val today = remember { LocalDate.now(ZONE) }
    var submitted by remember { mutableStateOf(store.getCheckIn(today) != null) }
    var refresh by remember { mutableIntStateOf(0) }

    Column(Modifier.fillMaxWidth()) {
        SectionTitle(s.checkInTitle)
        Text(s.checkInSubtitle, style = MaterialTheme.typography.bodyLarge, color = WarmGray)
        Spacer(Modifier.height(14.dp))

        if (!submitted) {
            CheckInForm(s) { mood, cravings, gratitude, hasCall ->
                store.saveCheckIn(CheckIn(today, mood, cravings, gratitude, hasCall, LocalTime.now(ZONE)))
                submitted = true
                refresh++
            }
        } else {
            val c = store.getCheckIn(today)
            if (c != null) {
                RecoveryCard {
                    Text("💛", fontSize = 32.sp)
                    Spacer(Modifier.height(6.dp))
                    Text(s.checkInDoneTitle, style = MaterialTheme.typography.titleLarge)
                    Text(s.checkInDoneBody, style = MaterialTheme.typography.bodyLarge, color = WarmGray)
                    Spacer(Modifier.height(10.dp))
                    val moods = listOf(s.moodGreat, s.moodGood, s.moodOkay, s.moodLow, s.moodStruggling)
                    val cravs = listOf(s.cravingsNone, s.cravingsMild, s.cravingsStrong)
                    Text("${s.feeling}: ${moods[c.mood]} · ${s.cravings}: ${cravs[c.cravings]}",
                        style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                    if (c.gratitude.isNotBlank())
                        Text("“${c.gratitude}”", style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.Medium)
                    Spacer(Modifier.height(12.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        TextButton(onClick = { goTo(Tab.Resources) }) { Text(s.tryBoxBreathing, color = DeepTeal, fontWeight = FontWeight.Bold) }
                        TextButton(onClick = { goTo(Tab.Meetings) }) { Text(s.seeTodaysMeetings, color = DeepTeal, fontWeight = FontWeight.Bold) }
                    }
                }
            }
        }

        Spacer(Modifier.height(16.dp))
        SectionTitle(s.recentCheckIns)
        val streak = store.streak(today)
        RecoveryCard {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("🔥", fontSize = 28.sp)
                Column(Modifier.padding(start = 10.dp)) {
                    Text(
                        "$streak ${if (streak == 1) s.dayStreak else s.daysStreak}",
                        style = MaterialTheme.typography.titleLarge,
                    )
                    Text("Check-in streak", style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                }
            }
            Spacer(Modifier.height(8.dp))
            store.checkInDates().mapNotNull { runCatching { LocalDate.parse(it) }.getOrNull() }
                .sortedDescending().take(5).forEach { d ->
                    val c = store.getCheckIn(d)
                    if (c != null) {
                        val moods = listOf(s.moodGreat, s.moodGood, s.moodOkay, s.moodLow, s.moodStruggling)
                        val cravs = listOf(s.cravingsNone, s.cravingsMild, s.cravingsStrong)
                        Text(
                            "${formatFullDate(d, lang)} · ${moods[c.mood]} · ${s.cravings}: ${cravs[c.cravings]}",
                            style = MaterialTheme.typography.bodyMedium, color = WarmGray,
                            modifier = Modifier.padding(vertical = 3.dp),
                        )
                    }
                }
            if (refresh < 0) Spacer(Modifier.height(1.dp)) // keep recompose dep
        }

        Spacer(Modifier.height(16.dp))
        SectionTitle(s.journalTitle)
        var journalText by remember { mutableStateOf("") }
        var journalRefresh by remember { mutableIntStateOf(0) }
        RecoveryCard {
            OutlinedTextField(
                value = journalText, onValueChange = { journalText = it },
                placeholder = { Text(s.journalHint) },
                modifier = Modifier.fillMaxWidth().height(110.dp),
                shape = RoundedCornerShape(14.dp),
            )
            Spacer(Modifier.height(10.dp))
            Button(
                onClick = {
                    if (journalText.isNotBlank()) {
                        store.saveJournal(journalText.trim())
                        journalText = ""
                        journalRefresh++
                    }
                },
                shape = RoundedCornerShape(50),
                colors = ButtonDefaults.buttonColors(containerColor = DeepTeal),
            ) { Text(s.saveEntry) }
            if (journalRefresh >= 0) {
                Spacer(Modifier.height(10.dp))
                store.journalEntries().take(10).forEach { e ->
                    Row(Modifier.fillMaxWidth().padding(vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
                        Column(Modifier.weight(1f)) {
                            Text(formatShortDateTime(e.dateTime, lang), style = MaterialTheme.typography.labelSmall, color = WarmGray)
                            Text(e.text, style = MaterialTheme.typography.bodyMedium)
                        }
                        TextButton(onClick = { store.deleteJournal(e.id); journalRefresh++ }) {
                            Text(s.delete, color = Danger)
                        }
                    }
                }
            }
        }

        Spacer(Modifier.height(8.dp))
        Footer(store, s) { goTo(Tab.CheckIn) }
    }
}

@Composable
private fun CheckInForm(s: AppStrings, onDone: (mood: Int, cravings: Int, gratitude: String, hasCall: Boolean) -> Unit) {
    val ctx = LocalContext.current
    var mood by remember { mutableIntStateOf(-1) }
    var cravings by remember { mutableIntStateOf(-1) }
    var gratitude by remember { mutableStateOf("") }
    var hasCall by remember { mutableStateOf<Boolean?>(null) }

    val moodEmojis = listOf("😄", "🙂", "😐", "😟", "😞")
    val moodLabels = listOf(s.moodGreat, s.moodGood, s.moodOkay, s.moodLow, s.moodStruggling)
    val cravLabels = listOf(s.cravingsNone, s.cravingsMild, s.cravingsStrong)

    RecoveryCard {
        Text(s.moodLabel, style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
            moodEmojis.forEachIndexed { i, e ->
                Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.clickable { mood = i }.padding(4.dp)) {
                    Surface(
                        shape = RoundedCornerShape(50),
                        color = if (mood == i) DeepTeal.copy(alpha = 0.15f) else CardWhite,
                        border = BorderStroke(1.5.dp, if (mood == i) DeepTeal else SoftBorder),
                    ) { Text(e, fontSize = 26.sp, modifier = Modifier.padding(10.dp)) }
                    Text(moodLabels[i], style = MaterialTheme.typography.labelSmall, color = WarmGray)
                }
            }
        }
        Spacer(Modifier.height(14.dp))
        Text(s.cravingsLabel, style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            cravLabels.forEachIndexed { i, label ->
                val selected = cravings == i
                Surface(
                    shape = RoundedCornerShape(50),
                    color = if (selected) DeepTeal else CardWhite,
                    border = BorderStroke(1.5.dp, DeepTeal),
                    modifier = Modifier.clickable { cravings = i },
                ) {
                    Text(label, Modifier.padding(horizontal = 16.dp, vertical = 9.dp),
                        color = if (selected) CardWhite else DeepTeal, fontWeight = FontWeight.SemiBold)
                }
            }
        }
        Spacer(Modifier.height(14.dp))
        Text(s.gratitudeLabel, style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        OutlinedTextField(
            value = gratitude, onValueChange = { gratitude = it },
            placeholder = { Text(s.gratitudeHint) },
            modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(14.dp),
        )
        Spacer(Modifier.height(14.dp))
        Text(s.callSomeoneLabel, style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf(true to s.yes, false to s.no).forEach { (v, label) ->
                val selected = hasCall == v
                Surface(
                    shape = RoundedCornerShape(50),
                    color = if (selected) DeepTeal else CardWhite,
                    border = BorderStroke(1.5.dp, DeepTeal),
                    modifier = Modifier.clickable { hasCall = v },
                ) {
                    Text(label, Modifier.padding(horizontal = 22.dp, vertical = 9.dp),
                        color = if (selected) CardWhite else DeepTeal, fontWeight = FontWeight.SemiBold)
                }
            }
        }
        Spacer(Modifier.height(16.dp))
        PillButton(
            s.completeCheckIn,
            modifier = Modifier.fillMaxWidth(),
            onClick = {
                if (mood < 0 || cravings < 0 || hasCall == null) {
                    toast(ctx, s.completeAllFields)
                } else onDone(mood, cravings, gratitude.trim(), hasCall == true)
            },
        )
    }
}
