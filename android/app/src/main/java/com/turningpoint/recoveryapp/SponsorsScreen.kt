package com.turningpoint.recoveryapp

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
fun SponsorsScreen(store: Store, s: AppStrings, lang: String, goTo: (Tab) -> Unit) {
    val ctx = LocalContext.current
    var sponsors by remember { mutableStateOf(store.sponsors()) }
    var name by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }

    fun refresh() { sponsors = store.sponsors() }

    Column(Modifier.fillMaxWidth()) {
        SectionTitle(s.sponsorsTitle)
        Text(s.sponsorsSubtitle, style = MaterialTheme.typography.bodyLarge, color = WarmGray)
        Spacer(Modifier.height(14.dp))

        if (sponsors.isEmpty()) {
            Text(s.noSponsors, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Spacer(Modifier.height(8.dp))
        }
        sponsors.forEach { sp ->
            RecoveryCard {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Column(Modifier.weight(1f)) {
                        Text(sp.name, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                        Text(sp.phone, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                    }
                    OutlinedButton(onClick = { dial(ctx, sp.phone) }) { Text("📞 ${s.call}") }
                }
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                    TextButton(onClick = { store.removeSponsor(sp); refresh() }) { Text(s.remove) }
                }
            }
            Spacer(Modifier.height(8.dp))
        }

        RecoveryCard {
            Text(s.addContact, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = name, onValueChange = { name = it },
                label = { Text(s.contactNameHint) }, modifier = Modifier.fillMaxWidth(),
                singleLine = true,
            )
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = phone, onValueChange = { phone = it },
                label = { Text(s.contactPhoneHint) }, modifier = Modifier.fillMaxWidth(),
                singleLine = true,
            )
            Spacer(Modifier.height(12.dp))
            PillButton(
                s.addContact,
                modifier = Modifier.fillMaxWidth(),
                onClick = {
                    if (name.isNotBlank() && phone.isNotBlank()) {
                        store.addSponsor(name.trim(), phone.trim())
                        name = ""; phone = ""
                        refresh()
                    }
                },
            )
        }

        Spacer(Modifier.height(8.dp))
        Footer(store, s) { goTo(Tab.Sponsors) }
    }
}
