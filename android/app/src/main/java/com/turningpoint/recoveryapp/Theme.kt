package com.turningpoint.recoveryapp

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

val Cream = Color(0xFFF5F1E6)
val CardWhite = Color(0xFFFFFFFF)
val DeepTeal = Color(0xFF0E5B57)
val DeepTealDark = Color(0xFF0A4441)
val HelpOrange = Color(0xFFE4572E)
val HelpOrangeDark = Color(0xFFC7431F)
val WarmGray = Color(0xFF6B6455)
val SoftBorder = Color(0xFFE4DCC8)
val Gold = Color(0xFFC9962E)
val Danger = Color(0xFFB3261E)

private val RecoveryColors = lightColorScheme(
    primary = DeepTeal,
    onPrimary = Color.White,
    secondary = HelpOrange,
    background = Cream,
    surface = CardWhite,
    onBackground = Color(0xFF1F1B13),
    onSurface = Color(0xFF1F1B13),
    surfaceVariant = Color(0xFFEFE8D3),
)

private val RecoveryType = Typography(
    displaySmall = TextStyle(fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 28.sp, lineHeight = 34.sp),
    headlineSmall = TextStyle(fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 22.sp, lineHeight = 28.sp),
    titleLarge = TextStyle(fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 20.sp, lineHeight = 26.sp),
    titleMedium = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 16.sp, lineHeight = 22.sp),
    bodyLarge = TextStyle(fontSize = 16.sp, lineHeight = 24.sp),
    bodyMedium = TextStyle(fontSize = 14.sp, lineHeight = 20.sp),
    labelLarge = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 14.sp),
    labelSmall = TextStyle(fontWeight = FontWeight.Medium, fontSize = 12.sp),
)

@Composable
fun RecoveryTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = RecoveryColors, typography = RecoveryType, content = content)
}
