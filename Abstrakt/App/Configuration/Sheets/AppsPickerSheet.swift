import SwiftUI
import WidgetKit

struct AppsPickerSheet: View {
    @Binding var selectedApps: [PortalApp]
    @State private var draftApps: [PortalApp]
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)

    init(selectedApps: Binding<[PortalApp]>) {
        _selectedApps = selectedApps
        _draftApps = State(initialValue: selectedApps.wrappedValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            selectedStrip
            appGrid
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.appBackground)
        .sensoryFeedback(.selection, trigger: PortalApp.storageValue(for: draftApps))
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.grid.2x2.fill")
                .font(AppFonts.font(.heading3))
                .foregroundStyle(AppColors.appBackground)
                .frame(width: 32, height: 32)
                .background(AppColors.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text("App Picker")
                .font(AppFonts.font(.heading2))
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            Button {
                selectedApps = draftApps
                WidgetCenter.shared.reloadAllTimelines()
                dismiss()
            } label: {
                Text("Done")
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(AppColors.appBackground)
                    .frame(height: 42)
                    .padding(.horizontal, 20)
                    .background(AppColors.primaryText)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(draftApps.count != 6)
            .opacity(draftApps.count == 6 ? 1 : 0.42)
        }
    }

    private var selectedStrip: some View {
        HStack(spacing: -8) {
            ForEach(draftApps.prefix(6), id: \.rawValue) { app in
                Button {
                    toggle(app)
                } label: {
                    Image(app.assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(app.title)")
            }

            if draftApps.count < 6 {
                ForEach(0..<(6 - draftApps.count), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.miniAppEmptySlot)
                        .frame(width: 48, height: 48)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppColors.miniAppEmptySlotBorder, lineWidth: 1)
                        }
                        .overlay {
                            Image(systemName: "plus")
                                .font(AppFonts.font(.caption))
                                .foregroundStyle(AppColors.tertiaryText)
                        }
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 74)
        .background(AppColors.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var appGrid: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 22) {
            ForEach(PortalApp.availableApps, id: \.rawValue) { app in
                appButton(app)
            }
        }
    }

    private func appButton(_ app: PortalApp) -> some View {
        let isSelected = draftApps.contains(app)
        let canSelect = isSelected || draftApps.count < 6

        return Button {
            toggle(app)
        } label: {
            VStack(spacing: 9) {
                Image(app.assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 58, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .opacity(canSelect ? 1 : 0.42)
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(AppColors.accentGreen)
                                .background(Circle().fill(AppColors.appBackground))
                                .offset(x: 5, y: -5)
                        }
                    }

                Text(app.title)
                    .font(AppFonts.font(.caption))
                    .foregroundStyle(canSelect ? AppColors.primaryText : AppColors.tertiaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(!canSelect)
        .accessibilityLabel(isSelected ? "Remove \(app.title)" : "Add \(app.title)")
    }

    private func toggle(_ app: PortalApp) {
        withAnimation(.smooth(duration: 0.18)) {
            if draftApps.contains(app) {
                draftApps.removeAll { $0 == app }
            } else if draftApps.count < 6 {
                draftApps.append(app)
            }
        }
    }
}

#Preview {
    AppsPickerSheet(selectedApps: .constant(PortalApp.defaultSelection))
}
