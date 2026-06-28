import SwiftUI

struct ConfigRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.headline)
    }
}

#Preview {
    ConfigRow(title: "Font", value: "Round")
}
