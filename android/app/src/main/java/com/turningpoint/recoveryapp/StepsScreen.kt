package com.turningpoint.recoveryapp

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
fun StepsScreen(store: Store, s: AppStrings, lang: String, goTo: (Tab) -> Unit) {
    var done by remember { mutableStateOf(store.stepsDone()) }

    Column(Modifier.fillMaxWidth()) {
        SectionTitle(s.stepsTitle)
        Text(s.stepsSubtitle, style = MaterialTheme.typography.bodyLarge, color = WarmGray)
        Spacer(Modifier.height(6.dp))
        Text("${done.size} / 12 ${s.stepsCompleted}",
            style = MaterialTheme.typography.titleMedium, color = DeepTeal, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(14.dp))

        TWELVE_STEPS.forEachIndexed { i, step ->
            val n = i + 1
            val checked = n in done
            RecoveryCard(modifier = Modifier.padding(vertical = 5.dp)) {
                Row(verticalAlignment = Alignment.Top, modifier = Modifier.fillMaxWidth()) {
                    Checkbox(
                        checked = checked,
                        onCheckedChange = {
                            store.toggleStep(n)
                            done = store.stepsDone()
                        },
                        colors = CheckboxDefaults.colors(checkedColor = DeepTeal),
                    )
                    Column(Modifier.weight(1f).padding(start = 4.dp)) {
                        Text("${s.stepsTitle.split(" ").lastOrNull() ?: ""} $n".trim(),
                            style = MaterialTheme.typography.labelLarge, color = DeepTeal,
                            fontWeight = FontWeight.Bold)
                        Text(if (lang == "es") step.es else step.en,
                            style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }
        }

        Spacer(Modifier.height(8.dp))
        Footer(store, s) { goTo(Tab.Steps) }
    }
}
