import SwiftUI

struct ReminderCustomizationRow: View {
    let selectedReminderTitle: String
    let openReminderPicker: () -> Void

    var body: some View {
        Button {
            Haptics.selection.play()
            openReminderPicker()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "checklist")
                    .font(AppFonts.font(.title))

                Capsule()
                    .fill(AppColors.primaryText.opacity(0.16))
                    .frame(width: 2, height: 20)

                Spacer(minLength: 10)

                Text(selectedReminderTitle)
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Image(systemName: "chevron.right")
                    .font(AppFonts.font(.heading4))
                    .foregroundStyle(AppColors.primaryText.opacity(0.42))
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(AppColors.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 360)
        .accessibilityLabel("Choose reminder list")
    }
}

struct ReminderPickerSheet: View {
    @Binding var selectedReminderIdentifier: String
    @Binding var selectedReminderTitle: String

    @Environment(\.dismiss) private var dismiss
    @State private var reminderLists: [ReminderListSummary] = []
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if reminderLists.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No reminder lists yet")
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)

                    Text("Create a list in Apple Reminders, then come back here to feature it in the widget.")
                        .font(AppFonts.font(.body))
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        reminderButton(
                            title: "Auto pick",
                            subtitle: "Show tasks from all reminder lists",
                            identifier: ""
                        )

                        ForEach(reminderLists) { reminder in
                            reminderButton(
                                title: reminder.title,
                                subtitle: reminder.subtitle,
                                identifier: reminder.id
                            )
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.appBackground)
        .task {
            await loadReminders()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            SheetHeaderSymbol(systemName: "checklist")

            VStack(alignment: .leading, spacing: 2) {
                Text("Pick reminder list")
                    .font(AppFonts.font(.heading2))
                    .foregroundStyle(AppColors.primaryText)

                Text("The widget will show tasks from this list.")
                    .font(AppFonts.font(.caption))
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            Button {
                Haptics.selection.play()
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

    private func reminderButton(
        title: String,
        subtitle: String,
        identifier: String
    ) -> some View {
        let isSelected = selectedReminderIdentifier == identifier

        return Button {
            Haptics.selection.play()
            selectedReminderIdentifier = identifier
            selectedReminderTitle = identifier.isEmpty ? "" : title
            Task { @MainActor in
                let snapshot = await ReminderProvider.currentSnapshot()
                SharedModelContainer.write(reminders: snapshot)
                WidgetTimelineReloadScheduler.reloadNow()
            }
            dismiss()
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    Text(subtitle)
                        .font(AppFonts.font(.caption))
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(2)
                }

                Spacer(minLength: 12)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        isSelected ? AppColors.accentGreen : AppColors.tertiaryText
                    )
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 74)
            .background(
                isSelected ? AppColors.primaryText.opacity(0.06) : AppColors.cardSoft
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func loadReminders() async {
        isLoading = true
        reminderLists = await ReminderProvider.availableReminderLists()
        isLoading = false
    }
}
