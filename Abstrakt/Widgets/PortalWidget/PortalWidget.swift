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

enum PortalApp: String, AppEnum, Codable, Identifiable {
    case calls
    case calendar
    case activity
    case books
    case faceTime
    case findMy
    case mail
    case messages
    case music
    case maps
    case photos
    case safari
    case shortcuts
    case settings
    case store
    case translate

    var id: String { rawValue }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Portal App"
    
    static var caseDisplayRepresentations: [PortalApp: DisplayRepresentation] = [
        .calls: "Phone",
        .calendar: "Calendar",
        .activity: "Activity",
        .books: "Books",
        .faceTime: "FaceTime",
        .findMy: "Find My",
        .mail: "Mail",
        .messages: "Messages",
        .music: "Music",
        .maps: "Maps",
        .photos: "Photos",
        .safari: "Safari",
        .shortcuts: "Shortcuts",
        .settings: "Settings",
        .store: "App Store",
        .translate: "Translate",
    ]

    static let availableApps: [PortalApp] = [
        .calls,
        .messages,
        .shortcuts,
        .settings,
        .activity,
        .music,
        .books,
        .calendar,
        .faceTime,
        .findMy,
        .mail,
        .photos,
        .maps,
        .safari,
        .store,
        .translate,
    ]

    static let defaultSelection: [PortalApp] = [
        .messages,
        .music,
        .maps,
        .calendar,
        .shortcuts,
        .settings,
    ]

    static func selection(from storedValue: String?) -> [PortalApp] {
        let apps = (storedValue ?? "")
            .split(separator: ",")
            .compactMap { PortalApp(rawValue: String($0)) }
            .uniqued()

        guard apps.count == 6 else {
            return defaultSelection
        }

        return apps
    }

    static func storageValue(for apps: [PortalApp]) -> String {
        apps.prefix(6).map(\.rawValue).joined(separator: ",")
    }
    
    var title: String {
        switch self {
        case .calls:
            "Phone"
        case .calendar:
            "Calendar"
        case .activity:
            "Activity"
        case .books:
            "Books"
        case .faceTime:
            "FaceTime"
        case .findMy:
            "Find My"
        case .mail:
            "Mail"
        case .messages:
            "Messages"
        case .music:
            "Music"
        case .maps:
            "Maps"
        case .photos:
            "Photos"
        case .safari:
            "Safari"
        case .shortcuts:
            "Shortcuts"
        case .settings:
            "Settings"
        case .store:
            "App Store"
        case .translate:
            "Translate"
        }
    }
    
    var assetName: String {
        switch self {
        case .calls:
            "calls"
        case .calendar:
            "calendar"
        case .activity:
            "fitness"
        case .books:
            "books"
        case .faceTime:
            "facetime"
        case .findMy:
            "find-my"
        case .mail:
            "mail"
        case .messages:
            "messages"
        case .music:
            "music"
        case .maps:
            "maps"
        case .photos:
            "photos"
        case .safari:
            "safari"
        case .shortcuts:
            "shortcuts"
        case .settings:
            "settings"
        case .store:
            "store"
        case .translate:
            "translate"
        }
    }
    
    var launchURL: URL {
        switch self {
        case .calls:
            URL(string: "tel://")!
        case .calendar:
            URL(string: "calshow://")!
        case .activity:
            URL(string: "fitnessapp://")!
        case .books:
            URL(string: "ibooks://")!
        case .faceTime:
            URL(string: "facetime://")!
        case .findMy:
            URL(string: "findmy://")!
        case .mail:
            URL(string: "message://")!
        case .messages:
            URL(string: "sms://")!
        case .music:
            URL(string: "music://")!
        case .maps:
            URL(string: "maps://?q=Denpasar")!
        case .photos:
            URL(string: "photos-redirect://")!
        case .safari:
            URL(string: "https://www.apple.com")!
        case .shortcuts:
            URL(string: "shortcuts://")!
        case .settings:
            URL(string: "App-Prefs:root")!
        case .store:
            URL(string: "itms-apps://apps.apple.com")!
        case .translate:
            URL(string: "translate://")!
        }
    }
}

enum PortalIconClipStyle: String, CaseIterable, Identifiable, Codable, Hashable {
    case `default`
    case circle
    case bloom

    var id: String { rawValue }

    static func from(id: String?) -> PortalIconClipStyle {
        PortalIconClipStyle(rawValue: id ?? "") ?? .default
    }

    var title: String {
        switch self {
        case .default:
            "Default"
        case .circle:
            "Circle"
        case .bloom:
            "Bloom"
        }
    }

    var systemImage: String {
        switch self {
        case .default:
            "app"
        case .circle:
            "circle"
        case .bloom:
            "seal"
        }
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

struct OpenPortalCalendarIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Calendar"
    static var description = IntentDescription("Open Calendar from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.calendar.launchURL))
    }
}

struct OpenPortalCallsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Phone"
    static var description = IntentDescription("Open Phone from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.calls.launchURL))
    }
}

struct OpenPortalActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Activity"
    static var description = IntentDescription("Open Activity from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.activity.launchURL))
    }
}

struct OpenPortalBooksIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Books"
    static var description = IntentDescription("Open Books from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.books.launchURL))
    }
}

struct OpenPortalFaceTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "Open FaceTime"
    static var description = IntentDescription("Open FaceTime from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.faceTime.launchURL))
    }
}

struct OpenPortalFindMyIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Find My"
    static var description = IntentDescription("Open Find My from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.findMy.launchURL))
    }
}

struct OpenPortalMailIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Mail"
    static var description = IntentDescription("Open Mail from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.mail.launchURL))
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

struct OpenPortalPhotosIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Photos"
    static var description = IntentDescription("Open Photos from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.photos.launchURL))
    }
}

struct OpenPortalSafariIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Safari"
    static var description = IntentDescription("Open Safari from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.safari.launchURL))
    }
}

struct OpenPortalShortcutsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Shortcuts"
    static var description = IntentDescription("Open Shortcuts from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.shortcuts.launchURL))
    }
}

struct OpenPortalStoreIntent: AppIntent {
    static var title: LocalizedStringResource = "Open App Store"
    static var description = IntentDescription("Open App Store from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.store.launchURL))
    }
}

struct OpenPortalTranslateIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Translate"
    static var description = IntentDescription("Open Translate from the Portal widget.")

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(PortalApp.translate.launchURL))
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
    let selectedApps: [PortalApp]
    let iconClipStyle: PortalIconClipStyle
    var usesInteractiveButtons = false
    var clipsToWidgetShape = true
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        snapshot: PortalWidgetSnapshot = .placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        selectedApps: [PortalApp] = PortalApp.defaultSelection,
        iconClipStyle: PortalIconClipStyle = .default,
        usesInteractiveButtons: Bool = false,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.selectedApps = Array(selectedApps.prefix(6))
        self.iconClipStyle = iconClipStyle
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
            ForEach(Array(displayApps.enumerated()), id: \.element.rawValue) { index, app in
                portalIcon(app, metrics: metrics)
                    .offset(iconOffset(index: index, metrics: metrics))
                    .rotationEffect(.degrees(iconRotation(index: index)))
            }
        }
        .frame(width: metrics.clusterWidth, height: metrics.clusterHeight)
        .padding(.top, metrics.clusterTopPadding)
    }

    private var displayApps: [PortalApp] {
        let apps = selectedApps.uniqued()
        guard apps.count == 6 else {
            return PortalApp.defaultSelection
        }

        return apps
    }

    private func iconOffset(index: Int, metrics: PortalWidgetMetrics) -> CGSize {
        let column = index % 3
        let row = index / 3
        let x: CGFloat

        switch column {
        case 0:
            x = -metrics.columnOffset
        case 1:
            x = 0
        default:
            x = metrics.columnOffset
        }

        let baseY = row == 0 ? -metrics.rowOffset : metrics.rowOffset
        return CGSize(
            width: x,
            height: baseY + visualYAxisCorrection(index: index, metrics: metrics)
        )
    }

    private func iconRotation(index: Int) -> Double {
        let rotations: [Double] = [4, -6, 4, -4, 3, -5]
        return rotations[min(index, rotations.count - 1)]
    }

    private func visualYAxisCorrection(index: Int, metrics: PortalWidgetMetrics) -> CGFloat {
        let corrections: [CGFloat] = [0.105, 0, -0.055, -0.045, 0, 0.08]
        return metrics.iconSize * corrections[min(index, corrections.count - 1)]
    }
    
    @ViewBuilder
    private func portalIcon(_ app: PortalApp, metrics: PortalWidgetMetrics) -> some View {
        let icon = Image(app.assetName)
            .resizable()
            .interpolation(.high)
            .scaledToFill()
            .frame(width: metrics.iconSize, height: metrics.iconSize)
            .clipShape(PortalIconShape(style: iconClipStyle, cornerRadius: metrics.iconCornerRadius))
            .contentShape(PortalIconShape(style: iconClipStyle, cornerRadius: metrics.iconCornerRadius))
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
        case .calls:
            Button(role: nil, intent: OpenPortalCallsIntent(), label: label)
                .buttonStyle(.plain)
        case .calendar:
            Button(role: nil, intent: OpenPortalCalendarIntent(), label: label)
                .buttonStyle(.plain)
        case .activity:
            Button(role: nil, intent: OpenPortalActivityIntent(), label: label)
                .buttonStyle(.plain)
        case .books:
            Button(role: nil, intent: OpenPortalBooksIntent(), label: label)
                .buttonStyle(.plain)
        case .faceTime:
            Button(role: nil, intent: OpenPortalFaceTimeIntent(), label: label)
                .buttonStyle(.plain)
        case .findMy:
            Button(role: nil, intent: OpenPortalFindMyIntent(), label: label)
                .buttonStyle(.plain)
        case .mail:
            Button(role: nil, intent: OpenPortalMailIntent(), label: label)
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
        case .photos:
            Button(role: nil, intent: OpenPortalPhotosIntent(), label: label)
                .buttonStyle(.plain)
        case .safari:
            Button(role: nil, intent: OpenPortalSafariIntent(), label: label)
                .buttonStyle(.plain)
        case .shortcuts:
            Button(role: nil, intent: OpenPortalShortcutsIntent(), label: label)
                .buttonStyle(.plain)
        case .settings:
            Button(role: nil, intent: OpenPortalSettingsIntent(), label: label)
                .buttonStyle(.plain)
        case .store:
            Button(role: nil, intent: OpenPortalStoreIntent(), label: label)
                .buttonStyle(.plain)
        case .translate:
            Button(role: nil, intent: OpenPortalTranslateIntent(), label: label)
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

struct PortalIconShape: Shape {
    let style: PortalIconClipStyle
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        switch style {
        case .default:
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .path(in: rect)
        case .circle:
            Circle().path(in: rect)
        case .bloom:
            bloomPath(in: rect)
        }
    }

    private func bloomPath(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) * 0.43
        let petalDepth = baseRadius * 0.05
        let steps = 160

        var path = Path()

        for step in 0...steps {
            let angle = (Double(step) / Double(steps)) * Double.pi * 2
            let radius = baseRadius + cos(angle * 10) * petalDepth
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )

            if step == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
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
