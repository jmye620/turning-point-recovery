import Foundation

/// Every user-visible string in the app, in one place — mirrors the Android
/// AppStrings so both apps stay in lockstep. The in-app EN/ES toggle switches
/// between `en` and `es` at runtime.
struct AppStrings {
    // Tabs
    let tabToday: String, tabCheckIn: String, tabCounter: String
    let tabMeetings: String, tabResources: String, tabEvents: String
    // Header / global
    let appName: String, getHelp: String, language: String
    let crisisTitle: String, crisisSubtitle: String
    let crisisCallNow: String, crisisCallLine: String, crisisCall988: String
    let crisisText988: String, crisisCenter: String, crisisCenterHours: String
    let crisis911: String, crisis911Note: String
    let crisisWhat988: String, crisisWhat988Body: String
    let crisisWorried: String, crisisWorriedBody: String
    let crisisTryBreathing: String
    let supportContacts: String, contactNameHint: String, contactPhoneHint: String
    let addContact: String, call: String, text: String, remove: String
    let close: String
    // Footer
    let needHelpNow: String, privacyNote: String, deleteEverything: String
    let deleteConfirmTitle: String, deleteConfirmBody: String
    let deleteConfirmYes: String, cancel: String, deletedToast: String
    let programOf: String
    // Today
    let goodMorning: String, goodAfternoon: String, goodEvening: String
    let openNowUntil: String, closedNow: String, comingUpNext: String
    let todaysInspiration: String, anotherOne: String
    let nextMeeting: String, atTheCenter: String, seeFullSchedule: String
    let whatDoYouNeed: String
    let shortcutCheckIn: String, shortcutCheckInSub: String
    let shortcutCounter: String, shortcutCounterSub: String
    let shortcutCoping: String, shortcutCopingSub: String
    let shortcutHelp: String, shortcutHelpSub: String
    let seeAllEvents: String
    // Check-in
    let checkInTitle: String, checkInSubtitle: String
    let moodLabel: String, cravingsLabel: String, gratitudeLabel: String
    let gratitudeHint: String, callSomeoneLabel: String
    let yes: String, no: String, completeCheckIn: String
    let checkInDoneTitle: String, checkInDoneBody: String
    let tryBoxBreathing: String, seeTodaysMeetings: String, startNewCheckIn: String
    let recentCheckIns: String, dayStreak: String, daysStreak: String
    let journalTitle: String, journalHint: String, saveEntry: String, delete: String
    let feeling: String, cravings: String, gratefulFor: String
    let moodGreat: String, moodGood: String, moodOkay: String
    let moodLow: String, moodStruggling: String
    let cravingsNone: String, cravingsMild: String, cravingsStrong: String
    let completeAllFields: String
    // Counter
    let counterTitle: String, counterSubtitle: String, cleanDateLabel: String
    let startCounter: String, daysOfRecovery: String
    let currentChip: String, nextMilestone: String, inDays: String
    let shareMilestone: String, saveImage: String, changeDate: String, save: String
    let shareCleanTime: String
    let chipNote: String, milestoneTzNote: String
    let shareCardTitle: String, shareCardSubtitle: String, shareCardTag: String
    let year: String, years: String, month: String, months: String, day: String, days: String
    // Meetings
    let meetingsTitle: String, meetingsSub: String, freeNoSignup: String
    let centerPhoneLabel: String
    let todayBadge: String, addToCalendar: String
    let noMeetingsSaturday: String, schedulesChangeNote: String
    let takeBackDayTitle: String, takeBackDayWhen: String, takeBackDayWhere: String
    let takeBackDayBody: String
    // Resources
    let copingTools: String
    let boxBreathing: String, boxBreathingBody: String, start: String, stop: String
    let breatheIn: String, breatheHold: String, breatheOut: String, roundOf: String
    let grounding: String, groundingBody: String
    let groundingSee: String, groundingTouch: String, groundingHear: String
    let groundingSmell: String, groundingTaste: String
    let halt: String, haltBody: String
    let haltHungry: String, haltHungryTip: String
    let haltAngry: String, haltAngryTip: String
    let haltLonely: String, haltLonelyTip: String
    let haltTired: String, haltTiredTip: String
    let urgeSurfing: String, urgeSurfingBody: String
    let urgePhaseRise: String, urgePhasePeak: String, urgePhaseFall: String
    let urgeNeedSomeone: String
    let callSomeoneTitle: String, callSomeoneBody: String, callTurningPoint: String
    let writeItOut: String, writeItOutBody: String, writeHint: String, clearPage: String
    let freeServices: String, freeServicesNote: String
    let podcastTitle: String, podcastBody: String
    let visitCenter: String, visitAddress: String, visitEnter: String
    let hoursTitle: String, callTheCenter: String, website: String
    // Events
    let eventsTitle: String, eventsSubtitle: String
    let halloweenTitle: String, halloweenWhen: String, halloweenWhere: String, halloweenBody: String
}

let en = AppStrings(
    tabToday: "Today", tabCheckIn: "Check-in", tabCounter: "Counter",
    tabMeetings: "Meetings", tabResources: "Resources", tabEvents: "Events",
    appName: "Turning Point", getHelp: "Get help", language: "ES",
    crisisTitle: "Crisis help", crisisSubtitle: "You don't have to face this moment alone. Reach out — right now.",
    crisisCallNow: "I need support right now", crisisCallLine: "Call the 24-hour line",
    crisisCall988: "Call 988", crisisText988: "Text 988",
    crisisCenter: "Turning Point Center", crisisCenterHours: "Call during business hours to talk with a peer support specialist",
    crisis911: "Call 911", crisis911Note: "If you or someone near you is in immediate danger.",
    crisisWhat988: "What happens when you call 988?",
    crisisWhat988Body: "You'll reach the 988 Suicide & Crisis Lifeline — free, confidential, 24/7. Help is available in English and Spanish. A trained counselor will listen and help you stay safe.",
    crisisWorried: "Worried about someone else?",
    crisisWorriedBody: "You can call 988 for guidance on supporting a loved one, or call the 24-hour line any time.",
    crisisTryBreathing: "Try box breathing",
    supportContacts: "My support contacts", contactNameHint: "Name", contactPhoneHint: "Phone",
    addContact: "Add contact", call: "Call", text: "Text", remove: "Remove", close: "Close",
    needHelpNow: "Need help now?", privacyNote: "Your check-ins, journal, support contacts, and clean date are saved on this phone only — nothing is sent anywhere.",
    deleteEverything: "Delete everything saved on this phone",
    deleteConfirmTitle: "Delete everything?",
    deleteConfirmBody: "This will permanently erase your check-ins, journal entries, support contacts, and clean date from this phone. This cannot be undone.",
    deleteConfirmYes: "Yes, delete everything", cancel: "Cancel", deletedToast: "Everything was deleted.",
    programOf: "A program of Four Rivers Behavioral Health",
    goodMorning: "Good morning", goodAfternoon: "Good afternoon", goodEvening: "Good evening",
    openNowUntil: "Open now · until", closedNow: "Closed right now", comingUpNext: "Coming up next",
    todaysInspiration: "Today's inspiration", anotherOne: "Another one",
    nextMeeting: "Next meeting", atTheCenter: "at the center", seeFullSchedule: "See the full schedule",
    whatDoYouNeed: "What do you need today?",
    shortcutCheckIn: "Daily check-in", shortcutCheckInSub: "A one-minute pause with yourself",
    shortcutCounter: "My recovery counter", shortcutCounterSub: "See how far you've come",
    shortcutCoping: "Coping tools", shortcutCopingSub: "Breathing, grounding & more",
    shortcutHelp: "Get help now", shortcutHelpSub: "Crisis lines, 24/7",
    seeAllEvents: "See all events",
    checkInTitle: "Daily check-in", checkInSubtitle: "One honest minute with yourself.",
    moodLabel: "How are you feeling?", cravingsLabel: "How strong are your cravings?",
    gratitudeLabel: "What's one thing you're grateful for?", gratitudeHint: "Type here…",
    callSomeoneLabel: "Do you have someone you can call today?",
    yes: "Yes", no: "No", completeCheckIn: "Complete my check-in",
    checkInDoneTitle: "Hold onto this feeling.",
    checkInDoneBody: "Good days are built one honest day at a time.",
    tryBoxBreathing: "Try box breathing", seeTodaysMeetings: "See today's meetings", startNewCheckIn: "Start a new check-in",
    recentCheckIns: "Your recent check-ins", dayStreak: "day in a row", daysStreak: "days in a row",
    journalTitle: "Daily journal", journalHint: "A few honest lines…", saveEntry: "Save entry", delete: "Delete",
    feeling: "Feeling", cravings: "Cravings", gratefulFor: "Grateful for",
    moodGreat: "Great", moodGood: "Good", moodOkay: "Okay", moodLow: "Low", moodStruggling: "Struggling",
    cravingsNone: "None", cravingsMild: "Mild", cravingsStrong: "Strong",
    completeAllFields: "Please answer each question to complete your check-in.",
    counterTitle: "Recovery counter", counterSubtitle: "One day at a time.", cleanDateLabel: "Your clean date",
    startCounter: "Start my counter", daysOfRecovery: "days of recovery",
    currentChip: "Current chip", nextMilestone: "Next", inDays: "in",
    shareMilestone: "Share your milestone", saveImage: "Save image", changeDate: "Change date", save: "Save",
    shareCleanTime: "Share your clean time",
    chipNote: "Chip traditions differ by fellowship — this is one common set.",
    milestoneTzNote: "Milestones are marked at midnight in your time zone.",
    shareCardTitle: "Congratulations!", shareCardSubtitle: "One day at a time.",
    shareCardTag: "TURNING POINT RECOVERY · PADUCAH, KY",
    year: "year", years: "years", month: "month", months: "months", day: "day", days: "days",
    meetingsTitle: "Meetings this week", meetingsSub: "All at the Paducah center · 415 Broadway",
    freeNoSignup: "Free, no sign-up.", todayBadge: "Today", addToCalendar: "Add to calendar",
    centerPhoneLabel: "Community Center · 270.444.3621",
    noMeetingsSaturday: "No meetings scheduled. If you need support today, the 24-hour crisis line is always open.",
    schedulesChangeNote: "Schedules can change on holidays — call 270.444.3621 to confirm.",
    takeBackDayTitle: "National Drug Take Back Day", takeBackDayWhen: "Sat Oct 24, 2026 · 10 a.m.–2 p.m.",
    takeBackDayWhere: "Turning Point Center",
    takeBackDayBody: "Bring unused or expired medications for safe, anonymous disposal. No questions asked.",
    copingTools: "Coping tools",
    boxBreathing: "Box breathing", boxBreathingBody: "Four counts in, four held, four out, four held. Calms your nervous system in about two minutes.",
    start: "Start", stop: "Stop",
    breatheIn: "Breathe in", breatheHold: "Hold", breatheOut: "Breathe out", roundOf: "Round",
    grounding: "5-4-3-2-1 grounding", groundingBody: "Name what you notice, out loud if you can. It pulls your mind back into the room.",
    groundingSee: "things you can see", groundingTouch: "things you can touch",
    groundingHear: "things you can hear", groundingSmell: "things you can smell", groundingTaste: "thing you can taste",
    halt: "The HALT check", haltBody: "Pause and ask: am I Hungry, Angry, Lonely, or Tired? Meet the need before it becomes a craving.",
    haltHungry: "Hungry", haltHungryTip: "Eat something. Drink water.",
    haltAngry: "Angry", haltAngryTip: "Move your body. Talk it out.",
    haltLonely: "Lonely", haltLonelyTip: "Call someone. Come to the center.",
    haltTired: "Tired", haltTiredTip: "Rest. Exhaustion whispers lies.",
    urgeSurfing: "Urge surfing", urgeSurfingBody: "A craving is a wave: it rises, peaks, and falls — usually within 20 minutes. Ride it out.",
    urgePhaseRise: "The wave is rising. Notice where you feel it in your body.",
    urgePhasePeak: "This is the peak. Breathe through it — it won't stay here.",
    urgePhaseFall: "The wave is falling. You're riding it out. Keep going.",
    urgeNeedSomeone: "Need someone before that?",
    callSomeoneTitle: "Call someone", callSomeoneBody: "Don't isolate. Call your sponsor, a peer, or the center — someone who gets it.",
    callTurningPoint: "Call Turning Point",
    writeItOut: "Write it out", writeItOutBody: "Get it out of your head and onto the page. No one's reading this — it vanishes when you leave.",
    writeHint: "Write it out…", clearPage: "Clear the page",
    freeServices: "Free services at Turning Point", freeServicesNote: "Everything listed here is offered at no cost to the community.",
    podcastTitle: "Crosstalk Recovery Podcast", podcastBody: "Stories and conversations from the recovery community. Ask at the front desk or call 270.444.3621 to listen.",
    visitCenter: "Visit the center", visitAddress: "415 Broadway, Paducah, KY 42001",
    visitEnter: "Enter on Broadway or through the Zone in the rear parking lot.",
    hoursTitle: "Hours", callTheCenter: "Call the center", website: "Website",
    eventsTitle: "Events", eventsSubtitle: "Come as you are. Bring a friend.",
    halloweenTitle: "Join us for Halloween Bash!", halloweenWhen: "Wed Oct 21, 2026 · 5:00–8:00 PM",
    halloweenWhere: "Maiden Alley Cinema, Paducah",
    halloweenBody: "Costumes, candy, and community. A family-friendly night at Maiden Alley Cinema."
)

let es = AppStrings(
    tabToday: "Hoy", tabCheckIn: "Registro", tabCounter: "Contador",
    tabMeetings: "Reuniones", tabResources: "Recursos", tabEvents: "Eventos",
    appName: "Turning Point", getHelp: "Ayuda", language: "EN",
    crisisTitle: "Ayuda en crisis", crisisSubtitle: "No tienes que enfrentar este momento a solas. Comunícate — ahora mismo.",
    crisisCallNow: "Necesito apoyo ahora mismo", crisisCallLine: "Llama a la línea 24 horas",
    crisisCall988: "Llama al 988", crisisText988: "Envía un texto al 988",
    crisisCenter: "Centro Turning Point", crisisCenterHours: "Llama en horario de oficina para hablar con un especialista en apoyo entre pares",
    crisis911: "Llama al 911", crisis911Note: "Si tú o alguien cercano está en peligro inmediato.",
    crisisWhat988: "¿Qué pasa cuando llamas al 988?",
    crisisWhat988Body: "Te comunicarás con la Línea 988 de Prevención del Suicidio y Crisis — gratuita, confidencial, 24/7. Hay ayuda en inglés y español. Un consejero capacitado te escuchará y te ayudará a mantenerte a salvo.",
    crisisWorried: "¿Preocupado por otra persona?",
    crisisWorriedBody: "Puedes llamar al 988 para recibir orientación sobre cómo apoyar a un ser querido, o llamar a la línea 24 horas en cualquier momento.",
    crisisTryBreathing: "Prueba la respiración en caja",
    supportContacts: "Mis contactos de apoyo", contactNameHint: "Nombre", contactPhoneHint: "Teléfono",
    addContact: "Agregar contacto", call: "Llamar", text: "Texto", remove: "Eliminar", close: "Cerrar",
    needHelpNow: "¿Necesitas ayuda ahora?", privacyNote: "Tus registros, diario, contactos de apoyo y fecha de inicio se guardan solo en este teléfono — nada se envía a ningún lado.",
    deleteEverything: "Borrar todo lo guardado en este teléfono",
    deleteConfirmTitle: "¿Borrar todo?",
    deleteConfirmBody: "Esto borrará permanentemente tus registros, entradas del diario, contactos de apoyo y fecha de inicio de este teléfono. No se puede deshacer.",
    deleteConfirmYes: "Sí, borrar todo", cancel: "Cancelar", deletedToast: "Todo fue borrado.",
    programOf: "Un programa de Four Rivers Behavioral Health",
    goodMorning: "Buenos días", goodAfternoon: "Buenas tardes", goodEvening: "Buenas noches",
    openNowUntil: "Abierto ahora · hasta las", closedNow: "Cerrado en este momento", comingUpNext: "Próximamente",
    todaysInspiration: "Inspiración de hoy", anotherOne: "Otra",
    nextMeeting: "Próxima reunión", atTheCenter: "en el centro", seeFullSchedule: "Ver el horario completo",
    whatDoYouNeed: "¿Qué necesitas hoy?",
    shortcutCheckIn: "Registro diario", shortcutCheckInSub: "Un minuto de pausa contigo",
    shortcutCounter: "Mi contador de recuperación", shortcutCounterSub: "Mira lo lejos que has llegado",
    shortcutCoping: "Herramientas de apoyo", shortcutCopingSub: "Respiración, conexión a tierra y más",
    shortcutHelp: "Obtén ayuda ahora", shortcutHelpSub: "Líneas de crisis, 24/7",
    seeAllEvents: "Ver todos los eventos",
    checkInTitle: "Registro diario", checkInSubtitle: "Un minuto honesto contigo.",
    moodLabel: "¿Cómo te sientes?", cravingsLabel: "¿Qué tan fuertes son tus antojos?",
    gratitudeLabel: "¿Por qué estás agradecido hoy?", gratitudeHint: "Escribe aquí…",
    callSomeoneLabel: "¿Tienes a alguien a quien llamar hoy?",
    yes: "Sí", no: "No", completeCheckIn: "Completar mi registro",
    checkInDoneTitle: "Aferrate a este sentimiento.",
    checkInDoneBody: "Los buenos días se construyen un día honesto a la vez.",
    tryBoxBreathing: "Prueba la respiración en caja", seeTodaysMeetings: "Ver las reuniones de hoy", startNewCheckIn: "Iniciar un nuevo registro",
    recentCheckIns: "Tus registros recientes", dayStreak: "día seguido", daysStreak: "días seguidos",
    journalTitle: "Diario", journalHint: "Unas líneas honestas…", saveEntry: "Guardar entrada", delete: "Eliminar",
    feeling: "Ánimo", cravings: "Antojos", gratefulFor: "Agradecido por",
    moodGreat: "Genial", moodGood: "Bien", moodOkay: "Más o menos", moodLow: "Bajo", moodStruggling: "Luchando",
    cravingsNone: "Ninguno", cravingsMild: "Leves", cravingsStrong: "Fuertes",
    completeAllFields: "Responde cada pregunta para completar tu registro.",
    counterTitle: "Contador de recuperación", counterSubtitle: "Un día a la vez.", cleanDateLabel: "Tu fecha de inicio",
    startCounter: "Iniciar mi contador", daysOfRecovery: "días de recuperación",
    currentChip: "Ficha actual", nextMilestone: "Próxima", inDays: "en",
    shareMilestone: "Comparte tu logro", saveImage: "Guardar imagen", changeDate: "Cambiar fecha", save: "Guardar",
    shareCleanTime: "Comparte tu tiempo de recuperación",
    chipNote: "Las tradiciones de fichas varían según la comunidad — este es un conjunto común.",
    milestoneTzNote: "Los logros se marcan a la medianoche en tu zona horaria.",
    shareCardTitle: "¡Felicidades!", shareCardSubtitle: "Un día a la vez.",
    shareCardTag: "TURNING POINT RECOVERY · PADUCAH, KY",
    year: "año", years: "años", month: "mes", months: "meses", day: "día", days: "días",
    meetingsTitle: "Reuniones de esta semana", meetingsSub: "Todas en el centro de Paducah · 415 Broadway",
    freeNoSignup: "Gratis, sin inscripción.", todayBadge: "Hoy", addToCalendar: "Agregar al calendario",
    centerPhoneLabel: "Centro comunitario · 270.444.3621",
    noMeetingsSaturday: "No hay reuniones programadas. Si necesitas apoyo hoy, la línea de crisis 24 horas siempre está abierta.",
    schedulesChangeNote: "Los horarios pueden cambiar en días festivos — llama al 270.444.3621 para confirmar.",
    takeBackDayTitle: "Día Nacional de Devolución de Medicamentos", takeBackDayWhen: "Sáb 24 oct 2026 · 10 a.m.–2 p.m.",
    takeBackDayWhere: "Centro Turning Point",
    takeBackDayBody: "Trae medicamentos sin usar o vencidos para desecharlos de forma segura y anónima. Sin preguntas.",
    copingTools: "Herramientas de apoyo",
    boxBreathing: "Respiración en caja", boxBreathingBody: "Cuatro tiempos inhalando, cuatro sosteniendo, cuatro exhalando, cuatro sosteniendo. Calma tu sistema nervioso en unos dos minutos.",
    start: "Comenzar", stop: "Detener",
    breatheIn: "Inhala", breatheHold: "Sostén", breatheOut: "Exhala", roundOf: "Ronda",
    grounding: "Conexión a tierra 5-4-3-2-1", groundingBody: "Nombra lo que notes, en voz alta si puedes. Devuelve tu mente a la habitación.",
    groundingSee: "cosas que puedes ver", groundingTouch: "cosas que puedes tocar",
    groundingHear: "cosas que puedes oír", groundingSmell: "cosas que puedes oler", groundingTaste: "cosa que puedes saborear",
    halt: "La revisión HALT", haltBody: "Haz una pausa y pregúntate: ¿tengo Hambre, estoy Enojado, Solo o cansado (Tired)? Atiende la necesidad antes de que se convierta en antojo.",
    haltHungry: "Hambre", haltHungryTip: "Come algo. Toma agua.",
    haltAngry: "Enojo", haltAngryTip: "Mueve tu cuerpo. Habla de ello.",
    haltLonely: "Soledad", haltLonelyTip: "Llama a alguien. Ven al centro.",
    haltTired: "Cansancio", haltTiredTip: "Descansa. El agotamiento susurra mentiras.",
    urgeSurfing: "Surfea el impulso", urgeSurfingBody: "Un antojo es una ola: sube, alcanza su punto máximo y baja — generalmente en 20 minutos. Déjala pasar.",
    urgePhaseRise: "La ola está subiendo. Nota dónde la sientes en tu cuerpo.",
    urgePhasePeak: "Este es el punto máximo. Respira — no se quedará aquí.",
    urgePhaseFall: "La ola está bajando. La estás superando. Sigue adelante.",
    urgeNeedSomeone: "¿Necesitas a alguien antes?",
    callSomeoneTitle: "Llama a alguien", callSomeoneBody: "No te aísles. Llama a tu padrino, a un compañero o al centro — alguien que lo entienda.",
    callTurningPoint: "Llama a Turning Point",
    writeItOut: "Escríbelo", writeItOutBody: "Sácalo de tu cabeza y ponlo en la página. Nadie lo está leyendo — desaparece cuando te vas.",
    writeHint: "Escríbelo…", clearPage: "Borrar la página",
    freeServices: "Servicios gratuitos en Turning Point", freeServicesNote: "Todo lo aquí listado se ofrece sin costo a la comunidad.",
    podcastTitle: "Pódcast Crosstalk Recovery", podcastBody: "Historias y conversaciones de la comunidad de recuperación. Pregunta en recepción o llama al 270.444.3621 para escuchar.",
    visitCenter: "Visita el centro", visitAddress: "415 Broadway, Paducah, KY 42001",
    visitEnter: "Entra por Broadway o por la Zona en el estacionamiento trasero.",
    hoursTitle: "Horario", callTheCenter: "Llama al centro", website: "Sitio web",
    eventsTitle: "Eventos", eventsSubtitle: "Ven como eres. Trae a un amigo.",
    halloweenTitle: "¡Únete a la fiesta de Halloween!", halloweenWhen: "Mié 21 oct 2026 · 5:00–8:00 PM",
    halloweenWhere: "Maiden Alley Cinema, Paducah",
    halloweenBody: "Disfraces, dulces y comunidad. Una noche familiar en Maiden Alley Cinema."
)
