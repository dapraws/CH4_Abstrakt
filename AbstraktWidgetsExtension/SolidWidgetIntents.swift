import AppIntents
import Foundation

struct SmallSolidWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Solid Small Widget"
    static var description = IntentDescription("Displays a small solid color widget.")
    
    @Parameter(title: "Widget", query: SmallSavedWidgetQuery())
    var preset: SavedWidgetEntity?

    init() {}

    init(preset: SavedWidgetEntity) {
        self.preset = preset
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$preset)")
    }
}

struct MediumSolidWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Solid Medium Widget"
    static var description = IntentDescription("Displays a medium solid color widget.")
    
    @Parameter(title: "Widget", query: MediumSavedWidgetQuery())
    var preset: SavedWidgetEntity?

    init() {}

    init(preset: SavedWidgetEntity) {
        self.preset = preset
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$preset)")
    }
}

struct LargeSolidWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Solid Large Widget"
    static var description = IntentDescription("Displays a large solid color widget.")
    
    @Parameter(title: "Widget", query: LargeSavedWidgetQuery())
    var preset: SavedWidgetEntity?

    init() {}

    init(preset: SavedWidgetEntity) {
        self.preset = preset
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$preset)")
    }
}
