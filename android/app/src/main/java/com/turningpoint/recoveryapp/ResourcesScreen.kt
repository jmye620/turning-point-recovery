package com.turningpoint.recoveryapp

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.BorderStroke
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
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

@Composable
fun ResourcesScreen(store: Store, s: AppStrings, lang: String, goTo: (Tab) -> Unit) {
    Column(Modifier.fillMaxWidth()) {
        SectionTitle(s.copingTools)

        ToolCard("🫁", s.boxBreathing, s.boxBreathingBody) { BoxBreathingTool(s) }
        ToolCard("👁", s.grounding, s.groundingBody) { GroundingTool(s) }
        ToolCard("⏸", s.halt, s.haltBody) { HaltTool(s) }
        ToolCard("🌊", s.urgeSurfing, s.urgeSurfingBody) { UrgeSurfingTool(s) }
        ToolCard("📞", s.callSomeoneTitle, s.callSomeoneBody) {
            val ctx = LocalContext.current
            Spacer(Modifier.height(8.dp))
            Button(
                onClick = { dial(ctx, CENTER_PHONE) },
                shape = RoundedCornerShape(50),
                colors = ButtonDefaults.buttonColors(containerColor = DeepTeal),
            ) {
                Icon(Icons.Filled.Phone, contentDescription = null)
                Spacer(Modifier.width(8.dp))
                Text("${s.callTurningPoint}: $CENTER_PHONE_PRETTY")
            }
        }
        ToolCard("✍️", s.writeItOut, s.writeItOutBody) {
            var text by remember { mutableStateOf("") }
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = text, onValueChange = { text = it },
                placeholder = { Text(s.writeHint) },
                modifier = Modifier.fillMaxWidth().height(120.dp),
                shape = RoundedCornerShape(14.dp),
            )
            Spacer(Modifier.height(8.dp))
            OutlinedButton(onClick = { text = "" }, shape = RoundedCornerShape(50)) { Text(s.clearPage) }
        }

        Spacer(Modifier.height(18.dp))
        SectionTitle(s.freeServices)
        RecoveryCard {
            SERVICES.forEach { svc ->
                Row(Modifier.padding(vertical = 5.dp), verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.Check, contentDescription = null, tint = DeepTeal, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(10.dp))
                    Text(if (lang == "es") svc.es else svc.en, style = MaterialTheme.typography.bodyLarge)
                }
            }
            Spacer(Modifier.height(8.dp))
            Text(s.freeServicesNote, style = MaterialTheme.typography.bodyMedium, color = WarmGray, fontWeight = FontWeight.SemiBold)
        }

        Spacer(Modifier.height(16.dp))
        RecoveryCard {
            Text("🎙️", style = MaterialTheme.typography.titleLarge)
            Spacer(Modifier.height(4.dp))
            Text(s.podcastTitle, style = MaterialTheme.typography.titleMedium)
            Text(s.podcastBody, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
        }

        Spacer(Modifier.height(16.dp))
        SectionTitle(s.visitCenter)
        val ctx = LocalContext.current
        RecoveryCard {
            Text("TURNING POINT RECOVERY COMMUNITY CENTER",
                style = MaterialTheme.typography.titleMedium, color = DeepTeal, fontWeight = FontWeight.Bold)
            Text(s.visitAddress, style = MaterialTheme.typography.bodyLarge)
            Text(s.visitEnter, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Spacer(Modifier.height(10.dp))
            Text(s.hoursTitle, style = MaterialTheme.typography.titleMedium)
            Text(if (lang == "es") "Lun · Mié · Vie 8 a.m.–5 p.m.\nMar · Jue 8 a.m.–7 p.m."
                else "Mon · Wed · Fri 8 a.m.–5 p.m.\nTue · Thu 8 a.m.–7 p.m.",
                style = MaterialTheme.typography.bodyMedium)
            val status = openStatus(s = s)
            if (status != null) {
                Spacer(Modifier.height(6.dp))
                Text(status, style = MaterialTheme.typography.labelLarge, color = DeepTeal, fontWeight = FontWeight.Bold)
            }
            Spacer(Modifier.height(10.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedButton(onClick = { dial(ctx, CENTER_PHONE) }, shape = RoundedCornerShape(50)) {
                    Icon(Icons.Filled.Phone, contentDescription = null, tint = DeepTeal, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(6.dp))
                    Text(s.callTheCenter, color = DeepTeal, fontWeight = FontWeight.Bold)
                }
            }
        }

        Spacer(Modifier.height(8.dp))
        Footer(store, s) { goTo(Tab.Resources) }
    }
}

@Composable
private fun ToolCard(emoji: String, title: String, body: String, content: @Composable () -> Unit) {
    var open by remember { mutableStateOf(false) }
    RecoveryCard(Modifier.padding(bottom = 10.dp)) {
        Row(
            Modifier.fillMaxWidth().clickable { open = !open },
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(emoji, fontSize = 26.sp)
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(title, style = MaterialTheme.typography.titleMedium)
                if (!open) Text(body, style = MaterialTheme.typography.bodyMedium, color = WarmGray, maxLines = 2)
            }
            Icon(if (open) Icons.Filled.ExpandLess else Icons.Filled.ExpandMore, contentDescription = null, tint = WarmGray)
        }
        AnimatedVisibility(open) {
            Column {
                Spacer(Modifier.height(8.dp))
                Text(body, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                content()
            }
        }
    }
}

@Composable
private fun BoxBreathingTool(s: AppStrings) {
    var running by remember { mutableStateOf(false) }
    var phase by remember { mutableIntStateOf(0) } // 0 in, 1 hold, 2 out, 3 hold
    var round by remember { mutableIntStateOf(1) }
    var count by remember { mutableIntStateOf(4) }
    val phases = listOf(s.breatheIn, s.breatheHold, s.breatheOut, s.breatheHold)

    if (running) {
        LaunchedEffect(round, phase) {
            count = 4
            while (count > 0 && running) { delay(1000); count-- }
            if (running) {
                if (phase == 3) {
                    if (round >= 4) running = false else { round++; phase = 0 }
                } else phase++
            }
        }
    }
    Spacer(Modifier.height(10.dp))
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = DeepTeal.copy(alpha = 0.08f),
        border = BorderStroke(1.dp, DeepTeal.copy(alpha = 0.3f)),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(Modifier.padding(18.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            if (running) {
                Text("${s.roundOf} $round / 4", style = MaterialTheme.typography.labelLarge, color = WarmGray)
                Spacer(Modifier.height(4.dp))
                Text(phases[phase], style = MaterialTheme.typography.headlineSmall, color = DeepTeal)
                Spacer(Modifier.height(4.dp))
                Text("$count", fontSize = 44.sp, fontWeight = FontWeight.Bold, color = DeepTeal)
                Spacer(Modifier.height(10.dp))
                Button(onClick = { running = false }, shape = RoundedCornerShape(50),
                    colors = ButtonDefaults.buttonColors(containerColor = HelpOrange)) { Text(s.stop) }
            } else {
                Text("4 · 4 · 4 · 4", style = MaterialTheme.typography.titleMedium, color = WarmGray)
                Spacer(Modifier.height(8.dp))
                PillButton(s.start, onClick = { round = 1; phase = 0; running = true })
            }
        }
    }
}

@Composable
private fun GroundingTool(s: AppStrings) {
    val steps = listOf(5 to s.groundingSee, 4 to s.groundingTouch, 3 to s.groundingHear, 2 to s.groundingSmell, 1 to s.groundingTaste)
    Spacer(Modifier.height(8.dp))
    steps.forEach { (n, label) ->
        Row(Modifier.padding(vertical = 5.dp), verticalAlignment = Alignment.CenterVertically) {
            Surface(shape = RoundedCornerShape(50), color = DeepTeal) {
                Text("$n", Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                    color = CardWhite, fontWeight = FontWeight.Bold)
            }
            Spacer(Modifier.width(10.dp))
            Text(label, style = MaterialTheme.typography.bodyLarge)
        }
    }
}

@Composable
private fun HaltTool(s: AppStrings) {
    val rows = listOf(
        "🍽" to (s.haltHungry to s.haltHungryTip),
        "😠" to (s.haltAngry to s.haltAngryTip),
        "💛" to (s.haltLonely to s.haltLonelyTip),
        "😴" to (s.haltTired to s.haltTiredTip),
    )
    Spacer(Modifier.height(8.dp))
    rows.forEach { (emoji, pair) ->
        Row(Modifier.padding(vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(emoji, fontSize = 24.sp)
            Spacer(Modifier.width(10.dp))
            Column {
                Text(pair.first, style = MaterialTheme.typography.titleMedium)
                Text(pair.second, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            }
        }
    }
}

@Composable
private fun UrgeSurfingTool(s: AppStrings) {
    val ctx = LocalContext.current
    var running by remember { mutableStateOf(false) }
    var secondsLeft by remember { mutableIntStateOf(20 * 60) }

    if (running) {
        LaunchedEffect(Unit) {
            while (secondsLeft > 0) { delay(1000); secondsLeft-- }
            running = false
        }
    }
    val total = 20 * 60
    val elapsed = total - secondsLeft
    val phaseText = when {
        elapsed < total / 3 -> s.urgePhaseRise
        elapsed < total * 2 / 3 -> s.urgePhasePeak
        else -> s.urgePhaseFall
    }
    Spacer(Modifier.height(10.dp))
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = DeepTeal.copy(alpha = 0.08f),
        border = BorderStroke(1.dp, DeepTeal.copy(alpha = 0.3f)),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(Modifier.padding(18.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            if (running) {
                val mm = secondsLeft / 60
                val ss = secondsLeft % 60
                Text(String.format("%02d:%02d", mm, ss), fontSize = 44.sp, fontWeight = FontWeight.Bold, color = DeepTeal)
                Spacer(Modifier.height(6.dp))
                LinearProgressIndicator(
                    progress = { elapsed.toFloat() / total },
                    modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(50)),
                    color = DeepTeal, trackColor = SoftBorder,
                )
                Spacer(Modifier.height(10.dp))
                Text(phaseText, style = MaterialTheme.typography.bodyLarge, color = WarmGray)
                Spacer(Modifier.height(10.dp))
                Button(onClick = { running = false }, shape = RoundedCornerShape(50),
                    colors = ButtonDefaults.buttonColors(containerColor = HelpOrange)) { Text(s.stop) }
            } else {
                Text("20:00", fontSize = 44.sp, fontWeight = FontWeight.Bold, color = DeepTeal)
                Spacer(Modifier.height(8.dp))
                PillButton(s.start, onClick = { secondsLeft = total; running = true })
            }
            Spacer(Modifier.height(10.dp))
            Text(
                "${s.urgeNeedSomeone} ${s.call} $CRISIS_LINE_PRETTY",
                style = MaterialTheme.typography.bodyMedium, color = DeepTeal, fontWeight = FontWeight.SemiBold,
                modifier = Modifier.clickable { dial(ctx, CRISIS_LINE) },
            )
        }
    }
}
