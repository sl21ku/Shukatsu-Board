import SwiftUI

struct TaskRowView: View {
    let task: TaskItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: task.type.iconName)
                .frame(width: 24)
                .foregroundStyle(task.isCompleted ? Color.secondary : Color.accentColor)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                    Spacer()
                    Text(task.type.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let companyName = task.company?.name {
                    Text(companyName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let dueAt = task.dueAt {
                    Label(Formatters.dateTime.string(from: dueAt), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
