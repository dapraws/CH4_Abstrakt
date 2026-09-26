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
        // Monochromatic wide fluted glass / prism texture
        let slatCount = max(8, Int((w / 16.0).rounded()))
        let slatWidth = w / CGFloat(slatCount)

        ZStack {
            // Layer 1: Smooth atmospheric monochromatic base gradient
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.06, green: 0.06, blue: 0.07), location: 0.0),   // Deep obsidian
                    .init(color: Color(red: 0.12, green: 0.12, blue: 0.14), location: 0.18),  // Charcoal
                    .init(color: Color(red: 0.22, green: 0.22, blue: 0.25), location: 0.36),  // Dark graphite
                    .init(color: Color(red: 0.34, green: 0.34, blue: 0.38), location: 0.52),  // Titanium slate
                    .init(color: Color(red: 0.48, green: 0.48, blue: 0.54), location: 0.68),  // Cool steel
                    .init(color: Color(red: 0.64, green: 0.64, blue: 0.70), location: 0.84),  // Silver
                    .init(color: Color(red: 0.80, green: 0.80, blue: 0.86), location: 1.0)    // Platinum sheen
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Layer 2: Radiant bottom-center soft silver bloom
            RadialGradient(
                colors: [
                    Color.white.opacity(0.18),
                    Color(white: 0.70).opacity(0.08),
                    Color.clear
                ],
                center: .init(x: 0.55, y: 0.85),
                startRadius: 0,
                endRadius: max(w, h) * 0.75
            )

            // Layer 3: 3D Fluted Glass / Reeded Prism Texture
            HStack(spacing: 0) {
                ForEach(0..<slatCount, id: \.self) { _ in
                    // Fluted 3D cylinder bevel: Shadow crease on left, luminous highlight ridge on right
                    LinearGradient(
                        stops: [
                            .init(color: Color.black.opacity(0.10), location: 0.0),
                            .init(color: Color.clear, location: 0.24),
                            .init(color: Color.white.opacity(0.08), location: 0.80),
                            .init(color: Color.white.opacity(0.20), location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: slatWidth, height: h)
                }
            }
        }
        .frame(width: w, height: h)
    }

    @ViewBuilder
    private func amberBottomLightBackground(width w: CGFloat, height h: CGFloat) -> some View {
        // Deep obsidian dark canvas
        Color(red: 0.05, green: 0.05, blue: 0.06)

        // Organic Cascading Glowing Light Blobs (creating the falling gradient aesthetic)
        ZStack {
            // Layer 1: Ambient Base Floor Light (spans the entire lower base)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.70, green: 0.22, blue: 0.03).opacity(0.70),
                            Color(red: 0.40, green: 0.10, blue: 0.02).opacity(0.35),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: max(w, h) * 0.75
                    )
                )
                .frame(width: w * 1.50, height: h * 0.90)
                .position(x: w * 0.50, y: h * 1.05)
                .blur(radius: max(16, h * 0.20))

            // Layer 2: Left-Side Warm Horizon Spill
            Ellipse()
                .fill(Color(red: 0.85, green: 0.28, blue: 0.04).opacity(0.65))
                .frame(width: w * 0.80, height: h * 0.55)
                .position(x: w * 0.15, y: h * 0.95)
                .blur(radius: max(14, h * 0.16))

            // Layer 3: Dynamic Rising Amber Cascade Blob (tilted organic shape climbing the right flank)
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.38, blue: 0.06).opacity(0.90),
                            Color(red: 0.75, green: 0.18, blue: 0.02).opacity(0.50)
                        ],
                        startPoint: .bottomTrailing,
                        endPoint: .topLeading
                    )
                )
                .frame(width: w * 0.95, height: h * 0.75)
                .rotationEffect(.degrees(-15))
                .position(x: w * 0.78, y: h * 0.82)
                .blur(radius: max(15, h * 0.18))

            // Layer 4: Radiant Golden-Amber Hot Core Flare
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.00, green: 0.68, blue: 0.20),
                            Color(red: 0.98, green: 0.42, blue: 0.08).opacity(0.90),
                            Color(red: 0.85, green: 0.22, blue: 0.03).opacity(0.40),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: max(w, h) * 0.40
                    )
                )
                .frame(width: w * 0.85, height: h * 0.65)
                .position(x: w * 0.80, y: h * 0.90)
                .blur(radius: max(12, h * 0.14))

            // Layer 5: Incandescent Specular Sunburst Center
            Circle()
                .fill(Color(red: 1.00, green: 0.84, blue: 0.48).opacity(0.95))
                .frame(width: min(w, h) * 0.36, height: min(w, h) * 0.36)
                .position(x: w * 0.82, y: h * 0.94)
                .blur(radius: max(8, min(w, h) * 0.09))
        }
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
