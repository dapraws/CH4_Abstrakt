import SwiftUI

struct WelcomeScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            let metrics = WelcomeScreenMetrics(size: proxy.size)

            ZStack(alignment: .bottom) {
                widgetIllustration
                    .frame(width: metrics.illustrationWidth)
                    .frame(
                        width: metrics.illustrationViewportWidth,
                        height: metrics.illustrationViewportHeight,
                        alignment: .bottom
                    )
                    .offset(y: metrics.illustrationYOffset)
                    .clipped()
                    .allowsHitTesting(false)
                    .ignoresSafeArea(.container, edges: .bottom)

                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: metrics.logoTopSpacing)

                    onboardingLogo
                        .frame(width: metrics.logoSize, height: metrics.logoSize)
                        .padding(.bottom, metrics.logoBottomSpacing)

                    ZStack {
                        Image("laurel_left")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: metrics.laurelWidth,
                                height: metrics.laurelHeight
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: metrics.titleLineSpacing) {
                            Text(L("onboarding.welcome_prefix"))
                                .font(AppFonts.font(.display, theme: .quicksand))
                                .foregroundStyle(AppColors.primaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .minimumScaleFactor(0.92)

                            Text("Abstrakt")
                                .font(AppFonts.font(.homeDisplay, theme: .fusionPixel))
                                .lineSpacing(AppFonts.lineSpacing(.homeDisplay, theme: .fusionPixel))
                                .foregroundStyle(AppColors.primaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                                .frame(
                                    width: metrics.wordmarkWidth,
                                    height: metrics.wordmarkHeight
                                )
                        }
                        .frame(width: metrics.titleColumnWidth)

                        Image("laurel_right")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: metrics.laurelWidth,
                                height: metrics.laurelHeight
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(width: metrics.titleGroupWidth)
                    .padding(.bottom, metrics.titleBottomSpacing)

                    Text(L("onboarding.welcome_subtitle"))
                        .font(AppFonts.font(.heading3, theme: .quicksand))
                        .lineSpacing(2)
                        .foregroundStyle(AppColors.secondaryText.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, metrics.subtitleBottomSpacing)

                    BrandCreditFooter()

                    Spacer(minLength: metrics.bottomContentSpacing)
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                .padding(.horizontal, metrics.horizontalPadding)
                .clipped()
            }
        }
    }

    private var onboardingLogo: some View {
        Image("logo")
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
                    .blendMode(.screen)
            }
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.1))
                    .frame(width: 35)
                    .blendMode(.softLight)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.black.opacity(0.24), lineWidth: 1)
                    .blur(radius: 2)
                    .offset(y: 1)
                    .mask(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
            }
            .shadow(color: .black.opacity(0.13), radius: 16, y: 8)
    }

    private var widgetIllustration: some View {
        ZStack {
            onboardingWidgetImage("widgets_light")
                .opacity(colorScheme == .dark ? 0 : 1)

            onboardingWidgetImage("widgets_dark")
                .opacity(colorScheme == .dark ? 1 : 0)
        }
        .animation(.smooth(duration: 0.25), value: colorScheme)
        .opacity(0.64)
        .mask {
            widgetIllustrationFade
        }
    }

    private func onboardingWidgetImage(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
    }

    private var widgetIllustrationFade: some View {
        LinearGradient(
            stops: [
                .init(color: AppColors.appBackground.opacity(0.08), location: 0),
                .init(color: AppColors.appBackground.opacity(0.12), location: 0.08),
                .init(color: AppColors.appBackground.opacity(0.2), location: 0.18),
                .init(color: AppColors.appBackground.opacity(0.36), location: 0.32),
                .init(color: AppColors.appBackground.opacity(0.58), location: 0.48),
                .init(color: AppColors.appBackground.opacity(0.82), location: 0.66),
                .init(color: AppColors.appBackground.opacity(0.96), location: 0.82),
                .init(color: AppColors.appBackground, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct WelcomeScreenMetrics {
    let size: CGSize

    private var height: CGFloat {
        max(size.height, 620)
    }

    private var width: CGFloat {
        max(size.width, 320)
    }

    var horizontalPadding: CGFloat {
        28
    }

    private var contentWidth: CGFloat {
        max(0, width - (horizontalPadding * 2))
    }

    private var tallDeviceProgress: CGFloat {
        min(max((height - 620) / 210, 0), 1)
    }

    var logoTopSpacing: CGFloat {
        88 + (32 * tallDeviceProgress)
    }

    var logoSize: CGFloat {
        58 + (12 * tallDeviceProgress)
    }

    var logoBottomSpacing: CGFloat {
        28 + (10 * tallDeviceProgress)
    }

    var laurelWidth: CGFloat {
        min(48, max(34, width * 0.115))
    }

    var laurelHeight: CGFloat {
        laurelWidth * 1.62
    }

    var titleGroupWidth: CGFloat {
        contentWidth
    }

    var titleColumnWidth: CGFloat {
        min(224, max(168, titleGroupWidth - (laurelWidth * 2) - 8))
    }

    var wordmarkWidth: CGFloat {
        min(204, titleColumnWidth)
    }

    var wordmarkHeight: CGFloat {
        42 + (8 * tallDeviceProgress)
    }

    var titleLineSpacing: CGFloat {
        -2
    }

    var titleBottomSpacing: CGFloat {
        20 + (6 * tallDeviceProgress)
    }

    var subtitleBottomSpacing: CGFloat {
        30 + (10 * tallDeviceProgress)
    }

    var bottomContentSpacing: CGFloat {
        196 + (42 * tallDeviceProgress)
    }

    var illustrationWidth: CGFloat {
        width * 1.5
    }

    var illustrationViewportWidth: CGFloat {
        width
    }

    var illustrationViewportHeight: CGFloat {
        min(470, max(380, height * 0.5))
    }

    var illustrationYOffset: CGFloat {
        48 + (8 * tallDeviceProgress)
    }
}

#Preview("Welcome") {
    AppColors.appBackground
        .overlay {
            WelcomeScreen()
        }
        .environment(LocalizationManager.shared)
        .environment(\.locale, LocalizationManager.shared.locale)
}

#Preview("Welcome Dark") {
    AppColors.appBackground
        .overlay {
            WelcomeScreen()
        }
        .environment(LocalizationManager.shared)
        .environment(\.locale, LocalizationManager.shared.locale)
        .preferredColorScheme(.dark)
}
