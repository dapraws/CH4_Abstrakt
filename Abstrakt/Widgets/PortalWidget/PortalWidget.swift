import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Render Snapshot

struct PortalWidgetSnapshot: Codable, Hashable {
    let date: Date
    let temperature: Int
    let placeName: String
    
    private var usesFahrenheit: Bool {
        UserDefaults(suiteName: "group.msaf.abstrakt")?.string(forKey: "settings.temperatureUnit") == "fahrenheit"
    }
    
    var displayTemperature: Int {
        guard usesFahrenheit else {
            return temperature
        }
        
        return Int((Double(temperature) * 9.0 / 5.0 + 32.0).rounded())
    }
}

// MARK: - App Shortcuts

enum PortalApp: String, AppEnum {
    case calendar
    case messages
    case music
    case maps
    case shortcuts
    case settings
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Portal App"
    
    static var caseDisplayRepresentations: [PortalApp: DisplayRepresentation] = [
        .calendar: "Calendar",
        .messages: "Messages",
        .music: "Music",
        .maps: "Maps",
        .shortcuts: "Shortcuts",
        .settings: "Settings",
    ]
    
    var title: String {
        switch self {
        case .calendar:
            "Calendar"
        case .messages:
            "Messages"
        case .music:
            "Music"
        case .maps:
            "Maps"
        case .shortcuts:
            "Shortcuts"
        case .settings:
            "Settings"
        }
    }
    
    var assetName: String {
        switch self {
        case .calendar:
            "calendar"
        case .messages:
            "messages"
        case .music:
            "music"
        case .maps:
            "maps"
        case .shortcuts:
            "shortcuts"
        case .settings:
            "settings"
        }
    }
    
    var launchURL: URL {
        switch self {
        case .calendar:
            URL(string: "calshow://")!
        case .messages:
            URL(string: "sms://")!
        case .music:
            URL(string: "music://")!
        case .maps:
            URL(string: "maps://?q=Denpasar")!
        case .shortcuts:
            URL(string: "shortcuts://")!
        case .settings:
            URL(string: "App-Prefs:root")!
        }
    }
}

struct OpenPortalCalendarIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Calendar"
    static var description = IntentDescription("Open Calendar from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.calendar.launchURL))
    }
}

struct OpenPortalMessagesIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Messages"
    static var description = IntentDescription("Open Messages from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.messages.launchURL))
    }
}

struct OpenPortalMusicIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Music"
    static var description = IntentDescription("Open Music from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.music.launchURL))
    }
}

struct OpenPortalMapsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Maps"
    static var description = IntentDescription("Open Maps from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.maps.launchURL))
    }
}

struct OpenPortalShortcutsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Shortcuts"
    static var description = IntentDescription("Open Shortcuts from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.shortcuts.launchURL))
    }
}

struct OpenPortalSettingsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Settings"
    static var description = IntentDescription("Open Settings from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.settings.launchURL))
    }
}

// MARK: - Widget

struct PortalWidget: View {
    private static let widgetCornerRadius: CGFloat = 30
    
    let snapshot: PortalWidgetSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var usesInteractiveButtons = false
    var clipsToWidgetShape = true
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        snapshot: PortalWidgetSnapshot = .placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        usesInteractiveButtons: Bool = false,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.usesInteractiveButtons = usesInteractiveButtons
        self.clipsToWidgetShape = clipsToWidgetShape
    }
    
    var body: some View {
        ZStack {
            palette.background
            
            GeometryReader { proxy in
                let metrics = PortalWidgetMetrics(size: proxy.size)
                
                VStack(alignment: .leading, spacing: metrics.verticalSpacing) {
                    header(metrics: metrics)
                    appCluster(metrics: metrics)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.top, metrics.topPadding)
                .padding(.bottom, metrics.bottomPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: clipsToWidgetShape ? Self.widgetCornerRadius : 0,
                style: .continuous
            )
        )
    }
    
    private func header(metrics: PortalWidgetMetrics) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 5) {
                Text("It's \(weekdayText),")
                    .foregroundStyle(palette.foreground)
                
                Text(dayOrdinalText)
                    .foregroundStyle(Color(red: 1, green: 0.38, blue: 0.62))
                
                Text(monthText)
                    .foregroundStyle(palette.foreground)
            }
            
            Text("\(snapshot.displayTemperature)° now in \(snapshot.placeName)")
                .foregroundStyle(palette.foreground)
        }
        .font(AbstraktWidgetFonts.font(.body, theme: fontTheme).weight(.bold))
        .lineLimit(1)
        .minimumScaleFactor(metrics.headerMinimumScale)
    }
    
    private func appCluster(metrics: PortalWidgetMetrics) -> some View {
        ZStack {
            portalIcon(.messages, metrics: metrics)
                .offset(x: -metrics.columnOffset, y: -metrics.rowOffset + visualYAxisCorrection(for: .messages, metrics: metrics))
                .rotationEffect(.degrees(4))
            
            portalIcon(.music, metrics: metrics)
                .offset(x: 0, y: -metrics.rowOffset + visualYAxisCorrection(for: .music, metrics: metrics))
                .rotationEffect(.degrees(-6))
            
            portalIcon(.maps, metrics: metrics)
                .offset(x: metrics.columnOffset, y: -metrics.rowOffset + visualYAxisCorrection(for: .maps, metrics: metrics))
                .rotationEffect(.degrees(4))
            
            portalIcon(.calendar, metrics: metrics)
                .offset(x: -metrics.columnOffset, y: metrics.rowOffset + visualYAxisCorrection(for: .calendar, metrics: metrics))
                .rotationEffect(.degrees(-4))

            portalIcon(.shortcuts, metrics: metrics)
                .offset(x: 0, y: metrics.rowOffset + visualYAxisCorrection(for: .shortcuts, metrics: metrics))
                .rotationEffect(.degrees(3))
            
            portalIcon(.settings, metrics: metrics)
                .offset(x: metrics.columnOffset, y: metrics.rowOffset + visualYAxisCorrection(for: .settings, metrics: metrics))
                .rotationEffect(.degrees(-5))
        }
        .frame(width: metrics.clusterWidth, height: metrics.clusterHeight)
        .padding(.top, metrics.clusterTopPadding)
    }

    private func visualYAxisCorrection(for app: PortalApp, metrics: PortalWidgetMetrics) -> CGFloat {
        switch app {
        case .music, .shortcuts:
            0
        case .messages:
            metrics.iconSize * 0.105
        case .maps:
            metrics.iconSize * -0.055
        case .calendar:
            metrics.iconSize * -0.045
        case .settings:
            metrics.iconSize * 0.08
        }
    }
    
    @ViewBuilder
    private func portalIcon(_ app: PortalApp, metrics: PortalWidgetMetrics) -> some View {
        let icon = Image(app.assetName)
            .resizable()
            .interpolation(.high)
            .scaledToFill()
            .frame(width: metrics.iconSize, height: metrics.iconSize)
            .clipShape(RoundedRectangle(cornerRadius: metrics.iconCornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: metrics.iconCornerRadius, style: .continuous))
            .accessibilityLabel(app.title)
        
        if usesInteractiveButtons {
            portalButton(for: app) {
                icon
            }
        } else {
            icon
        }
    }

    @ViewBuilder
    private func portalButton<Label: View>(for app: PortalApp, @ViewBuilder label: () -> Label) -> some View {
        switch app {
        case .calendar:
            Button(role: nil, intent: OpenPortalCalendarIntent(), label: label)
                .buttonStyle(.plain)
        case .messages:
            Button(role: nil, intent: OpenPortalMessagesIntent(), label: label)
                .buttonStyle(.plain)
        case .music:
            Button(role: nil, intent: OpenPortalMusicIntent(), label: label)
                .buttonStyle(.plain)
        case .maps:
            Button(role: nil, intent: OpenPortalMapsIntent(), label: label)
                .buttonStyle(.plain)
        case .shortcuts:
            Button(role: nil, intent: OpenPortalShortcutsIntent(), label: label)
                .buttonStyle(.plain)
        case .settings:
            Button(role: nil, intent: OpenPortalSettingsIntent(), label: label)
                .buttonStyle(.plain)
        }
    }
    
    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }
    
    private var weekdayText: String {
        snapshot.date.formatted(.dateTime.weekday(.wide))
    }
    
    private var dayOrdinalText: String {
        let day = Calendar.current.component(.day, from: snapshot.date)
        let suffix: String
        
        switch day {
        case 11, 12, 13:
            suffix = "th"
        default:
            switch day % 10 {
            case 1:
                suffix = "st"
            case 2:
                suffix = "nd"
            case 3:
                suffix = "rd"
            default:
                suffix = "th"
            }
        }
        
        return "\(day)\(suffix)"
    }
    
    private var monthText: String {
        snapshot.date.formatted(.dateTime.month(.wide))
    }
}

// MARK: - Layout Metrics

private struct PortalWidgetMetrics {
    let size: CGSize
    
    var horizontalPadding: CGFloat {
        clamped(size.width * 0.09, minimum: 15, maximum: 21)
    }
    
    var topPadding: CGFloat {
        clamped(size.height * 0.10, minimum: 15, maximum: 19)
    }
    
    var bottomPadding: CGFloat {
        clamped(size.height * 0.10, minimum: 11, maximum: 17)
    }
    
    var verticalSpacing: CGFloat {
        clamped(size.height * 0.06, minimum: 8, maximum: 11)
    }
    
    var headerMinimumScale: CGFloat {
        0.72
    }
    
    var iconSize: CGFloat {
        clamped(size.width * 0.34, minimum: 54, maximum: 58)
    }
    
    var iconCornerRadius: CGFloat {
        iconSize * 0.24
    }
    
    var clusterWidth: CGFloat {
        min(size.width - horizontalPadding * 2, iconSize * 2.5)
    }
    
    var clusterHeight: CGFloat {
        iconSize * 1.66
    }

    var columnOffset: CGFloat {
        iconSize * 0.68
    }

    var rowOffset: CGFloat {
        iconSize * 0.32
    }
    
    var clusterTopPadding: CGFloat {
        0
    }
}

private func clamped(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
    min(max(value, minimum), maximum)
}

// MARK: - Preview Data

extension PortalWidgetSnapshot {
    static let placeholder = PortalWidgetSnapshot(
        date: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 26, hour: 9, minute: 41)) ?? .now,
        temperature: 16,
        placeName: "Denpasar"
    )
}

#Preview("Portal Widget", traits: .fixedLayout(width: 170, height: 170)) {
    PortalWidget()
}
