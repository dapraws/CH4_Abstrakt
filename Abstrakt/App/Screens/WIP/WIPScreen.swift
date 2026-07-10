import SwiftUI

struct WIPScreen: View {
    @AppStorage(AppGroupConstants.liveActivityBatteryEnabledKey, store: AppGroupConstants.sharedDefaults)
    private var isBatteryLiveActivityEnabled = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Battery Charging", isOn: $isBatteryLiveActivityEnabled)
                        .onChange(of: isBatteryLiveActivityEnabled) { _, newValue in
                            if newValue {
                                BatteryLiveActivityProvider.shared.startIfNeeded(with: BatteryStatusProvider.currentSnapshot())
                            } else {
                                BatteryLiveActivityProvider.shared.end()
                            }
                        }
                } footer: {
                    Text("Starts a Live Activity when your battery state changes or you plug in your device.")
                }
            }
            .navigationTitle("Live Activities")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WIPScreen()
}
