package com.turningpoint.recoveryapp

import android.content.Context
import android.content.pm.PackageManager
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/** Package of John's installed Flappy Bird v1 mod build. */
const val FLAPPY_PACKAGE = "com.dotgears.flappybird.jyeley.v100426"

fun isFlappyInstalled(ctx: Context): Boolean = try {
    @Suppress("DEPRECATION")
    ctx.packageManager.getPackageInfo(FLAPPY_PACKAGE, 0)
    true
} catch (_: PackageManager.NameNotFoundException) {
    false
}

/** Emergency distraction tab: one tap opens the Flappy Bird game, if installed. */
@Composable
fun DistractScreen(store: Store, s: AppStrings, lang: String, goTo: (Tab) -> Unit) {
    val ctx = LocalContext.current
    // Re-checked every time the tab is opened (screen is recreated on tab switch).
    var installed by remember { mutableStateOf(isFlappyInstalled(ctx)) }

    Column(
        Modifier.fillMaxWidth().padding(vertical = 12.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(Modifier.height(24.dp))
        Text("🎮", fontSize = 72.sp)
        Spacer(Modifier.height(16.dp))
        Text(
            s.distractTitle,
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            color = DeepTeal,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(10.dp))
        Text(
            s.distractBody,
            style = MaterialTheme.typography.bodyLarge,
            color = WarmGray,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 12.dp),
        )
        Spacer(Modifier.height(28.dp))
        Button(
            onClick = {
                if (installed) {
                    val launch = ctx.packageManager.getLaunchIntentForPackage(FLAPPY_PACKAGE)
                    if (launch != null) ctx.startActivity(launch)
                    else installed = false
                } else {
                    installed = isFlappyInstalled(ctx)
                }
            },
            shape = RoundedCornerShape(50),
            colors = ButtonDefaults.buttonColors(containerColor = DeepTeal),
            modifier = Modifier.fillMaxWidth().height(60.dp),
        ) {
            Text(s.playFlappy, fontWeight = FontWeight.Bold, fontSize = 18.sp)
        }
        if (!installed) {
            Spacer(Modifier.height(14.dp))
            Text(
                s.flappyMissing,
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.SemiBold,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(6.dp))
            Text(
                s.flappyMissingNote,
                style = MaterialTheme.typography.bodyMedium,
                color = WarmGray,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = 12.dp),
            )
        }
        Spacer(Modifier.height(28.dp))
        RecoveryCard {
            Text("⏱️", style = MaterialTheme.typography.titleLarge)
            Spacer(Modifier.height(4.dp))
            Text(s.distractTip, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
        }
        Spacer(Modifier.height(16.dp))
        Footer(store, s) { goTo(Tab.Distract) }
    }
}
