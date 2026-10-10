package com.turningpoint.recoveryapp

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
fun RecoveryCard(modifier: Modifier = Modifier, content: @Composable () -> Unit) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = CardWhite),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        border = BorderStroke(1.dp, SoftBorder),
    ) {
        Column(Modifier.padding(18.dp)) { content() }
    }
}

@Composable
fun SectionTitle(text: String, modifier: Modifier = Modifier) {
    Text(text, style = MaterialTheme.typography.headlineSmall, modifier = modifier.padding(bottom = 10.dp))
}

@Composable
fun PillButton(text: String, onClick: () -> Unit, modifier: Modifier = Modifier, primary: Boolean = true) {
    Button(
        onClick = onClick,
        modifier = modifier,
        shape = RoundedCornerShape(50),
        colors = ButtonDefaults.buttonColors(
            containerColor = if (primary) DeepTeal else CardWhite,
            contentColor = if (primary) CardWhite else DeepTeal,
        ),
        border = if (primary) null else BorderStroke(1.5.dp, DeepTeal),
    ) { Text(text, fontWeight = FontWeight.SemiBold) }
}

@Composable
fun CallRow(label: String, prettyNumber: String, digits: String, note: String? = null) {
    val ctx = LocalContext.current
    OutlinedButton(
        onClick = { dial(ctx, digits) },
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, SoftBorder),
    ) {
        Icon(Icons.Filled.Phone, contentDescription = null, tint = DeepTeal)
        Spacer(Modifier.width(10.dp))
        Column(Modifier.weight(1f), horizontalAlignment = Alignment.Start) {
            Text(label, style = MaterialTheme.typography.titleMedium, color = DeepTeal)
            Text(prettyNumber, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Bold)
            if (note != null) Text(note, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
        }
    }
}

fun dial(ctx: Context, digits: String) {
    runCatching {
        ctx.startActivity(Intent(Intent.ACTION_DIAL, Uri.parse("tel:$digits")).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        })
    }
}

fun textTo(ctx: Context, digits: String) {
    runCatching {
        ctx.startActivity(Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:$digits")).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        })
    }
}

fun openLink(ctx: Context, url: String) {
    runCatching {
        ctx.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        })
    }
}

fun toast(ctx: Context, msg: String) = Toast.makeText(ctx, msg, Toast.LENGTH_SHORT).show()

@Composable
fun DeleteAllSection(store: Store, s: AppStrings, onDeleted: () -> Unit) {
    var confirm by remember { mutableStateOf(false) }
    val ctx = LocalContext.current
    Spacer(Modifier.height(8.dp))
    TextButton(onClick = { confirm = true }, modifier = Modifier.fillMaxWidth()) {
        Text(s.deleteEverything, color = Danger, fontWeight = FontWeight.SemiBold)
    }
    if (confirm) {
        AlertDialog(
            onDismissRequest = { confirm = false },
            title = { Text(s.deleteConfirmTitle) },
            text = { Text(s.deleteConfirmBody) },
            confirmButton = {
                Button(
                    onClick = {
                        store.deleteEverything()
                        confirm = false
                        toast(ctx, s.deletedToast)
                        onDeleted()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = Danger),
                ) { Text(s.deleteConfirmYes) }
            },
            dismissButton = { TextButton(onClick = { confirm = false }) { Text(s.cancel) } },
        )
    }
}

@Composable
fun Footer(store: Store, s: AppStrings, onDeleted: () -> Unit) {
    val ctx = LocalContext.current
    Column(Modifier.fillMaxWidth().padding(top = 18.dp, bottom = 8.dp)) {
        Text(s.needHelpNow, style = MaterialTheme.typography.titleMedium, color = DeepTeal)
        Spacer(Modifier.height(6.dp))
        Row(Modifier.fillMaxWidth()) {
            OutlinedButton(
                onClick = { dial(ctx, CRISIS_LINE) },
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(50),
            ) { Text(CRISIS_LINE_PRETTY, fontWeight = FontWeight.Bold) }
            Spacer(Modifier.width(8.dp))
            OutlinedButton(
                onClick = { dial(ctx, "988") },
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(50),
            ) { Text("988", fontWeight = FontWeight.Bold) }
        }
        Spacer(Modifier.height(10.dp))
        Text(s.privacyNote, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
        Spacer(Modifier.height(4.dp))
        Text(s.programOf, style = MaterialTheme.typography.labelSmall, color = WarmGray)
        Spacer(Modifier.height(4.dp))
        val vName = try {
            ctx.packageManager.getPackageInfo(ctx.packageName, 0).versionName
        } catch (_: Exception) { "?" }
        Text("v$vName", style = MaterialTheme.typography.labelSmall, color = WarmGray,
            modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
        DeleteAllSection(store, s, onDeleted)
    }
}
