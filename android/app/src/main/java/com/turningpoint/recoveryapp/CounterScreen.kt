package com.turningpoint.recoveryapp

import android.app.DatePickerDialog
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream
import java.time.LocalDate
import java.time.temporal.ChronoUnit

@Composable
fun CounterScreen(store: Store, s: AppStrings, lang: String, goTo: (Tab) -> Unit) {
    val ctx = LocalContext.current
    var cleanDate by remember { mutableStateOf(store.cleanDate) }
    var shareFor by remember { mutableStateOf<Milestone?>(null) }

    Column(Modifier.fillMaxWidth()) {
        SectionTitle(s.counterTitle)
        Text(s.counterSubtitle, style = MaterialTheme.typography.bodyLarge, color = WarmGray)
        Spacer(Modifier.height(14.dp))

        if (cleanDate == null) {
            RecoveryCard {
                Text(s.cleanDateLabel, style = MaterialTheme.typography.titleMedium)
                Spacer(Modifier.height(10.dp))
                var picked by remember { mutableStateOf(LocalDate.now(ZONE)) }
                Text(
                    formatFullDate(picked, lang),
                    style = MaterialTheme.typography.titleLarge, color = DeepTeal,
                )
                Spacer(Modifier.height(8.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    PillButton(s.cleanDateLabel, primary = false, onClick = {
                        val d = picked
                        DatePickerDialog(ctx, { _, y, m, day ->
                            picked = LocalDate.of(y, m + 1, day)
                        }, d.year, d.monthValue - 1, d.dayOfMonth).show()
                    })
                }
                Spacer(Modifier.height(12.dp))
                MilestoneLegend(s)
                Spacer(Modifier.height(6.dp))
                Text(s.milestoneTzNote, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
                Spacer(Modifier.height(12.dp))
                PillButton(s.startCounter, modifier = Modifier.fillMaxWidth(), onClick = {
                    store.cleanDate = picked
                    cleanDate = picked
                })
            }
        } else {
            val today = LocalDate.now(ZONE)
            val days = ChronoUnit.DAYS.between(cleanDate, today).coerceAtLeast(0)
            val earned = MILESTONES.filter { days >= it.days }
            val next = MILESTONES.firstOrNull { days < it.days }

            RecoveryCard {
                Text("🏅", fontSize = 40.sp, modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
                Spacer(Modifier.height(6.dp))
                Text("$days", style = MaterialTheme.typography.displaySmall,
                    modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
                Text(s.daysOfRecovery, style = MaterialTheme.typography.titleMedium, color = WarmGray,
                    modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
                Spacer(Modifier.height(6.dp))
                Text(breakdown(days, s, lang), style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center, color = DeepTeal)
                Spacer(Modifier.height(10.dp))
                val chip = earned.lastOrNull()
                Text("${s.currentChip}: ${chip?.let { if (lang == "es") it.labelEs else it.labelEn } ?: "—"}",
                    style = MaterialTheme.typography.titleMedium, modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
                if (next != null) {
                    val left = next.days - days
                    Text("${s.nextMilestone}: ${if (lang == "es") next.labelEs else next.labelEn} — ${s.inDays} $left ${s.day}${if (left == 1L) "" else "s"}",
                        style = MaterialTheme.typography.bodyMedium, color = WarmGray,
                        modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
                }
            }

            Spacer(Modifier.height(14.dp))
            PillButton(s.shareCleanTime, modifier = Modifier.fillMaxWidth(), onClick = {
                shareCleanTimeImage(ctx, days, s, lang)
            })

            Spacer(Modifier.height(14.dp))
            MoneySavedCard(store, s, days)

            Spacer(Modifier.height(14.dp))
            LazyVerticalGrid(
                columns = GridCells.Fixed(3),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
                modifier = Modifier.height(430.dp),
            ) {
                items(MILESTONES) { m ->
                    val isEarned = days >= m.days
                    Surface(
                        shape = RoundedCornerShape(16.dp),
                        color = if (isEarned) Gold.copy(alpha = 0.16f) else CardWhite,
                        border = BorderStroke(1.5.dp, if (isEarned) Gold else SoftBorder),
                        onClick = { if (isEarned) shareFor = m },
                    ) {
                        Column(Modifier.padding(10.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(if (isEarned) "✓" else "○", fontSize = 20.sp,
                                color = if (isEarned) Gold else WarmGray)
                            Text(if (lang == "es") m.labelEs else m.labelEn,
                                style = MaterialTheme.typography.labelLarge,
                                textAlign = TextAlign.Center, fontWeight = FontWeight.SemiBold)
                        }
                    }
                }
            }
            Spacer(Modifier.height(8.dp))
            Text(s.chipNote, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Spacer(Modifier.height(10.dp))
            TextButton(onClick = {
                val d = cleanDate!!
                DatePickerDialog(ctx, { _, y, m, day ->
                    val nd = LocalDate.of(y, m + 1, day)
                    store.cleanDate = nd
                    cleanDate = nd
                }, d.year, d.monthValue - 1, d.dayOfMonth).show()
            }, modifier = Modifier.fillMaxWidth()) {
                Text(s.changeDate, color = DeepTeal, fontWeight = FontWeight.Bold)
            }
        }

        Spacer(Modifier.height(8.dp))
        Footer(store, s) { goTo(Tab.Counter) }
    }

    shareFor?.let { m ->
        AlertDialog(
            onDismissRequest = { shareFor = null },
            title = { Text(s.shareMilestone) },
            text = {
                Text(
                    if (lang == "es") m.labelEs else m.labelEn,
                    style = MaterialTheme.typography.titleLarge, color = DeepTeal,
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        shareMilestoneImage(ctx, m, s, lang)
                        shareFor = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = DeepTeal),
                ) { Text(s.saveImage) }
            },
            dismissButton = { TextButton(onClick = { shareFor = null }) { Text(s.close) } },
        )
    }
}

@Composable
private fun MilestoneLegend(s: AppStrings) {
    Text("30 · 60 · 90 ${s.daysOfRecovery.split(" ").first()} · 6 · 9 · 18 ${s.months} · 1 · 2 · 4 · 5 ${s.years}",
        style = MaterialTheme.typography.bodyMedium, color = WarmGray)
}

private fun breakdown(days: Long, s: AppStrings, lang: String): String {
    val years = days / 365
    val months = (days % 365) / 30
    val rest = (days % 365) % 30
    val parts = mutableListOf<String>()
    if (years > 0) parts += "$years ${if (years == 1L) s.year else s.years}"
    if (months > 0) parts += "$months ${if (months == 1L) s.month else s.months}"
    if (rest > 0 || parts.isEmpty()) parts += "$rest ${s.day}${if (rest == 1L) "" else "s"}"
    return parts.joinToString(", ")
}

/** Draws the shared card frame (teal background + gold border). Returns bitmap + canvas. */
private fun cardBitmap(): Pair<Bitmap, Canvas> {
    val w = 1080; val h = 1350
    val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
    val c = Canvas(bmp)
    c.drawRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), 48f, 48f,
        Paint().apply { color = 0xFF0E5B57.toInt() })
    val gold = Paint().apply { color = 0xFFC9962E.toInt(); style = Paint.Style.STROKE; strokeWidth = 10f }
    c.drawRoundRect(RectF(60f, 60f, w - 60f, h - 60f), 32f, 32f, gold)
    return bmp to c
}

private fun Canvas.cardText(str: String, y: Float, size: Float, color: Int, bold: Boolean, w: Int = 1080) {
    val p = Paint().apply {
        this.color = color; textSize = size; textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.SANS_SERIF, if (bold) Typeface.BOLD else Typeface.NORMAL)
        isAntiAlias = true
    }
    drawText(str, w / 2f, y, p)
}

/** Saves the bitmap as a PNG and opens the system share sheet with the image
 *  plus a text message, so it can go to social apps, text messages, or email. */
private fun shareBitmap(ctx: Context, bmp: Bitmap, filename: String, message: String, title: String) {
    val dir = File(ctx.cacheDir, "images").apply { mkdirs() }
    val file = File(dir, filename)
    FileOutputStream(file).use { bmp.compress(Bitmap.CompressFormat.PNG, 100, it) }
    val uri = FileProvider.getUriForFile(ctx, "${ctx.packageName}.fileprovider", file)
    val share = Intent(Intent.ACTION_SEND).apply {
        type = "image/png"
        putExtra(Intent.EXTRA_STREAM, uri)
        putExtra(Intent.EXTRA_TEXT, message)
        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }
    ctx.startActivity(Intent.createChooser(share, title).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK
    })
}

/** Renders the milestone share card and opens the share sheet. */
private fun shareMilestoneImage(ctx: Context, m: Milestone, s: AppStrings, lang: String) {
    val (bmp, c) = cardBitmap()
    val label = if (lang == "es") m.labelEs else m.labelEn
    c.cardText("TURNING POINT", 300f, 64f, 0xFFFFFFFF.toInt(), true)
    c.cardText(s.shareCardTag, 360f, 34f, 0xFFC9962E.toInt(), true)
    c.cardText("🏅", 560f, 150f, 0xFFFFFFFF.toInt(), false)
    c.cardText(s.shareCardTitle, 700f, 72f, 0xFFFFFFFF.toInt(), true)
    c.cardText(label, 830f, 96f, 0xFFFFFFFF.toInt(), true)
    c.cardText(if (lang == "es") "de recuperación" else "of recovery", 900f, 44f, 0xFFFFFFFF.toInt(), false)
    c.cardText(s.shareCardSubtitle, 1050f, 48f, 0xFFE8E0CC.toInt(), false)
    shareBitmap(ctx, bmp, "milestone_${m.days}.png",
        "$label ${if (lang == "es") "de recuperación" else "of recovery"} — ${s.shareCardSubtitle} 💛", s.shareMilestone)
}

/** Renders a share card with the total clean time and opens the share sheet. */
private fun shareCleanTimeImage(ctx: Context, days: Long, s: AppStrings, lang: String) {
    val (bmp, c) = cardBitmap()
    c.cardText("TURNING POINT", 300f, 64f, 0xFFFFFFFF.toInt(), true)
    c.cardText(s.shareCardTag, 360f, 34f, 0xFFC9962E.toInt(), true)
    c.cardText("🏅", 590f, 150f, 0xFFFFFFFF.toInt(), false)
    c.cardText("$days", 770f, 130f, 0xFFFFFFFF.toInt(), true)
    c.cardText(s.daysOfRecovery, 850f, 52f, 0xFFFFFFFF.toInt(), false)
    c.cardText(breakdown(days, s, lang), 930f, 44f, 0xFFE8E0CC.toInt(), false)
    c.cardText(s.shareCardSubtitle, 1080f, 48f, 0xFFE8E0CC.toInt(), false)
    shareBitmap(ctx, bmp, "cleantime_$days.png",
        "$days ${s.daysOfRecovery} (${breakdown(days, s, lang)}) — ${s.shareCardSubtitle} 💛", s.shareCleanTime)
}

private fun usd(amount: Double): String =
    java.text.NumberFormat.getCurrencyInstance(java.util.Locale.US).format(amount)

private fun typeLabel(type: String, s: AppStrings): String = when (type) {
    "wine" -> s.moneyWine
    "liquor" -> s.moneyLiquor
    else -> s.moneyBeer
}

@Composable
private fun ChoiceChip(label: String, selected: Boolean, onClick: () -> Unit) {
    Surface(
        shape = RoundedCornerShape(50),
        color = if (selected) DeepTeal else CardWhite,
        border = BorderStroke(1.5.dp, DeepTeal),
        onClick = onClick,
    ) {
        Text(label, modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp),
            color = if (selected) CardWhite else DeepTeal,
            fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun MoneySavedCard(store: Store, s: AppStrings, days: Long) {
    var configured by remember { mutableStateOf(store.moneyConfigured()) }
    var setupOpen by remember { mutableStateOf(false) }
    val isDrugs = store.alcoholType == "drugs"

    RecoveryCard {
        Text("💰 ${s.moneyTitle}", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(8.dp))
        if (!configured) {
            Text(s.moneyNotSet, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Spacer(Modifier.height(10.dp))
            PillButton(s.moneySetup, primary = false, onClick = { setupOpen = true })
        } else {
            Text(usd(store.moneySaved(days)), style = MaterialTheme.typography.displaySmall,
                color = DeepTeal, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(4.dp))
            val detail = if (isDrugs) {
                val name = store.drugName.trim()
                val perDay = "${usd(store.spendPerDay.toDouble())} ${s.moneyPerDay}"
                if (name.isEmpty()) perDay else "$name · $perDay"
            } else {
                "${store.drinksPerDay} ${s.moneyDrinksDay} · ${typeLabel(store.alcoholType, s)} · " +
                    "${usd(store.pricePerDrink.toDouble())} ${s.moneyEach}"
            }
            Text(detail, style = MaterialTheme.typography.bodyMedium, color = WarmGray)
            Spacer(Modifier.height(10.dp))
            PillButton(s.moneyEdit, primary = false, onClick = { setupOpen = true })
        }
    }

    if (setupOpen) {
        MoneySetupDialog(store, s, onDone = {
            setupOpen = false
            configured = store.moneyConfigured()
        })
    }
}

@Composable
private fun MoneySetupDialog(store: Store, s: AppStrings, onDone: () -> Unit) {
    var substance by remember { mutableStateOf(if (store.alcoholType == "drugs") "drugs" else "alcohol") }
    // alcohol fields
    var drinksText by remember { mutableStateOf(if (store.drinksPerDay > 0) store.drinksPerDay.toString() else "") }
    var type by remember { mutableStateOf(if (store.alcoholType == "drugs") "beer" else store.alcoholType) }
    var priceText by remember { mutableStateOf(store.pricePerDrink.toString()) }
    var priceTouched by remember { mutableStateOf(false) }
    // drug fields
    var drugNameText by remember { mutableStateOf(store.drugName) }
    var spendText by remember {
        mutableStateOf(if (store.spendPerDay > 0) store.spendPerDay.toString() else "")
    }

    AlertDialog(
        onDismissRequest = onDone,
        title = { Text(s.moneyTitle, fontWeight = FontWeight.Bold) },
        text = {
            Column(Modifier.verticalScroll(rememberScrollState())) {
                Text(s.moneySubstance, style = MaterialTheme.typography.labelLarge)
                Spacer(Modifier.height(4.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    ChoiceChip(s.moneyAlcohol, substance == "alcohol") { substance = "alcohol" }
                    ChoiceChip(s.moneyDrugs, substance == "drugs") { substance = "drugs" }
                }
                if (substance == "alcohol") {
                    Spacer(Modifier.height(12.dp))
                    Text(s.moneyDrinksPerDay, style = MaterialTheme.typography.labelLarge)
                    Spacer(Modifier.height(4.dp))
                    OutlinedTextField(
                        value = drinksText,
                        onValueChange = { drinksText = it.filter { c -> c.isDigit() }.take(3) },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth(),
                        keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                            keyboardType = androidx.compose.ui.text.input.KeyboardType.Number),
                    )
                    Spacer(Modifier.height(12.dp))
                    Text(s.moneyAlcoholType, style = MaterialTheme.typography.labelLarge)
                    Spacer(Modifier.height(4.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        listOf("beer" to s.moneyBeer, "wine" to s.moneyWine, "liquor" to s.moneyLiquor)
                            .forEach { (key, label) ->
                                ChoiceChip(label, type == key) {
                                    type = key
                                    if (!priceTouched) priceText = defaultDrinkPrice(key).toString()
                                }
                            }
                    }
                    Spacer(Modifier.height(12.dp))
                    Text(s.moneyPricePerDrink, style = MaterialTheme.typography.labelLarge)
                    Spacer(Modifier.height(4.dp))
                    OutlinedTextField(
                        value = priceText,
                        onValueChange = { priceText = it.filter { c -> c.isDigit() || c == '.' }.take(6); priceTouched = true },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth(),
                        keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                            keyboardType = androidx.compose.ui.text.input.KeyboardType.Decimal),
                    )
                } else {
                    Spacer(Modifier.height(12.dp))
                    Text(s.moneyDrugOfChoice, style = MaterialTheme.typography.labelLarge)
                    Spacer(Modifier.height(4.dp))
                    OutlinedTextField(
                        value = drugNameText,
                        onValueChange = { drugNameText = it.take(40) },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth(),
                    )
                    Spacer(Modifier.height(12.dp))
                    Text(s.moneySpentPerDay, style = MaterialTheme.typography.labelLarge)
                    Spacer(Modifier.height(4.dp))
                    OutlinedTextField(
                        value = spendText,
                        onValueChange = { spendText = it.filter { c -> c.isDigit() || c == '.' }.take(7) },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth(),
                        keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(
                            keyboardType = androidx.compose.ui.text.input.KeyboardType.Decimal),
                    )
                }
            }
        },
        confirmButton = {
            TextButton(onClick = {
                if (substance == "drugs") {
                    val sp = spendText.toFloatOrNull() ?: 0f
                    if (sp > 0) {
                        store.alcoholType = "drugs"
                        store.drugName = drugNameText.trim()
                        store.spendPerDay = sp
                    }
                } else {
                    val d = drinksText.toIntOrNull() ?: 0
                    val p = priceText.toFloatOrNull() ?: defaultDrinkPrice(type)
                    if (d > 0 && p > 0) {
                        store.drinksPerDay = d
                        store.alcoholType = type
                        store.pricePerDrink = p
                    }
                }
                onDone()
            }) { Text(s.moneySave) }
        },
        dismissButton = {
            TextButton(onClick = onDone) { Text(s.close) }
        },
    )
}
