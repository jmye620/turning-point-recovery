package com.turningpoint.recoveryapp

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CrisisSheet(store: Store, s: AppStrings, onClose: () -> Unit, goTo: (Tab) -> Unit) {
    val ctx = LocalContext.current
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    var showNow by remember { mutableStateOf(false) }
    var name by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }
    var refresh by remember { mutableIntStateOf(0) }

    ModalBottomSheet(onDismissRequest = onClose, sheetState = sheetState) {
        Column(
            Modifier.fillMaxWidth().verticalScroll(rememberScrollState()).padding(20.dp),
        ) {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Text(s.crisisTitle, style = MaterialTheme.typography.headlineSmall, modifier = Modifier.weight(1f))
                IconButton(onClick = onClose) { Icon(Icons.Filled.Close, contentDescription = s.close) }
            }
            Text(s.crisisSubtitle, style = MaterialTheme.typography.bodyLarge, color = WarmGray)
            Spacer(Modifier.height(14.dp))

            Button(
                onClick = { showNow = !showNow },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(50),
                colors = ButtonDefaults.buttonColors(containerColor = HelpOrange),
            ) { Text(s.crisisCallNow, fontWeight = FontWeight.Bold) }
            if (showNow) {
                Spacer(Modifier.height(10.dp))
                RecoveryCard {
                    CallRow(s.crisisCallLine, CRISIS_LINE_PRETTY, CRISIS_LINE)
                    Spacer(Modifier.height(8.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        Button(onClick = { dial(ctx, "988") }, shape = RoundedCornerShape(50),
                            colors = ButtonDefaults.buttonColors(containerColor = DeepTeal),
                            modifier = Modifier.weight(1f)) { Text(s.crisisCall988) }
                        Button(onClick = { textTo(ctx, "988") }, shape = RoundedCornerShape(50),
                            colors = ButtonDefaults.buttonColors(containerColor = DeepTeal),
                            modifier = Modifier.weight(1f)) { Text(s.crisisText988) }
                    }
                }
            }

            Spacer(Modifier.height(12.dp))
            CallRow("24-hour crisis line", CRISIS_LINE_PRETTY, CRISIS_LINE)
            Spacer(Modifier.height(8.dp))
            CallRow("988 Suicide & Crisis Lifeline", "988", "988", "free, confidential, 24/7")
            Spacer(Modifier.height(8.dp))
            CallRow(s.crisisCenter, CENTER_PHONE_PRETTY, CENTER_PHONE, s.crisisCenterHours)
            Spacer(Modifier.height(8.dp))
            CallRow(s.crisis911, "911", "911", s.crisis911Note)

            Spacer(Modifier.height(14.dp))
            RecoveryCard {
                Text(s.crisisWhat988, style = MaterialTheme.typography.titleMedium)
                Spacer(Modifier.height(4.dp))
                Text(s.crisisWhat988Body, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            }
            Spacer(Modifier.height(10.dp))
            RecoveryCard {
                Text(s.crisisWorried, style = MaterialTheme.typography.titleMedium)
                Spacer(Modifier.height(4.dp))
                Text(s.crisisWorriedBody, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            }
            Spacer(Modifier.height(10.dp))
            PillButton(s.crisisTryBreathing, modifier = Modifier.fillMaxWidth(), onClick = {
                onClose(); goTo(Tab.Resources)
            })

            Spacer(Modifier.height(16.dp))
            Text(s.supportContacts, style = MaterialTheme.typography.titleLarge)
            Spacer(Modifier.height(8.dp))
            if (refresh >= 0) {
                store.contacts().forEach { c ->
                    RecoveryCard(Modifier.padding(bottom = 8.dp)) {
                        Text(c.name, style = MaterialTheme.typography.titleMedium)
                        Text(c.phone, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                        Spacer(Modifier.height(8.dp))
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            Button(onClick = { dial(ctx, c.phone) }, shape = RoundedCornerShape(50),
                                colors = ButtonDefaults.buttonColors(containerColor = DeepTeal)) { Text(s.call) }
                            Button(onClick = { textTo(ctx, c.phone) }, shape = RoundedCornerShape(50),
                                colors = ButtonDefaults.buttonColors(containerColor = DeepTeal)) { Text(s.text) }
                            TextButton(onClick = { store.removeContact(c); refresh++ }) {
                                Text(s.remove, color = Danger)
                            }
                        }
                    }
                }
            }
            RecoveryCard {
                OutlinedTextField(value = name, onValueChange = { name = it },
                    label = { Text(s.contactNameHint) }, modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(14.dp))
                Spacer(Modifier.height(8.dp))
                OutlinedTextField(value = phone, onValueChange = { phone = it },
                    label = { Text(s.contactPhoneHint) }, modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(14.dp))
                Spacer(Modifier.height(10.dp))
                Button(
                    onClick = {
                        if (name.isNotBlank() && phone.isNotBlank()) {
                            store.addContact(name.trim(), phone.trim())
                            name = ""; phone = ""; refresh++
                        }
                    },
                    shape = RoundedCornerShape(50),
                    colors = ButtonDefaults.buttonColors(containerColor = DeepTeal),
                ) { Text(s.addContact) }
            }
            Spacer(Modifier.height(24.dp))
        }
    }
}
