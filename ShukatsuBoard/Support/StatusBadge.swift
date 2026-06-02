import SwiftUI

struct StatusBadge: View {
    let status: SelectionStatus

    var body: some View {
        Text(status.title)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.tint.opacity(0.14), in: Capsule())
            .foregroundStyle(status.tint)
    }
}
