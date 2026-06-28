import SwiftUI

struct BatteryBarsWidget: View {
    let snapshot: BatterySnapshot

    init(snapshot: BatterySnapshot = BatteryStatusProvider.currentSnapshot()) {
        self.snapshot = snapshot
    }

    var body: some View {
        ZStack {
            AppColors.widgetBackground

            VStack(spacing: 24) {
                HStack(spacing: 5) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.22))

                    Text("\(snapshot.level)%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.widgetPrimaryText)
                }

                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(index < snapshot.filledSegments ? Color(red: 1, green: 0.35, blue: 0.22) : AppColors.widgetPrimaryText.opacity(0.08))
                            .frame(width: 21, height: 44)
                    }
                }

                Text(snapshot.timeRemainingLabel)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.widgetTertiaryText)
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }
}

#Preview {
    BatteryBarsWidget()
        .frame(width: 170, height: 170)
}
