//
//  ShareAppSheet.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 06/07/26.
//

import SwiftUI

/// Themed "Share App" sheet.
///
/// The sheet itself is the custom-branded UI (matching `FontPickerSheet`).
/// The actual act of sharing hands off to the system share sheet, because
/// reaching Messages / WhatsApp / AirDrop is only possible through
/// `UIActivityViewController`. We share three items: a rendered branded card
/// image, the broadcast message, and the landing URL.
struct ShareAppSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale

    /// Chosen once when the sheet appears so the preview and the shared image
    /// use the same line.
    @State private var broadcastLine = AppShareContent.randomBroadcastLine()
    @State private var isPresentingActivitySheet = false

    private let cardCornerRadius: CGFloat = 24

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            shareCard
            
            Spacer()
            
            shareButton
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.appBackground)
        .sheet(isPresented: $isPresentingActivitySheet) {
            ShareActivityView(items: shareItems())
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            SheetHeaderSymbol(systemName: "arrowshape.turn.up.right.fill")

            Text("Share Abstrakt")
                .font(AppFonts.font(.heading2))
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: 42, height: 42)
                    .background(AppColors.cardSoft)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Share Card

    /// The branded preview. This same view is rendered to a `UIImage` and
    /// attached to the share, so what the user sees is what they send.
    private var shareCard: some View {
        ShareCardView(broadcastLine: broadcastLine)
            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button {
            isPresentingActivitySheet = true
        } label: {
            ShareAppButtonContent()
                .frame(maxWidth: 256)
                .frame(height: 64)
        }
        .buttonStyle(.plain)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Share Items

    private func shareItems() -> [Any] {
        var items: [Any] = [
            AppShareContent.shareMessage(line: broadcastLine),
            AppShareContent.landingURL,
        ]

        if let image = renderShareCardImage() {
            items.insert(image, at: 0)
        }

        return items
    }

    @MainActor
    private func renderShareCardImage() -> UIImage? {
        let renderer = ImageRenderer(
            content: ShareCardView(broadcastLine: broadcastLine)
                .frame(width: 320)
        )
        renderer.scale = displayScale
        return renderer.uiImage
    }
}

// MARK: - Share Button Content

private struct ShareAppButtonContent: View {
    @State private var shimmerPhase: CGFloat = -1

    var body: some View {
        buttonLabel
            .foregroundStyle(Color.blue.opacity(0.64))
            .overlay {
                GeometryReader { proxy in
                    buttonLabel
                        .foregroundStyle(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.blue.opacity(0), location: 0),
                                    .init(color: Color.blue.opacity(0.12), location: 0.32),
                                    .init(color: Color.blue.opacity(0.54), location: 0.5),
                                    .init(color: Color.blue.opacity(0.12), location: 0.68),
                                    .init(color: Color.blue.opacity(0), location: 1),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .mask(
                            Capsule()
                                .frame(width: proxy.size.width * 0.42, height: proxy.size.height * 1.35)
                                .blur(radius: 6)
                                .rotationEffect(.degrees(8))
                                .offset(x: proxy.size.width * shimmerPhase)
                        )
                        .opacity(0.9)
                }
                .allowsHitTesting(false)
            }
            .symbolEffect(.pulse.wholeSymbol, options: .repeating.speed(0.35), value: shimmerPhase > 0)
            .onAppear {
                shimmerPhase = -0.9
                withAnimation(.easeInOut(duration: 4.4).repeatForever(autoreverses: false)) {
                    shimmerPhase = 1.45
                }
            }
    }

    private var buttonLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .font(AppFonts.font(.heading2))

            Text("Share App")
                .font(AppFonts.font(.heading2))
        }
    }
}

// MARK: - Share Card View

/// Standalone branded card, used both in the sheet and as the rendered share
/// image. Kept token-based so it looks correct in light and dark mode.
private struct ShareCardView: View {
    let broadcastLine: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 24) {
                Image(uiImage: appIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Abstrakt")
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                    Text("Widgets, your way")
                        .font(AppFonts.font(.caption))
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()
            }

            Text(broadcastLine)
                .font(AppFonts.font(.subHeading))
                .lineSpacing(AppFonts.lineSpacing(.subHeading))
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            Text(AppShareContent.landingURL.host ?? AppShareContent.landingURL.absoluteString)
                .font(AppFonts.font(.caption))
                .foregroundStyle(AppColors.secondaryText)
                .padding(.horizontal, 16)
                .frame(height: 32)
                .background(AppColors.appBackground.opacity(0.55))
                .clipShape(Capsule())
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardSoft)
    }

    /// Best-effort primary app icon for the card. Falls back to a neutral
    /// placeholder if the icon can't be resolved (e.g. in previews).
    private var appIconImage: UIImage {
        if let name = primaryIconFileName, let image = UIImage(named: name) {
            return image
        }
        return UIImage(systemName: "app.dashed") ?? UIImage()
    }

    private var primaryIconFileName: String? {
        guard
            let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
            let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let files = primary["CFBundleIconFiles"] as? [String]
        else {
            return nil
        }
        return files.last
    }
}

// MARK: - Activity View Wrapper

/// Thin `UIViewControllerRepresentable` wrapper around the system share sheet.
private struct ShareActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

#Preview {
    ShareAppSheet()
}
