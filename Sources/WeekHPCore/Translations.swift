// SPDX-License-Identifier: GPL-2.0-or-later
//
// The app has no bundle to hold .strings files, so the texts it shows live
// here. English texts are the keys, like the gettext calls of the GNOME
// extension. The Settings window texts come from the Cinnamon applet
// (asterion/week-hp-cinnamon) and its translations.

import Foundation

public struct Translations: Sendable {
    /// Language used, from the first of the user's preferred languages that is supported
    public let language: String

    private static let tables: [String: [String: String]] = [
        "es": [
            "Mon": "Lun",
            "Tue": "Mar",
            "Wed": "Mié",
            "Thu": "Jue",
            "Fri": "Vie",
            "Sat": "Sáb",
            "Sun": "Dom",
            "GOAL!": "¡META!",
            "%@ %d%%": "%@ %d%%",
            "%d%%": "%d%%",
            "About Week HP": "Acerca de Week HP",
            "Settings…": "Ajustes…",
            "Quit Week HP": "Salir de Week HP",
            "Compact Mode": "Modo compacto",
            "Compact mode": "Modo compacto",
            "Hide the text next to the bar: the day and the percentage show up when you hover over it.":
                "Oculta el texto junto a la barra: el día y el porcentaje aparecen al pasar el puntero sobre ella.",
            "Official macOS port of Week HP by asterion.": "Port oficial para macOS de Week HP, de asterion.",

            "Week HP Settings": "Ajustes de Week HP",
            "Work schedule": "Horario de trabajo",
            "Work days per week": "Días laborales por semana",
            "Number of segments in the bar. 5 means Monday to Friday.":
                "Cantidad de segmentos de la barra. 5 significa de lunes a viernes.",
            "Day starts at": "El día empieza a las",
            "Before this hour a day counts as empty. Use 00:00 to count from midnight.":
                "Antes de esta hora el día cuenta como vacío. Usa 00:00 para contar desde la medianoche.",
            "Day is complete at": "El día se completa a las",
            "After this hour a day counts as full. Use 24:00 to count until midnight.":
                "Después de esta hora el día cuenta como completo. Usa 24:00 para contar hasta la medianoche.",
            "Last work day ends at": "El último día laboral termina a las",
            "The weekly goal is reached at this hour on the last work day (Friday by default). Keep it later than the day start hour.":
                "La meta semanal se alcanza a esta hora del último día laboral (el viernes, por defecto). Debe ser posterior a la hora de inicio del día.",
            "Bar appearance": "Apariencia de la barra",
            "Segment width": "Ancho de los segmentos",
            "Width of each day segment in the bar.": "Ancho del segmento de cada día en la barra.",
            "Turns yellow at": "Cambia a amarillo al",
            "Total weekly progress where the bar changes from red to yellow. Keep it below the green threshold.":
                "Avance total de la semana en el que la barra pasa de rojo a amarillo. Debe ser menor que el umbral del verde.",
            "Turns green at": "Cambia a verde al",
            "Total weekly progress where the bar changes to green. Keep it above the yellow threshold.":
                "Avance total de la semana en el que la barra cambia a verde. Debe ser mayor que el umbral del amarillo.",
            "Colors": "Colores",
            "Fill color: low progress": "Color de relleno: avance bajo",
            "Color of the fill while progress is below the yellow threshold.":
                "Color del relleno mientras el avance está bajo el umbral del amarillo.",
            "Fill color: mid progress": "Color de relleno: avance medio",
            "Color of the fill between the yellow and green thresholds.":
                "Color del relleno entre los umbrales del amarillo y del verde.",
            "Fill color: high progress": "Color de relleno: avance alto",
            "Color of the fill from the green threshold until the goal.":
                "Color del relleno desde el umbral del verde hasta la meta.",
            "Goal color": "Color de la meta",
            "Color of the star and the GOAL! message when the week is complete.":
                "Color de la estrella y del mensaje ¡META! cuando la semana está completa.",
            "Restore default values": "Restaurar valores por defecto",
            "Set every option back to its original value: schedule, bar appearance and colors.":
                "Devuelve todas las opciones a su valor original: horario, apariencia de la barra y colores.",
        ],
        "fr": [
            "Mon": "Lun",
            "Tue": "Mar",
            "Wed": "Mer",
            "Thu": "Jeu",
            "Fri": "Ven",
            "Sat": "Sam",
            "Sun": "Dim",
            "GOAL!": "OBJECTIF !",
            "%@ %d%%": "%@ %d %%",
            "%d%%": "%d %%",
            "About Week HP": "À propos de Week HP",
            "Settings…": "Réglages…",
            "Quit Week HP": "Quitter Week HP",
            "Compact Mode": "Mode compact",
            "Compact mode": "Mode compact",
            "Hide the text next to the bar: the day and the percentage show up when you hover over it.":
                "Masque le texte à côté de la barre : le jour et le pourcentage s’affichent au survol.",
            "Official macOS port of Week HP by asterion.": "Portage officiel pour macOS de Week HP, par asterion.",

            "Week HP Settings": "Réglages de Week HP",
            "Work schedule": "Horaires de travail",
            "Work days per week": "Jours travaillés par semaine",
            "Number of segments in the bar. 5 means Monday to Friday.":
                "Nombre de segments de la barre. 5 signifie du lundi au vendredi.",
            "Day starts at": "La journée commence à",
            "Before this hour a day counts as empty. Use 00:00 to count from midnight.":
                "Avant cette heure, la journée compte comme vide. Utilisez 00:00 pour compter à partir de minuit.",
            "Day is complete at": "La journée est complète à",
            "After this hour a day counts as full. Use 24:00 to count until midnight.":
                "Après cette heure, la journée compte comme complète. Utilisez 24:00 pour compter jusqu’à minuit.",
            "Last work day ends at": "Le dernier jour travaillé se termine à",
            "The weekly goal is reached at this hour on the last work day (Friday by default). Keep it later than the day start hour.":
                "L’objectif de la semaine est atteint à cette heure le dernier jour travaillé (le vendredi par défaut). Elle doit être postérieure à l’heure de début de journée.",
            "Bar appearance": "Apparence de la barre",
            "Segment width": "Largeur des segments",
            "Width of each day segment in the bar.": "Largeur du segment de chaque jour dans la barre.",
            "Turns yellow at": "Passe au jaune à",
            "Total weekly progress where the bar changes from red to yellow. Keep it below the green threshold.":
                "Progression totale de la semaine à laquelle la barre passe du rouge au jaune. Elle doit rester inférieure au seuil du vert.",
            "Turns green at": "Passe au vert à",
            "Total weekly progress where the bar changes to green. Keep it above the yellow threshold.":
                "Progression totale de la semaine à laquelle la barre passe au vert. Elle doit rester supérieure au seuil du jaune.",
            "Colors": "Couleurs",
            "Fill color: low progress": "Couleur de remplissage : progression faible",
            "Color of the fill while progress is below the yellow threshold.":
                "Couleur du remplissage tant que la progression est sous le seuil du jaune.",
            "Fill color: mid progress": "Couleur de remplissage : progression moyenne",
            "Color of the fill between the yellow and green thresholds.":
                "Couleur du remplissage entre les seuils du jaune et du vert.",
            "Fill color: high progress": "Couleur de remplissage : progression élevée",
            "Color of the fill from the green threshold until the goal.":
                "Couleur du remplissage du seuil du vert jusqu’à l’objectif.",
            "Goal color": "Couleur de l’objectif",
            "Color of the star and the GOAL! message when the week is complete.":
                "Couleur de l’étoile et du message OBJECTIF ! quand la semaine est terminée.",
            "Restore default values": "Restaurer les valeurs par défaut",
            "Set every option back to its original value: schedule, bar appearance and colors.":
                "Rétablit toutes les options à leur valeur d’origine : horaires, apparence de la barre et couleurs.",
        ],
    ]

    public init(preferredLanguages: [String] = Locale.preferredLanguages) {
        // "es-CL" → "es", "zh-Hans-CN" → "zh"
        let codes = preferredLanguages.map {
            $0.split(whereSeparator: { $0 == "-" || $0 == "_" }).first.map { $0.lowercased() } ?? ""
        }
        language = codes.first { $0 == "en" || Self.tables[$0] != nil } ?? "en"
    }

    public func callAsFunction(_ text: String) -> String {
        Self.tables[language]?[text] ?? text
    }

    private static let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    /// Text shown next to the bar, e.g. "Wed 46%", or "GOAL!" once the week is complete.
    public func status(for progress: WeekProgress) -> String {
        guard !progress.isComplete, let today = progress.today else {
            return self("GOAL!")
        }
        return status(day: today, percent: progress.percent)
    }

    /// The widest texts `status(for:)` can return: every day with a two-digit
    /// percentage (it never reaches 100 before the goal) and the goal itself.
    public var longestStatusTexts: [String] {
        Self.dayNames.indices.map { status(day: $0, percent: 88) } + [self("GOAL!")]
    }

    /// Number of work days and the days they cover, e.g. "5 (Mon–Fri)".
    public func workDays(_ count: Int) -> String {
        let first = self(Self.dayNames[0])
        guard count > 1 else {
            return "\(count) (\(first))"
        }
        return "\(count) (\(first)–\(self(Self.dayNames[min(count, Self.dayNames.count) - 1])))"
    }

    /// A percentage, e.g. "40%" ("40 %" in French).
    public func percentage(_ value: Int) -> String {
        String(format: self("%d%%"), value)
    }

    /// An hour of the day as a clock time, e.g. 8.5 → "08:30". 24 is "24:00", the end of the day.
    public static func clockTime(_ hours: Double) -> String {
        let minutes = Int((hours * 60).rounded())
        return String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    private func status(day: Int, percent: Int) -> String {
        String(format: self("%@ %d%%"), self(Self.dayNames[day]), percent)
    }
}
