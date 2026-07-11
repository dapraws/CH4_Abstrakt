import SwiftUI

struct TutorialPage: View {
    let step: TutorialStep

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var editButtonPhase: Bool
    @Binding var deletePhase: Bool
    @Binding var popoverPhase: Bool
    @Binding var sheetPhase: Bool
    @Binding var jiggleActive: Bool
    @Binding var jigglePhase: Bool

    private let artworkWidth: CGFloat = 286
    private let artworkHeight: CGFloat = 259

    var body: some View {
        VStack(spacing: 0) {
            tutorialTextBlock
                .id(step)
                .transition(blurFadeTransition)
                .animation(.smooth(duration: 0.3, extraBounce: 0), value: step)
                .padding(.horizontal, 28)
                .zIndex(2)

            Spacer(minLength: 54)

            TutorialArtwork(
                step: step,
                editButtonPhase: editButtonPhase,
                deletePhase: deletePhase,
                popoverPhase: popoverPhase,
                sheetPhase: sheetPhase,
                jiggleActive: jiggleActive,
                jigglePhase: jigglePhase,
                reduceMotion: reduceMotion
            )
            .frame(maxWidth: artworkWidth)
            .frame(height: artworkHeight)
            .offset(y: 34)
            .accessibilityHidden(true)
            .zIndex(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 446, alignment: .top)
    }

    private var tutorialTextBlock: some View {
        VStack(alignment: .center, spacing: 14) {
            HStack(spacing: 8) {
                Image(step.stickerAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(step.eyebrow)
                    .font(AppFonts.font(.caption, theme: .fusionPixel))
                    .lineSpacing(AppFonts.lineSpacing(.caption, theme: .fusionPixel))
                    .foregroundStyle(AppColors.secondaryText)
                    .tracking(0.2)
            }

            VStack(spacing: 10) {
                Text(step.title)
                    .font(AppFonts.font(.title, theme: .quicksand))
                    .lineSpacing(AppFonts.lineSpacing(.title, theme: .quicksand))
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)

                Text(step.subtitle)
                    .font(AppFonts.font(.body, theme: .quicksand))
                    .lineSpacing(AppFonts.lineSpacing(.body, theme: .quicksand) + 1)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.84)
                    .frame(maxWidth: 300)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TutorialArtwork: View {
    @Environment(\.colorScheme) private var colorScheme

    let step: TutorialStep
    let editButtonPhase: Bool
    let deletePhase: Bool
    let popoverPhase: Bool
    let sheetPhase: Bool
    let jiggleActive: Bool
    let jigglePhase: Bool
    let reduceMotion: Bool

    private let artworkSize = CGSize(width: 250.8, height: 259)
    private let appSize: CGFloat = 37.5
    private let appHorizontalInset: CGFloat = 25
    private let appRowSpacing: CGFloat = 16
    private let appGridTop: CGFloat = 52
    private let deleteBadgeSize: CGFloat = 11
    private let editButtonSize = CGSize(width: 35, height: 15)
    private let editPopoverSize = CGSize(width: 94, height: 54)
    private let sheetSize = CGSize(width: 241, height: 216)

    var body: some View {
        ZStack {
            ZStack {
                tutorialBackground
                    .transaction { transaction in
                        transaction.animation = nil
                    }

                appLayer
                    .opacity(1)

                editButtonLayer
                    .allowsHitTesting(false)

                editPopoverLayer
                    .allowsHitTesting(false)

                widgetSearchLayer
                    .allowsHitTesting(false)
            }
            .mask(containerFadeMask)
            .transaction { transaction in
                if step == .tapAndHold {
                    transaction.animation = nil
                }
            }
        }
        .compositingGroup()
        .saturation(colorScheme == .dark ? 0.92 : 1)
        .contrast(colorScheme == .dark ? 0.97 : 1)
        .brightness(colorScheme == .dark ? -0.02 : 0)
        .overlay {
            if colorScheme == .dark {
                darkModeTone
                    .blendMode(.multiply)
            }
        }
        .overlay {
            if colorScheme == .dark {
                darkModeLift
                    .blendMode(.screen)
            }
        }
        .frame(width: artworkSize.width, height: artworkSize.height)
    }

    private var widgetSearchLayer: some View {
        Image("tutorial_sheet")
            .resizable()
            .frame(width: sheetSize.width, height: sheetSize.height)
            .position(x: artworkSize.width / 2, y: 150)
            .opacity(sheetPhase ? 1 : 0)
            .offset(y: sheetPhase ? 0 : 70)
            .animation(.easeOut(duration: 0.34), value: sheetPhase)
            .mask(sheetInteriorFade)
    }

    private var appLayer: some View {
        VStack(spacing: appRowSpacing) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: appColumnSpacing) {
                    ForEach(0..<4, id: \.self) { column in
                        appCell(index: row * 4 + column, row: row)
                    }
                }
            }
        }
        .frame(width: appGridWidth, height: appGridHeight)
        .position(x: artworkSize.width / 2, y: appGridTop + appGridHeight / 2)
        .mask(phoneInteriorFade)
    }

    private func appCell(index: Int, row: Int) -> some View {
        ZStack(alignment: .topLeading) {
            Image("tutorial_app")
                .resizable()
                .scaledToFit()
                .frame(width: appSize, height: appSize)
                .opacity(appOpacity(row: row))

            Image("tutorial_delete_app")
                .resizable()
                .scaledToFit()
                .frame(width: deleteBadgeSize, height: deleteBadgeSize)
                .opacity(deletePhase ? deleteOpacity(row: row) : 0)
                .scaleEffect(deletePhase ? 1 : 0.68, anchor: .center)
                .blur(radius: deletePhase ? 0 : 8)
                .animation(
                    .spring(duration: deletePhase ? 0.34 : 0.28, bounce: deletePhase ? 0.2 : 0.16)
                        .delay(deletePhase ? 0.04 + Double(index) * 0.012 : 0),
                    value: deletePhase
                )
                .offset(x: -deleteBadgeSize / 2 + 1, y: -deleteBadgeSize / 2 + 1)
        }
        .frame(width: appSize, height: appSize)
        .rotationEffect(.degrees(jiggleAngle), anchor: .center)
        .scaleEffect(jiggleActive ? 1.015 : 1, anchor: .center)
    }

    private var editButtonLayer: some View {
        Image("tutorial_edit_button")
            .resizable()
            .scaledToFit()
            .frame(width: editButtonSize.width, height: editButtonSize.height)
            .opacity(editButtonPhase ? 1 : 0)
            .scaleEffect(editButtonPhase ? 1 : 0.82, anchor: .center)
            .blur(radius: editButtonPhase ? 0 : 9)
            .animation(.spring(duration: 0.32, bounce: 0.18), value: editButtonPhase)
            .position(editButtonPosition)
    }

    private var editPopoverLayer: some View {
        Image("tutorial_edit_popover")
            .resizable()
            .scaledToFit()
            .frame(width: editPopoverSize.width, height: editPopoverSize.height)
            .opacity(popoverPhase ? 1 : 0)
            .scaleEffect(popoverPhase ? 1 : 0.9, anchor: .topLeading)
            .blur(radius: popoverPhase ? 0 : 9)
            .animation(.spring(duration: 0.34, bounce: 0.18), value: popoverPhase)
            .position(editPopoverPosition)
    }

    private var containerFadeMask: some View {
        halfHeightFadeMask
    }

    private var sheetInteriorFade: some View {
        halfHeightFadeMask
    }

    private var phoneInteriorFade: some View {
        halfHeightFadeMask
    }

    private var halfHeightFadeMask: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.white)
                .frame(height: artworkSize.height / 2)

            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .white, location: 0),
                            .init(color: .white.opacity(0.82), location: 0.24),
                            .init(color: .white.opacity(0.48), location: 0.55),
                            .init(color: .white.opacity(0.16), location: 0.82),
                            .init(color: .clear, location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: artworkSize.height / 2)
        }
        .frame(width: artworkSize.width, height: artworkSize.height)
    }

    private var tutorialBackground: some View {
        Image("tutorial_bg")
            .resizable()
            .scaledToFit()
            .frame(width: artworkSize.width, height: artworkSize.height)
    }

    private var darkModeTone: some View {
        LinearGradient(
            colors: [
                Color(red: 0.27, green: 0.28, blue: 0.36).opacity(0.34),
                Color(red: 0.18, green: 0.19, blue: 0.26).opacity(0.22)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }

    private var darkModeLift: some View {
        RadialGradient(
            colors: [
                Color(red: 0.52, green: 0.54, blue: 0.76).opacity(0.36),
                Color.clear
            ],
            center: .top,
            startRadius: 10,
            endRadius: 180
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }

    private var jiggleAngle: Double {
        guard jiggleActive, !reduceMotion else { return 0 }
        return jigglePhase ? 4 : -2
    }

    private var appGridWidth: CGFloat {
        artworkSize.width - appHorizontalInset * 2
    }

    private var appGridHeight: CGFloat {
        appSize * 4 + appRowSpacing * 3
    }

    private var appGridLeft: CGFloat {
        appHorizontalInset
    }

    private var editButtonPosition: CGPoint {
        CGPoint(x: appGridLeft + appSize / 2, y: appGridTop - 28)
    }

    private var editPopoverPosition: CGPoint {
        let popoverLeft = editButtonPosition.x - editButtonSize.width / 2
        return CGPoint(
            x: popoverLeft + editPopoverSize.width / 2,
            y: editButtonPosition.y + editButtonSize.height / 2 + editPopoverSize.height / 2 + 16
        )
    }

    private var appColumnSpacing: CGFloat {
        (appGridWidth - appSize * 4) / 3
    }

    private func appOpacity(row: Int) -> Double {
        switch row {
        case 0:
            0.64
        case 1:
            0.58
        case 2:
            0.4
        default:
            0.2
        }
    }

    private func deleteOpacity(row: Int) -> Double {
        switch row {
        case 0:
            0.88
        case 1:
            0.74
        case 2:
            0.5
        default:
            0.22
        }
    }

}

enum TutorialStep: CaseIterable {
    case tapAndHold
    case edit
    case addWidget
    case findAbstrakt

    var showsEditButton: Bool {
        switch self {
        case .edit, .addWidget:
            true
        default:
            false
        }
    }

    var title: String {
        switch self {
        case .tapAndHold:
            "Hold an empty spot"
        case .edit:
            "Open the edit menu"
        case .addWidget:
            "Tap Add Widget"
        case .findAbstrakt:
            "Find Abstrakt"
        }
    }

    var subtitle: String {
        switch self {
        case .tapAndHold:
            "Press and hold until the apps start jiggling on the Home Screen."
        case .edit:
            "Tap Edit in the corner to open the Home Screen editing menu."
        case .addWidget:
            "Choose Add Widget, then scroll or search for the Abstrakt widget."
        case .findAbstrakt:
            "Pick a size, add it, then choose one of your saved presets to display."
        }
    }

    var eyebrow: String {
        switch self {
        case .tapAndHold:
            "STEP 1"
        case .edit:
            "STEP 2"
        case .addWidget:
            "STEP 3"
        case .findAbstrakt:
            "STEP 4"
        }
    }

    var stickerAssetName: String {
        switch self {
        case .tapAndHold:
            "tap-sticker"
        case .edit:
            "button-sticker"
        case .addWidget:
            "swap-sticker"
        case .findAbstrakt:
            "search-sticker"
        }
    }
}

#Preview("Tutorial Step") {
    AppColors.appBackground
        .overlay {
            TutorialPage(
                step: .edit,
                editButtonPhase: .constant(true),
                deletePhase: .constant(true),
                popoverPhase: .constant(false),
                sheetPhase: .constant(false),
                jiggleActive: .constant(true),
                jigglePhase: .constant(false)
            )
                .padding(.top, 24)
        }
        .environment(LocalizationManager.shared)
        .environment(\.locale, LocalizationManager.shared.locale)
}
