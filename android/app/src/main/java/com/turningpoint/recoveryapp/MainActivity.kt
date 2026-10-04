package com.turningpoint.recoveryapp

import android.content.Intent
import android.os.Bundle
import android.util.Log
import java.io.File
import java.util.Date
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Assignment
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Campaign
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.MenuBook
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.People
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

enum class Tab { Today, CheckIn, Counter, Meetings, Resources, Events, Steps, Sponsors }

/** Saves uncaught exceptions to internal storage so the next launch can
 *  offer to share the crash details for diagnosis. */
private fun crashFile(activity: ComponentActivity) = File(activity.filesDir, "crash.log")

private fun installCrashHandler(activity: ComponentActivity) {
    val prev = Thread.getDefaultUncaughtExceptionHandler()
    Thread.setDefaultUncaughtExceptionHandler { t, e ->
        try {
            val vName = try {
                activity.packageManager.getPackageInfo(activity.packageName, 0).versionName
            } catch (_: Exception) { "?" }
            crashFile(activity).writeText(
                "Turning Point Recovery crash — app v$vName — ${Date()}\nThread: ${t.name}\n\n${Log.getStackTraceString(e)}"
            )
        } catch (_: Exception) { }
        prev?.uncaughtException(t, e)
    }
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        installCrashHandler(this)
        val activity = this
        val store = Store(this)
        setContent {
            RecoveryTheme {
                var lang by remember { mutableStateOf(store.language) }
                var tab by remember { mutableStateOf(Tab.Today) }
                var crisisOpen by remember { mutableStateOf(false) }
                val s = if (lang == "es") es else en
                var crashReport by remember {
                    mutableStateOf(
                        crashFile(activity).takeIf { it.exists() }?.readText()
                    )
                }

                fun goTo(t: Tab) { tab = t }

                Scaffold(
                    topBar = { AppTopBar(s, lang, onLang = {
                        lang = it; store.language = it
                    }, onHelp = { crisisOpen = true }) },
                    bottomBar = { AppBottomBar(s, tab, onTab = { tab = it }) },
                    containerColor = Cream,
                ) { pad ->
                    Column(
                        Modifier.fillMaxSize().padding(pad)
                            .verticalScroll(rememberScrollState())
                            .padding(horizontal = 16.dp, vertical = 12.dp),
                    ) {
                        when (tab) {
                            Tab.Today -> TodayScreen(store, s, lang, ::goTo) { crisisOpen = true }
                            Tab.CheckIn -> CheckInScreen(store, s, lang, ::goTo) { crisisOpen = true }
                            Tab.Counter -> CounterScreen(store, s, lang, ::goTo)
                            Tab.Meetings -> MeetingsScreen(store, s, lang, ::goTo)
                            Tab.Resources -> ResourcesScreen(store, s, lang, ::goTo)
                            Tab.Events -> EventsScreen(store, s, ::goTo)
                            Tab.Steps -> StepsScreen(store, s, lang, ::goTo)
                            Tab.Sponsors -> SponsorsScreen(store, s, lang, ::goTo)
                        }
                    }
                }

                if (crisisOpen) CrisisSheet(store, s, onClose = { crisisOpen = false }, ::goTo)

                crashReport?.let { report ->
                    AlertDialog(
                        onDismissRequest = { },
                        title = { Text(s.crashTitle) },
                        text = {
                            Column {
                                Text(s.crashMessage)
                                Spacer(Modifier.height(8.dp))
                                Text(
                                    report.take(2000),
                                    style = MaterialTheme.typography.labelSmall,
                                    modifier = Modifier.verticalScroll(rememberScrollState()),
                                )
                            }
                        },
                        confirmButton = {
                            Button(onClick = {
                                val share = Intent(Intent.ACTION_SEND).apply {
                                    type = "text/plain"
                                    putExtra(Intent.EXTRA_TEXT, report)
                                }
                                activity.startActivity(
                                    Intent.createChooser(share, s.crashShare).apply {
                                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    }
                                )
                                crashFile(activity).delete()
                                crashReport = null
                            }) { Text(s.crashShare) }
                        },
                        dismissButton = {
                            TextButton(onClick = {
                                crashFile(activity).delete()
                                crashReport = null
                            }) { Text(s.close) }
                        },
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AppTopBar(s: AppStrings, lang: String, onLang: (String) -> Unit, onHelp: () -> Unit) {
    TopAppBar(
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("🌅", fontSize = 24.sp)
                Spacer(Modifier.width(8.dp))
                Text(s.appName, style = MaterialTheme.typography.titleLarge, color = DeepTeal)
            }
        },
        actions = {
            Surface(
                shape = RoundedCornerShape(50),
                border = BorderStroke(1.dp, SoftBorder),
                color = CardWhite,
                modifier = Modifier.padding(end = 8.dp),
                onClick = { onLang(if (lang == "en") "es" else "en") },
            ) {
                Text(
                    s.language,
                    modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp),
                    style = MaterialTheme.typography.labelLarge,
                    color = DeepTeal, fontWeight = FontWeight.Bold,
                )
            }
            Button(
                onClick = onHelp,
                shape = RoundedCornerShape(50),
                colors = ButtonDefaults.buttonColors(containerColor = HelpOrange),
                modifier = Modifier.padding(end = 12.dp).height(40.dp),
            ) { Text(s.getHelp, fontWeight = FontWeight.Bold, fontSize = 14.sp) }
        },
        colors = TopAppBarDefaults.topAppBarColors(containerColor = Cream),
    )
}

@Composable
private fun AppBottomBar(s: AppStrings, tab: Tab, onTab: (Tab) -> Unit) {
    val items: List<Triple<Tab, String, ImageVector>> = listOf(
        Triple(Tab.Today, s.tabToday, Icons.Filled.Home),
        Triple(Tab.CheckIn, s.tabCheckIn, Icons.Filled.Assignment),
        Triple(Tab.Counter, s.tabCounter, Icons.Filled.EmojiEvents),
        Triple(Tab.Meetings, s.tabMeetings, Icons.Filled.CalendarMonth),
        Triple(Tab.Resources, s.tabResources, Icons.Filled.MenuBook),
        Triple(Tab.Events, s.tabEvents, Icons.Filled.Campaign),
        Triple(Tab.Steps, s.tabSteps, Icons.Filled.CheckCircle),
        Triple(Tab.Sponsors, s.tabSponsors, Icons.Filled.People),
    )
    NavigationBar(containerColor = CardWhite) {
        items.forEach { (t, label, icon) ->
            NavigationBarItem(
                selected = tab == t,
                onClick = { onTab(t) },
                icon = { Icon(icon, contentDescription = label, modifier = Modifier.size(24.dp)) },
                label = { Text(label, fontSize = 11.sp) },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = DeepTeal,
                    selectedTextColor = DeepTeal,
                    indicatorColor = DeepTeal.copy(alpha = 0.12f),
                    unselectedIconColor = WarmGray,
                    unselectedTextColor = WarmGray,
                ),
            )
        }
    }
}
