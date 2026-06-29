import AppIntents
import Foundation

enum SolidWidgetSelection {
    static let choose = "Choose"

    static func optionNames(size: String) -> [String] {
        let names = WidgetSharedStore.savedPresets(size: size).map(\.name)
        return [choose] + names
    }

    static func widgetID(for name: String, size: String) -> String? {
        guard name != choose else {
            return nil
        }

        return WidgetSharedStore.savedPresets(size: size).first { $0.name == name }?.widgetID
    }
}

struct SmallSolidWidgetOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        SolidWidgetSelection.optionNames(size: "small")
    }
}

struct MediumSolidWidgetOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        SolidWidgetSelection.optionNames(size: "medium")
    }
}

struct LargeSolidWidgetOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        SolidWidgetSelection.optionNames(size: "large")
    }
}

struct SmallSolidWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Small Widget"
    static var description = IntentDescription("Choose one saved small widget from your Abstrakt library.")

    @Parameter(title: "Widget", optionsProvider: SmallSolidWidgetOptionsProvider())
    var currentWidget: String?

    init() {
        currentWidget = SolidWidgetSelection.choose
    }

    init(currentWidget: String?) {
        self.currentWidget = currentWidget
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$currentWidget)")
    }
}

struct MediumSolidWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Medium Widget"
    static var description = IntentDescription("Choose one saved medium widget from your Abstrakt library.")

    @Parameter(title: "Widget", optionsProvider: MediumSolidWidgetOptionsProvider())
    var currentWidget: String?

    init() {
        currentWidget = SolidWidgetSelection.choose
    }

    init(currentWidget: String?) {
        self.currentWidget = currentWidget
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$currentWidget)")
    }
}

struct LargeSolidWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Large Widget"
    static var description = IntentDescription("Choose one saved large widget from your Abstrakt library.")

    @Parameter(title: "Widget", optionsProvider: LargeSolidWidgetOptionsProvider())
    var currentWidget: String?

    init() {
        currentWidget = SolidWidgetSelection.choose
    }

    init(currentWidget: String?) {
        self.currentWidget = currentWidget
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$currentWidget)")
    }
}
