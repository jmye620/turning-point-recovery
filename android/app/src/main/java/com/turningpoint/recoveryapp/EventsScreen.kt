package com.turningpoint.recoveryapp

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun EventsScreen(store: Store, s: AppStrings, goTo: (Tab) -> Unit) {
    Column(Modifier.fillMaxWidth()) {
        SectionTitle(s.eventsTitle)
        Text(s.eventsSubtitle, style = MaterialTheme.typography.bodyLarge, color = WarmGray)
        Spacer(Modifier.height(14.dp))

        RecoveryCard {
            Text("🎃", style = MaterialTheme.typography.displaySmall)
            Spacer(Modifier.height(6.dp))
            Text(s.halloweenTitle, style = MaterialTheme.typography.titleLarge)
            Text(s.halloweenWhen, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Text(s.halloweenWhere, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Spacer(Modifier.height(6.dp))
            Text(s.halloweenBody, style = MaterialTheme.typography.bodyMedium)
        }
        Spacer(Modifier.height(12.dp))
        RecoveryCard {
            Text("📦", style = MaterialTheme.typography.displaySmall)
            Spacer(Modifier.height(6.dp))
            Text(s.takeBackDayTitle, style = MaterialTheme.typography.titleLarge)
            Text(s.takeBackDayWhen, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Text(s.takeBackDayWhere, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Spacer(Modifier.height(6.dp))
            Text(s.takeBackDayBody, style = MaterialTheme.typography.bodyMedium)
        }

        Spacer(Modifier.height(8.dp))
        Footer(store, s) { goTo(Tab.Events) }
    }
}
