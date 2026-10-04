package com.turningpoint.recoveryapp

import android.content.Context
import android.content.SharedPreferences
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Locale

val ZONE: ZoneId = ZoneId.of("America/Chicago")
const val CENTER_PHONE = "2704443621"
const val CRISIS_LINE = "8005923980"
const val CENTER_PHONE_PRETTY = "270.444.3621"
const val CRISIS_LINE_PRETTY = "800.592.3980"
const val WEBSITE = "https://4rbh.org"

data class CheckIn(val date: LocalDate, val mood: Int, val cravings: Int, val gratitude: String, val hasCall: Boolean, val time: LocalTime)
data class JournalEntry(val id: Long, val dateTime: LocalDateTime, val text: String)
data class SupportContact(val name: String, val phone: String)

/** All personal data lives in SharedPreferences on this phone only — mirrors the
 *  web app's "saved on this phone only" privacy promise. */
class Store(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("recovery_store", Context.MODE_PRIVATE)

    var language: String
        get() = prefs.getString("lang", "en") ?: "en"
        set(v) = prefs.edit().putString("lang", v).apply()

    var cleanDate: LocalDate?
        get() = prefs.getString("clean_date", null)?.let { LocalDate.parse(it) }
        set(v) = prefs.edit().putString("clean_date", v?.toString()).apply()

    fun saveCheckIn(c: CheckIn) {
        val key = c.date.toString()
        val value = listOf(c.mood, c.cravings, if (c.hasCall) 1 else 0, c.time.toString(), c.gratitude.replace("|", " "))
            .joinToString("|")
        prefs.edit().putString("checkin_$key", value).apply()
        val dates = checkInDates().toMutableSet().also { it.add(key) }
        prefs.edit().putStringSet("checkin_dates", dates).apply()
    }

    fun checkInDates(): Set<String> = prefs.getStringSet("checkin_dates", emptySet()) ?: emptySet()

    fun getCheckIn(date: LocalDate): CheckIn? {
        val raw = prefs.getString("checkin_${date}", null) ?: return null
        val parts = raw.split("|", limit = 5)
        if (parts.size < 5) return null
        return CheckIn(date, parts[0].toInt(), parts[1].toInt(), parts[4], parts[2] == "1", LocalTime.parse(parts[3]))
    }

    /** Consecutive-day streak ending today (or yesterday if today isn't done yet). */
    fun streak(today: LocalDate = LocalDate.now(ZONE)): Int {
        val dates = checkInDates().mapNotNull { runCatching { LocalDate.parse(it) }.getOrNull() }.toSet()
        if (dates.isEmpty()) return 0
        var cursor = if (today.toString() in checkInDates()) today else today.minusDays(1)
        var n = 0
        while (cursor.toString() in checkInDates()) { n++; cursor = cursor.minusDays(1) }
        return n
    }

    fun saveJournal(text: String) {
        val id = System.currentTimeMillis()
        prefs.edit().putString("journal_$id", "${LocalDateTime.now(ZONE)}|$text").apply()
        val ids = journalIds().toMutableSet().also { it.add(id.toString()) }
        prefs.edit().putStringSet("journal_ids", ids).apply()
    }

    fun journalIds(): Set<String> = prefs.getStringSet("journal_ids", emptySet()) ?: emptySet()

    fun journalEntries(): List<JournalEntry> = journalIds().mapNotNull { id ->
        val raw = prefs.getString("journal_$id", null) ?: return@mapNotNull null
        val dt = raw.substringBefore("|")
        val text = raw.substringAfter("|")
        JournalEntry(id.toLong(), LocalDateTime.parse(dt), text)
    }.sortedByDescending { it.dateTime }

    fun deleteJournal(id: Long) {
        prefs.edit().remove("journal_$id").apply()
        val ids = journalIds().toMutableSet().also { it.remove(id.toString()) }
        prefs.edit().putStringSet("journal_ids", ids).apply()
    }

    fun addContact(name: String, phone: String) {
        val list = contacts().toMutableList().also { it.add(SupportContact(name, phone)) }
        prefs.edit().putString("contacts", list.joinToString(";;") { "${it.name}||${it.phone}" }).apply()
    }

    fun contacts(): List<SupportContact> {
        val raw = prefs.getString("contacts", "") ?: ""
        if (raw.isBlank()) return emptyList()
        return raw.split(";;").mapNotNull {
            val p = it.split("||", limit = 2)
            if (p.size == 2 && p[0].isNotBlank()) SupportContact(p[0], p[1]) else null
        }
    }

    fun removeContact(c: SupportContact) {
        val list = contacts().toMutableList().also { it.remove(c) }
        prefs.edit().putString("contacts", list.joinToString(";;") { "${it.name}||${it.phone}" }).apply()
    }

    // ---- Sponsors (tap-to-call list, same encoding as support contacts) ----
    fun sponsors(): List<SupportContact> {
        val raw = prefs.getString("sponsors", "") ?: ""
        if (raw.isBlank()) return emptyList()
        return raw.split(";;").mapNotNull {
            val p = it.split("||", limit = 2)
            if (p.size == 2 && p[0].isNotBlank()) SupportContact(p[0], p[1]) else null
        }
    }

    fun addSponsor(name: String, phone: String) {
        val list = sponsors().toMutableList().also { it.add(SupportContact(name, phone)) }
        prefs.edit().putString("sponsors", list.joinToString(";;") { "${it.name}||${it.phone}" }).apply()
    }

    fun removeSponsor(c: SupportContact) {
        val list = sponsors().toMutableList().also { it.remove(c) }
        prefs.edit().putString("sponsors", list.joinToString(";;") { "${it.name}||${it.phone}" }).apply()
    }

    // ---- Money saved tracker ----
    var drinksPerDay: Int
        get() = prefs.getInt("drinks_per_day", 0)
        set(v) = prefs.edit().putInt("drinks_per_day", v).apply()

    var alcoholType: String
        get() = prefs.getString("alcohol_type", "beer") ?: "beer"
        set(v) = prefs.edit().putString("alcohol_type", v).apply()

    var pricePerDrink: Float
        get() = prefs.getFloat("price_per_drink", 2.0f)
        set(v) = prefs.edit().putFloat("price_per_drink", v).apply()

    var spendPerDay: Float
        get() = prefs.getFloat("spend_per_day", 0f)
        set(v) = prefs.edit().putFloat("spend_per_day", v).apply()

    var drugName: String
        get() = prefs.getString("drug_name", "") ?: ""
        set(v) = prefs.edit().putString("drug_name", v).apply()

    fun moneyConfigured(): Boolean =
        if (alcoholType == "drugs") spendPerDay > 0 else drinksPerDay > 0

    fun moneySaved(days: Long): Double =
        if (alcoholType == "drugs") days * spendPerDay.toDouble()
        else days * drinksPerDay * pricePerDrink.toDouble()

    // ---- 12 Steps progress (step numbers 1..12) ----
    fun stepsDone(): Set<Int> =
        (prefs.getStringSet("steps_done", emptySet()) ?: emptySet())
            .mapNotNull { it.toIntOrNull() }.filter { it in 1..12 }.toSet()

    fun toggleStep(n: Int) {
        val cur = stepsDone().toMutableSet()
        if (n in cur) cur.remove(n) else cur.add(n)
        prefs.edit().putStringSet("steps_done", cur.map { it.toString() }.toSet()).apply()
    }

    fun quoteIndex(): Int = prefs.getInt("quote_idx", 0)
    fun nextQuote(total: Int) = prefs.edit().putInt("quote_idx", (quoteIndex() + 1) % total).apply()

    fun deleteEverything() = prefs.edit().clear().apply()
}

/** Center hours: Mon/Wed/Fri 8a–5p, Tue/Thu 8a–7p, closed weekends. */
fun openStatus(now: LocalDateTime = LocalDateTime.now(ZONE), s: AppStrings): String? {
    if (now.dayOfWeek == DayOfWeek.SATURDAY || now.dayOfWeek == DayOfWeek.SUNDAY) return null
    val close = if (now.dayOfWeek == DayOfWeek.TUESDAY || now.dayOfWeek == DayOfWeek.THURSDAY) 19 else 17
    return if (now.hour in 8 until close) {
        val t = LocalTime.of(close, 0).format(DateTimeFormatter.ofPattern("h:mm a"))
        "${s.openNowUntil} $t"
    } else null
}

fun greeting(now: LocalDateTime = LocalDateTime.now(ZONE), s: AppStrings): String = when (now.hour) {
    in 5..11 -> s.goodMorning
    in 12..17 -> s.goodAfternoon
    else -> s.goodEvening
}

fun localeFor(lang: String): Locale = if (lang == "es") Locale("es") else Locale.US

fun formatFullDate(date: LocalDate, lang: String): String =
    date.format(DateTimeFormatter.ofLocalizedDate(FormatStyle.FULL).withLocale(localeFor(lang)))

fun formatShortDateTime(dt: LocalDateTime, lang: String): String =
    dt.format(DateTimeFormatter.ofLocalizedDateTime(FormatStyle.MEDIUM, FormatStyle.SHORT).withLocale(localeFor(lang)))
