package com.turningpoint.recoveryapp

import java.time.DayOfWeek

data class Quote(val textEn: String, val textEs: String)

val QUOTES = listOf(
    Quote("Yesterday you said tomorrow.", "Ayer dijiste mañana."),
    Quote("Recovery is possible — and you're living proof.", "La recuperación es posible, y tú eres la prueba viviente."),
    Quote("One day at a time.", "Un día a la vez."),
    Quote("You don't have to be perfect to be worthy of recovery.", "No tienes que ser perfecto para merecer la recuperación."),
    Quote("Courage is showing up, especially on the hard days.", "El valor es presentarse, especialmente en los días difíciles."),
    Quote("Every sunrise is a second chance.", "Cada amanecer es una segunda oportunidad."),
    Quote("Progress, not perfection.", "Progreso, no perfección."),
    Quote("You survived every hard day so far. That's a perfect record.", "Sobreviviste cada día difícil hasta ahora. Ese es un récord perfecto."),
    Quote("Ask for help. It's the bravest thing you'll do today.", "Pide ayuda. Es lo más valiente que harás hoy."),
    Quote("Small steps every day lead somewhere beautiful.", "Pequeños pasos cada día llevan a un lugar hermoso."),
    Quote("Your future self is cheering for you right now.", "Tu yo del futuro te está animando ahora mismo."),
    Quote("Healing isn't linear, but it is happening.", "Sanar no es lineal, pero está sucediendo."),
)

data class Meeting(val nameEn: String, val nameEs: String, val descEn: String, val descEs: String, val time: String, val hour24: Int, val minute: Int)

val WEEKLY_MEETINGS: Map<DayOfWeek, List<Meeting>> = mapOf(
    DayOfWeek.MONDAY to listOf(
        Meeting("Morning Meditation", "Meditación matutina", "Start the day grounded", "Comienza el día con calma", "8:00 AM", 8, 0),
        Meeting("Narcotics Anonymous", "Narcóticos Anónimos", "12-step fellowship", "Comunidad de 12 pasos", "12:00 PM", 12, 0),
        Meeting("Alcoholics Anonymous", "Alcohólicos Anónimos", "12-step fellowship", "Comunidad de 12 pasos", "4:00 PM", 16, 0),
    ),
    DayOfWeek.TUESDAY to listOf(
        Meeting("Morning Meditation", "Meditación matutina", "Start the day grounded", "Comienza el día con calma", "8:00 AM", 8, 0),
        Meeting("Medication Assisted Recovery Anonymous", "Recuperación Anónima con Medicación", "For MAT journeys", "Para caminos con MAT", "12:00 PM", 12, 0),
        Meeting("Narcotics Anonymous", "Narcóticos Anónimos", "12-step fellowship", "Comunidad de 12 pasos", "6:00 PM", 18, 0),
    ),
    DayOfWeek.WEDNESDAY to listOf(
        Meeting("Morning Meditation", "Meditación matutina", "Start the day grounded", "Comienza el día con calma", "8:00 AM", 8, 0),
        Meeting("Narcotics Anonymous", "Narcóticos Anónimos", "12-step fellowship", "Comunidad de 12 pasos", "12:00 PM", 12, 0),
        Meeting("LGBTQ+ All Recovery", "Recuperación LGBTQ+", "An affirming space", "Un espacio afirmativo", "4:00 PM", 16, 0),
        Meeting("Young People in Recovery (YPR)", "Jóvenes en Recuperación", "For young people in recovery", "Para jóvenes en recuperación", "8:00 PM", 20, 0),
    ),
    DayOfWeek.THURSDAY to listOf(
        Meeting("Morning Meditation", "Meditación matutina", "Start the day grounded", "Comienza el día con calma", "8:00 AM", 8, 0),
        Meeting("SMART Recovery", "SMART Recovery", "Science-based tools", "Herramientas basadas en ciencia", "12:00 PM", 12, 0),
        Meeting("Narcotics Anonymous", "Narcóticos Anónimos", "12-step fellowship", "Comunidad de 12 pasos", "6:00 PM", 18, 0),
    ),
    DayOfWeek.FRIDAY to listOf(
        Meeting("Morning Meditation", "Meditación matutina", "Start the day grounded", "Comienza el día con calma", "8:00 AM", 8, 0),
        Meeting("Narcotics Anonymous", "Narcóticos Anónimos", "12-step fellowship", "Comunidad de 12 pasos", "12:00 PM", 12, 0),
        Meeting("StrongHER Women's All-Recovery Group", "StrongHER Mujeres en Recuperación", "Women's group", "Grupo de mujeres", "6:00 PM", 18, 0),
    ),
)

data class Service(val en: String, val es: String)

val SERVICES = listOf(
    Service("Recovery coaching & support", "Acompañamiento y apoyo en recuperación"),
    Service("Resume & job searching", "Currículum y búsqueda de empleo"),
    Service("Resources & referrals", "Recursos y referencias"),
    Service("On-site computer lab", "Laboratorio de computación"),
    Service("Veterans support", "Apoyo a veteranos"),
    Service("Relapse refocus", "Reenfoque tras recaída"),
    Service("Overdose response", "Respuesta a sobredosis"),
    Service("Community outreach", "Alcance comunitario"),
    Service("Telephone recovery support", "Apoyo telefónico en recuperación"),
    Service("Speaking engagements", "Charlas y presentaciones"),
)

data class Milestone(val days: Long, val labelEn: String, val labelEs: String)

val MILESTONES = listOf(
    Milestone(1, "24 hours", "24 horas"),
    Milestone(30, "30 days", "30 días"),
    Milestone(60, "60 days", "60 días"),
    Milestone(90, "90 days", "90 días"),
    Milestone(182, "6 months", "6 meses"),
    Milestone(273, "9 months", "9 meses"),
    Milestone(365, "1 year", "1 año"),
    Milestone(547, "18 months", "18 meses"),
    Milestone(730, "2 years", "2 años"),
    Milestone(1095, "3 years", "3 años"),
    Milestone(1460, "4 years", "4 años"),
    Milestone(1825, "5 years", "5 años"),
)

data class TwelveStep(val en: String, val es: String)

val TWELVE_STEPS = listOf(
    TwelveStep(
        "We admitted we were powerless over our addiction — that our lives had become unmanageable.",
        "Admitimos que éramos impotentes ante nuestra adicción, que nuestras vidas se habían vuelto ingobernables."),
    TwelveStep(
        "Came to believe that a Power greater than ourselves could restore us to sanity.",
        "Llegamos a creer que un Poder superior a nosotros mismos podría devolvernos el sano juicio."),
    TwelveStep(
        "Made a decision to turn our will and our lives over to the care of God as we understood Him.",
        "Decidimos poner nuestras voluntades y nuestras vidas al cuidado de Dios, como nosotros lo concebimos."),
    TwelveStep(
        "Made a searching and fearless moral inventory of ourselves.",
        "Sin miedo hicimos un minucioso inventario moral de nosotros mismos."),
    TwelveStep(
        "Admitted to God, to ourselves, and to another human being the exact nature of our wrongs.",
        "Admitimos ante Dios, ante nosotros mismos, y ante otro ser humano, la naturaleza exacta de nuestros defectos."),
    TwelveStep(
        "Were entirely ready to have God remove all these defects of character.",
        "Estuvimos enteramente dispuestos a dejar que Dios nos liberase de nuestros defectos."),
    TwelveStep(
        "Humbly asked Him to remove our shortcomings.",
        "Humildemente le pedimos que nos liberase de nuestros defectos."),
    TwelveStep(
        "Made a list of all persons we had harmed, and became willing to make amends to them all.",
        "Hicimos una lista de todas aquellas personas a quienes habíamos ofendido y estuvimos dispuestos a reparar el daño que les causamos."),
    TwelveStep(
        "Made direct amends to such people wherever possible, except when to do so would injure them or others.",
        "Reparamos directamente a cuantos nos fue posible el daño causado, excepto cuando el hacerlo implicaba perjuicio para ellos o para otros."),
    TwelveStep(
        "Continued to take personal inventory and when we were wrong promptly admitted it.",
        "Continuamos haciendo nuestro inventario personal y cuando nos equivocábamos lo admitíamos inmediatamente."),
    TwelveStep(
        "Sought through prayer and meditation to improve our conscious contact with God as we understood Him, praying only for knowledge of His will for us and the power to carry that out.",
        "Buscamos a través de la oración y la meditación mejorar nuestro contacto consciente con Dios, como nosotros lo concebimos, pidiéndole solamente que nos dejase conocer su voluntad para con nosotros y nos diese la fortaleza para cumplirla."),
    TwelveStep(
        "Having had a spiritual awakening as the result of these steps, we tried to carry this message to addicts, and to practice these principles in all our affairs.",
        "Habiendo obtenido un despertar espiritual como resultado de estos pasos, tratamos de llevar este mensaje a otros adictos y de practicar estos principios en todos nuestros asuntos."),
)

/** Default average USD price per drink by type (user-editable in the app). */
fun defaultDrinkPrice(type: String): Float = when (type) {
    "wine" -> 3.5f
    "liquor" -> 4.5f
    else -> 2.0f // beer
}
