import SwiftUI
import WidgetKit

struct GradientSnapshot: Codable, Hashable {
    let date: Date
    let cityName: String
    let temperature: Int
    let highTemperature: Int
    let lowTemperature: Int
    let conditionCode: String
    let conditionDescription: String

    init(
        date: Date = .now,
        cityName: String = "London",
        temperature: Int = 9,
        highTemperature: Int = 12,
        lowTemperature: Int = 6,
        conditionCode: String = "rain",
        conditionDescription: String = "rain and chilly weather ahead."
    ) {
        self.date = date
        self.cityName = cityName
        self.temperature = temperature
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.conditionCode = conditionCode
        self.conditionDescription = conditionDescription
    }

    var sentence: String {
        let city = cityName.isEmpty ? "London" : cityName
        let desc = conditionDescription.isEmpty ? "chilly weather ahead." : conditionDescription
        let cleanDesc = desc.hasPrefix("with ") ? String(desc.dropFirst(5)) : desc
        return "\(city) is \(temperature)°C today, with \(cleanDesc)"
    }

    static let placeholder = GradientSnapshot(
        date: .now,
        cityName: "London",
        temperature: 9,
        highTemperature: 12,
        lowTemperature: 6,
        conditionCode: "rain",
        conditionDescription: "rain and chilly weather ahead."
    )
}

// Backward-compatibility alias
typealias WeatherEditorialSnapshot = GradientSnapshot

struct GradientWidget: View {
    private static let widgetCornerRadius: CGFloat = 22

    let snapshot: GradientSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    let gradientTheme: GradientTheme
    var clipsToWidgetShape = true

    init(
        snapshot: GradientSnapshot = .placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        gradientTheme: GradientTheme = .defaultTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.gradientTheme = gradientTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    var body: some View {
        ZStack {
            blobBackground

            GeometryReader { proxy in
                if proxy.size.width > 220 {
                    mediumContent
                } else {
                    smallContent
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: clipsToWidgetShape ? Self.widgetCornerRadius : 0,
                style: .continuous
            )
        )
        .containerBackground(for: .widget) {
            blobBackground
        }
    }

    // MARK: - Typography & Text Palette

    private var primaryTextColor: Color {
        Color.white
    }

    private var secondaryTextColor: Color {
        Color.white.opacity(0.60)
    }

    private var textShadowColor: Color {
        Color.black.opacity(0.45)
    }

    // MARK: - Small Layout

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)

            editorialSentenceText
                .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                .lineSpacing(2)
                .minimumScaleFactor(0.75)
                .lineLimit(5)
                .multilineTextAlignment(.leading)
                .shadow(color: textShadowColor, radius: 3, x: 0, y: 1)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
    }

    // MARK: - Medium Layout

    private var mediumContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(snapshot.cityName)
                    .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                    .foregroundStyle(primaryTextColor)

                Spacer()

                let hLabel = Text("H: ").foregroundStyle(secondaryTextColor)
                let hVal = Text("\(snapshot.highTemperature)°").foregroundStyle(primaryTextColor)
                let lLabel = Text("  L: ").foregroundStyle(secondaryTextColor)
                let lVal = Text("\(snapshot.lowTemperature)°").foregroundStyle(primaryTextColor)

                Text("\(hLabel)\(hVal)\(lLabel)\(lVal)")
                    .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
            }
            .shadow(color: Color.black.opacity(0.40), radius: 3, x: 0, y: 1)

            Spacer(minLength: 0)

            editorialSentenceText
                .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                .lineSpacing(3)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.leading)
                .shadow(color: textShadowColor, radius: 3, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(18)
    }

    // MARK: - Multi-Part Styled Editorial Sentence

    private var editorialSentenceText: Text {
        let city = snapshot.cityName.isEmpty ? "London" : snapshot.cityName
        var desc = snapshot.conditionDescription.isEmpty ? "chilly weather ahead." : snapshot.conditionDescription
        if desc.lowercased().hasPrefix("with ") {
            desc = String(desc.dropFirst(5))
        }

        let condition: String
        let suffix: String

        if let range = desc.range(of: " ahead", options: .caseInsensitive) {
            condition = String(desc[..<range.lowerBound])
            suffix = String(desc[range.lowerBound...])
        } else {
            condition = desc
            suffix = ""
        }

        let cityText = Text(city).foregroundStyle(primaryTextColor)
        let isText = Text(" is ").foregroundStyle(secondaryTextColor)
        let tempText = Text("\(snapshot.temperature)°C").foregroundStyle(primaryTextColor)
        let todayText = Text(" today, with ").foregroundStyle(secondaryTextColor)
        let conditionText = Text(condition).foregroundStyle(primaryTextColor)
        let suffixText = suffix.isEmpty ? Text("") : Text(suffix).foregroundStyle(secondaryTextColor)

        return Text("\(cityText)\(isText)\(tempText)\(todayText)\(conditionText)\(suffixText)")
    }

    // MARK: - Natural Organic Aurora Blob Background with Subtle Grain

    @ViewBuilder
    private var blobBackground: some View {
        GeometryReader { proxy in
            let w = max(0, proxy.size.width)
            let h = max(0, proxy.size.height)

            ZStack {
                if gradientTheme == .sunsetAmber {
                    // MARK: - Dark Obsidian with Bottom Contour Light Flare
                    amberBottomLightBackground(width: w, height: h)
                } else if gradientTheme == .fractalPrism {
                    // MARK: - Pleated Fractal Prism Gradient
                    fractalPrismBackground(width: w, height: h)
                } else {
                    // MARK: - Multi-Layer Planetary Aurora
                    standardAuroraBackground(width: w, height: h)
                }

                // Tactile Subtle Micro-Grain Texture (Delicate, soft paper-like grain)
                Image(uiImage: GrainTextureGenerator.sharedImage)
                    .resizable(resizingMode: .tile)
                    .blendMode(.overlay)
                    .opacity(0.07)
                    .allowsHitTesting(false)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private func standardAuroraBackground(width w: CGFloat, height h: CGFloat) -> some View {
        // Theme Base Linear Gradient
        LinearGradient(
            colors: gradientTheme.baseGradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Top-Left Soft Atmospheric Glow
        Circle()
            .fill(gradientTheme.topLeftGlow)
            .frame(width: w * 1.10, height: h * 1.10)
            .offset(x: -w * 0.25, y: -h * 0.25)
            .blur(radius: 55)

        // Radiant Glowing Mid-Field
        Circle()
            .fill(gradientTheme.midFieldGlow)
            .frame(width: w * 1.20, height: h * 1.20)
            .offset(x: -w * 0.08, y: 0)
            .blur(radius: 48)

        // Soft Luminous Highlight Arc
        Ellipse()
            .fill(gradientTheme.highlightArc)
            .frame(width: w * 1.15, height: h * 0.75)
            .rotationEffect(.degrees(-32))
            .offset(x: w * 0.05, y: -h * 0.05)
            .blur(radius: 45)

        // Halo Transition Rim
        Circle()
            .fill(gradientTheme.haloTransition)
            .frame(width: w * 1.35, height: h * 1.35)
            .offset(x: w * 0.35, y: h * 0.32)
            .blur(radius: 45)

        // Bottom-Right Deep Horizon Silhouette Dome
        Circle()
            .fill(gradientTheme.bottomRightDome)
            .frame(width: w * 1.25, height: h * 1.25)
            .offset(x: w * 0.40, y: h * 0.38)
            .blur(radius: 42)
    }

    @ViewBuilder
    private func fractalPrismBackground(width w: CGFloat, height h: CGFloat) -> some View {
        // Chromatic Iridescent wide fluted glass / prism texture
        let slatCount = max(8, Int((w / 18.0).rounded()))
        let slatWidth = w / CGFloat(slatCount)

        ZStack {
            // Layer 1: Smooth atmospheric dark midnight-indigo obsidian base gradient
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.03, green: 0.02, blue: 0.07), location: 0.0),
                    .init(color: Color(red: 0.05, green: 0.04, blue: 0.12), location: 0.30),
                    .init(color: Color(red: 0.08, green: 0.06, blue: 0.18), location: 0.65),
                    .init(color: Color(red: 0.14, green: 0.09, blue: 0.24), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Layer 2: Multi-Spectral Iridescent Dispersion Blooms (Violet, Cyan, Rose)
            Circle()
                .fill(Color(red: 0.45, green: 0.18, blue: 0.75).opacity(0.35))
                .frame(width: w * 0.95, height: h * 0.95)
                .offset(x: -w * 0.15, y: -h * 0.20)
                .blur(radius: 45)

            Circle()
                .fill(Color(red: 0.10, green: 0.65, blue: 0.80).opacity(0.28))
                .frame(width: w * 0.85, height: h * 0.85)
                .offset(x: w * 0.20, y: -h * 0.05)
                .blur(radius: 40)

            Circle()
                .fill(Color(red: 0.88, green: 0.28, blue: 0.58).opacity(0.32))
                .frame(width: w * 0.90, height: h * 0.90)
                .offset(x: w * 0.25, y: h * 0.30)
                .blur(radius: 42)

            // Layer 3: 3D Fluted Glass / Reeded Prism Texture with Spectral Dispersion
            HStack(spacing: 0) {
                ForEach(0..<slatCount, id: \.self) { index in
                    let progress = CGFloat(index) / CGFloat(max(1, slatCount - 1))
                    let refractionTint: Color = {
                        if progress < 0.33 {
                            return Color(red: 0.60, green: 0.25, blue: 0.90).opacity(0.06)
                        } else if progress < 0.66 {
                            return Color(red: 0.15, green: 0.75, blue: 0.85).opacity(0.06)
                        } else {
                            return Color(red: 0.95, green: 0.35, blue: 0.65).opacity(0.06)
                        }
                    }()

                    ZStack {
                        refractionTint

                        // Fluted 3D cylinder bevel: Deep shadow groove on left, subtle specular highlight ridge on right
                        LinearGradient(
                            stops: [
                                .init(color: Color.black.opacity(0.06), location: 0.0),
                                .init(color: Color.black.opacity(0.10), location: 0.08),
                                .init(color: Color.clear, location: 0.22),
                                .init(color: Color.white.opacity(0.03), location: 0.78),
                                .init(color: Color.white.opacity(0.08), location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                    .frame(width: slatWidth, height: h)
                }
            }

            // Layer 4: Subtle ambient chromatic diagonal reflection band
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.55, green: 0.20, blue: 0.85).opacity(0.08), location: 0.15),
                    .init(color: Color(red: 0.15, green: 0.70, blue: 0.85).opacity(0.08), location: 0.50),
                    .init(color: Color(red: 0.90, green: 0.30, blue: 0.60).opacity(0.08), location: 0.85)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .blendMode(.plusLighter)
        }
        .frame(width: w, height: h)
    }

    @ViewBuilder
    private func amberBottomLightBackground(width w: CGFloat, height h: CGFloat) -> some View {
        AmberBlobBackgroundView()
    }
}

// MARK: - Amber Blob Background View

public struct AmberBlobBackgroundView: View {
    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            let w = max(0, proxy.size.width)
            let h = max(0, proxy.size.height)
            let isWide = w > 220 || (h > 0 && w / h > 1.4)

            ZStack {
                // Pitch obsidian canvas
                Color(red: 0.04, green: 0.04, blue: 0.05)

                // Layer 0a: Atmospheric diffuse under-bleed along bottom shelf (deep smokey glow)
                AmberAtmosphericWaveShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.88, green: 0.30, blue: 0.02).opacity(isWide ? 0.88 : 0.85), location: 0.0),
                                .init(color: Color(red: 0.65, green: 0.18, blue: 0.01).opacity(isWide ? 0.60 : 0.55), location: 0.45),
                                .init(color: Color(red: 0.40, green: 0.10, blue: 0.01).opacity(0.30), location: 0.75),
                                .init(color: Color.clear, location: 1.0)
                            ],
                            startPoint: .bottomTrailing,
                            endPoint: .leading
                        )
                    )
                    .frame(width: w, height: h)
                    .blur(radius: max(22, h * (isWide ? 0.18 : 0.16)))

                // Layer 0b: Atmospheric diffuse under-bleed along right flank (deep smokey glow)
                AmberFlamePlumeShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.92, green: 0.35, blue: 0.02).opacity(isWide ? 0.90 : 0.85), location: 0.0),
                                .init(color: Color(red: 0.70, green: 0.20, blue: 0.01).opacity(isWide ? 0.62 : 0.55), location: 0.45),
                                .init(color: Color(red: 0.42, green: 0.10, blue: 0.01).opacity(0.30), location: 0.75),
                                .init(color: Color.clear, location: 1.0)
                            ],
                            startPoint: .bottomTrailing,
                            endPoint: .topTrailing
                        )
                    )
                    .frame(width: w, height: h)
                    .blur(radius: max(22, h * (isWide ? 0.18 : 0.16)))

                // Layer 1: Core bottom edge shelf bleeding leftward with corner hook
                AmberAtmosphericWaveShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.95, green: 0.40, blue: 0.04).opacity(0.96), location: 0.0),
                                .init(color: Color(red: 0.82, green: 0.28, blue: 0.02).opacity(0.74), location: 0.38),
                                .init(color: Color(red: 0.58, green: 0.16, blue: 0.01).opacity(0.48), location: 0.70),
                                .init(color: Color(red: 0.42, green: 0.10, blue: 0.01).opacity(0.24), location: 0.88),
                                .init(color: Color.clear, location: 1.0)
                            ],
                            startPoint: .bottomTrailing,
                            endPoint: .leading
                        )
                    )
                    .frame(width: w, height: h)
                    .blur(radius: max(12, h * (isWide ? 0.11 : 0.09)))

                // Layer 2: Core right flank plume bleeding upward, thick at bottom and tapering at top
                AmberFlamePlumeShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.96, green: 0.44, blue: 0.04).opacity(0.96), location: 0.0),
                                .init(color: Color(red: 0.84, green: 0.30, blue: 0.02).opacity(0.74), location: 0.35),
                                .init(color: Color(red: 0.60, green: 0.18, blue: 0.01).opacity(0.48), location: 0.68),
                                .init(color: Color(red: 0.42, green: 0.10, blue: 0.01).opacity(0.24), location: 0.88),
                                .init(color: Color.clear, location: 1.0)
                            ],
                            startPoint: .bottomTrailing,
                            endPoint: .topTrailing
                        )
                    )
                    .frame(width: w, height: h)
                    .blur(radius: max(12, h * (isWide ? 0.11 : 0.09)))

                // Layer 3: Corner origin bulb where both arms meet
                AmberFloatingCloudBlobShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.98, green: 0.54, blue: 0.08).opacity(0.78),
                                Color(red: 0.80, green: 0.24, blue: 0.02).opacity(0.30),
                                Color.clear
                            ],
                            center: .init(x: 0.95, y: 0.92),
                            startRadius: 0,
                            endRadius: isWide ? max(w, h) * 0.42 : max(w, h) * 0.32
                        )
                    )
                    .frame(width: w, height: h)
                    .blur(radius: max(10, h * 0.08))

                // Layer 4: Radiant warm amber-gold energy core at origin
                AmberRadiantCoreBlobShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.98, green: 0.62, blue: 0.12).opacity(0.82), location: 0.0),
                                .init(color: Color(red: 0.90, green: 0.30, blue: 0.02).opacity(0.50), location: 0.55),
                                .init(color: Color.clear, location: 0.85)
                            ],
                            startPoint: .bottomTrailing,
                            endPoint: .topLeading
                        )
                    )
                    .frame(width: w, height: h)
                    .blur(radius: max(7, h * 0.055))

                // Layer 5: Incandescent golden filament core at corner origin (dimmed slightly, remains brightest)
                AmberIncandescentCoreShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 1.00, green: 0.86, blue: 0.48).opacity(0.84), location: 0.0),
                                .init(color: Color(red: 0.98, green: 0.60, blue: 0.15).opacity(0.58), location: 0.60),
                                .init(color: Color.clear, location: 0.90)
                            ],
                            startPoint: .bottomTrailing,
                            endPoint: .topLeading
                        )
                    )
                    .frame(width: w, height: h)
                    .blur(radius: max(5, h * 0.038))
            }
        }
    }
}

// MARK: - Amber Organic Bézier Blob Shapes

public struct AmberAtmosphericWaveShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let isWide = w > 220 || (h > 0 && w / h > 1.4)

        if isWide {
            // Taller, deeper wave shelf on medium/long widgets
            path.move(to: CGPoint(x: -w * 0.10, y: h * 1.15))
            path.addLine(to: CGPoint(x: -w * 0.10, y: h * 0.52))
            path.addCurve(
                to: CGPoint(x: w * 0.16, y: h * 0.80),
                control1: CGPoint(x: -w * 0.02, y: h * 0.64),
                control2: CGPoint(x: w * 0.08, y: h * 0.76)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.52, y: h * 0.76),
                control1: CGPoint(x: w * 0.28, y: h * 0.82),
                control2: CGPoint(x: w * 0.40, y: h * 0.78)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.76, y: h * 0.62),
                control1: CGPoint(x: w * 0.62, y: h * 0.74),
                control2: CGPoint(x: w * 0.68, y: h * 0.66)
            )
            path.addCurve(
                to: CGPoint(x: w * 1.15, y: h * 0.56),
                control1: CGPoint(x: w * 0.88, y: h * 0.58),
                control2: CGPoint(x: w * 1.02, y: h * 0.56)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        } else {
            // Square/compact widget
            path.move(to: CGPoint(x: -w * 0.15, y: h * 1.15))
            path.addLine(to: CGPoint(x: -w * 0.15, y: h * 0.65))
            path.addCurve(
                to: CGPoint(x: w * 0.12, y: h * 0.86),
                control1: CGPoint(x: -w * 0.05, y: h * 0.75),
                control2: CGPoint(x: w * 0.04, y: h * 0.84)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.55, y: h * 0.84),
                control1: CGPoint(x: w * 0.25, y: h * 0.88),
                control2: CGPoint(x: w * 0.40, y: h * 0.86)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.82, y: h * 0.74),
                control1: CGPoint(x: w * 0.66, y: h * 0.82),
                control2: CGPoint(x: w * 0.74, y: h * 0.76)
            )
            path.addCurve(
                to: CGPoint(x: w * 1.15, y: h * 0.70),
                control1: CGPoint(x: w * 0.92, y: h * 0.72),
                control2: CGPoint(x: w * 1.05, y: h * 0.70)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        }
        return path
    }
}

public struct AmberFlamePlumeShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let isWide = w > 220 || (h > 0 && w / h > 1.4)

        if isWide {
            // Taller, higher climbing flame plume on medium/long widgets
            path.move(to: CGPoint(x: w * 1.15, y: -h * 0.05))
            path.addCurve(
                to: CGPoint(x: w * 0.80, y: h * 0.28),
                control1: CGPoint(x: w * 0.96, y: h * 0.04),
                control2: CGPoint(x: w * 0.86, y: h * 0.16)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.66, y: h * 0.58),
                control1: CGPoint(x: w * 0.74, y: h * 0.38),
                control2: CGPoint(x: w * 0.68, y: h * 0.48)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.56, y: h * 1.15),
                control1: CGPoint(x: w * 0.64, y: h * 0.78),
                control2: CGPoint(x: w * 0.60, y: h * 0.98)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        } else {
            // Square/compact widget
            path.move(to: CGPoint(x: w * 1.15, y: h * 0.18))
            path.addCurve(
                to: CGPoint(x: w * 0.88, y: h * 0.52),
                control1: CGPoint(x: w * 0.96, y: h * 0.25),
                control2: CGPoint(x: w * 0.92, y: h * 0.38)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.76, y: h * 0.75),
                control1: CGPoint(x: w * 0.85, y: h * 0.62),
                control2: CGPoint(x: w * 0.78, y: h * 0.68)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.72, y: h * 1.15),
                control1: CGPoint(x: w * 0.76, y: h * 0.88),
                control2: CGPoint(x: w * 0.73, y: h * 1.02)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        }
        return path
    }
}

public struct AmberFloatingCloudBlobShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let isWide = w > 220 || (h > 0 && w / h > 1.4)

        if isWide {
            path.move(to: CGPoint(x: w * 0.48, y: h * 1.15))
            path.addLine(to: CGPoint(x: w * 0.48, y: h * 0.86))
            path.addCurve(
                to: CGPoint(x: w * 0.68, y: h * 0.60),
                control1: CGPoint(x: w * 0.52, y: h * 0.74),
                control2: CGPoint(x: w * 0.58, y: h * 0.64)
            )
            path.addCurve(
                to: CGPoint(x: w * 1.15, y: h * 0.48),
                control1: CGPoint(x: w * 0.82, y: h * 0.54),
                control2: CGPoint(x: w * 1.00, y: h * 0.50)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        } else {
            path.move(to: CGPoint(x: w * 0.60, y: h * 1.15))
            path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.94))
            path.addCurve(
                to: CGPoint(x: w * 0.78, y: h * 0.76),
                control1: CGPoint(x: w * 0.64, y: h * 0.86),
                control2: CGPoint(x: w * 0.70, y: h * 0.78)
            )
            path.addCurve(
                to: CGPoint(x: w * 1.15, y: h * 0.65),
                control1: CGPoint(x: w * 0.90, y: h * 0.74),
                control2: CGPoint(x: w * 1.05, y: h * 0.68)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        }
        return path
    }
}

public struct AmberRadiantCoreBlobShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let isWide = w > 220 || (h > 0 && w / h > 1.4)

        if isWide {
            path.move(to: CGPoint(x: w * 0.58, y: h * 1.15))
            path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.92))
            path.addCurve(
                to: CGPoint(x: w * 0.78, y: h * 0.72),
                control1: CGPoint(x: w * 0.62, y: h * 0.82),
                control2: CGPoint(x: w * 0.68, y: h * 0.75)
            )
            path.addCurve(
                to: CGPoint(x: w * 1.15, y: h * 0.64),
                control1: CGPoint(x: w * 0.90, y: h * 0.68),
                control2: CGPoint(x: w * 1.04, y: h * 0.66)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        } else {
            path.move(to: CGPoint(x: w * 0.68, y: h * 1.15))
            path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.98))
            path.addCurve(
                to: CGPoint(x: w * 0.86, y: h * 0.84),
                control1: CGPoint(x: w * 0.72, y: h * 0.92),
                control2: CGPoint(x: w * 0.78, y: h * 0.86)
            )
            path.addCurve(
                to: CGPoint(x: w * 1.15, y: h * 0.78),
                control1: CGPoint(x: w * 0.96, y: h * 0.82),
                control2: CGPoint(x: w * 1.06, y: h * 0.80)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        }
        return path
    }
}

public struct AmberIncandescentCoreShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let isWide = w > 220 || (h > 0 && w / h > 1.4)

        if isWide {
            path.move(to: CGPoint(x: w * 0.70, y: h * 1.15))
            path.addLine(to: CGPoint(x: w * 0.70, y: h * 0.96))
            path.addCurve(
                to: CGPoint(x: w * 0.88, y: h * 0.80),
                control1: CGPoint(x: w * 0.74, y: h * 0.88),
                control2: CGPoint(x: w * 0.80, y: h * 0.83)
            )
            path.addCurve(
                to: CGPoint(x: w * 1.15, y: h * 0.74),
                control1: CGPoint(x: w * 0.98, y: h * 0.76),
                control2: CGPoint(x: w * 1.08, y: h * 0.75)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        } else {
            path.move(to: CGPoint(x: w * 0.78, y: h * 1.15))
            path.addLine(to: CGPoint(x: w * 0.78, y: h * 1.02))
            path.addCurve(
                to: CGPoint(x: w * 0.92, y: h * 0.89),
                control1: CGPoint(x: w * 0.82, y: h * 0.96),
                control2: CGPoint(x: w * 0.86, y: h * 0.91)
            )
            path.addCurve(
                to: CGPoint(x: w * 1.15, y: h * 0.85),
                control1: CGPoint(x: w * 1.00, y: h * 0.87),
                control2: CGPoint(x: w * 1.08, y: h * 0.86)
            )
            path.addLine(to: CGPoint(x: w * 1.15, y: h * 1.15))
            path.closeSubpath()
        }
        return path
    }
}

// Backward-compatibility alias
typealias WeatherEditorialWidget = GradientWidget

// MARK: - Procedural Film Grain Texture Generator

private enum GrainTextureGenerator {
    static let sharedImage: UIImage = {
        let size = 256
        let bytesPerPixel = 4
        let bytesPerRow = size * bytesPerPixel
        var pixelData = [UInt8](repeating: 0, count: size * size * bytesPerPixel)

        var seed: UInt64 = 0x8542A1B79F34C2D1
        for i in 0..<(size * size) {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let noise = Int((seed >> 56) & 0x3F) - 32
            let gray = UInt8(clamping: 128 + noise)
            let alpha = UInt8(((seed >> 48) & 0x1F) + 20)
            let offset = i * bytesPerPixel
            pixelData[offset] = gray
            pixelData[offset + 1] = gray
            pixelData[offset + 2] = gray
            pixelData[offset + 3] = alpha
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        guard let context = CGContext(
            data: &pixelData,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ), let cgImage = context.makeImage() else {
            return UIImage()
        }

        return UIImage(cgImage: cgImage)
    }()
}

#Preview("Gradient Small - Fractal") {
    GradientWidget(gradientTheme: .fractalPrism)
        .frame(width: 170, height: 170)
}

#Preview("Gradient Small - Ruby") {
    GradientWidget(gradientTheme: .rubyAurora)
        .frame(width: 170, height: 170)
}

#Preview("Gradient Small - Cyan") {
    GradientWidget(gradientTheme: .midnightCyan)
        .frame(width: 170, height: 170)
}

#Preview("Gradient Small - Amber") {
    GradientWidget(gradientTheme: .sunsetAmber)
        .frame(width: 170, height: 170)
}

#Preview("Gradient Medium - Fractal") {
    GradientWidget(gradientTheme: .fractalPrism)
        .frame(width: 360, height: 170)
}

#Preview("Gradient Medium - Amber") {
    GradientWidget(gradientTheme: .sunsetAmber)
        .frame(width: 360, height: 170)
}
