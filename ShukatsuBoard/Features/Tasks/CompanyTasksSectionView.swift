import SwiftData
import SwiftUI

struct CompanyTasksSectionView: View {
    @Environment(\.modelContext) private var modelContext

    let company: Company

    @State private var isAdding = false

    var body: some View {
        Section {
            if company.tasks.isEmpty {
                EmptyStateView(title: "タスクはありません", systemImage: "calendar")
            } else {
                ForEach(company.tasks.sorted { ($0.dueAt ?? .distantFuture) < ($1.dueAt ?? .distantFuture) }) { task in
                    NavigationLink {
                        TaskFormView(task: task, fixedCompany: company, companies: [company])
                    } label: {
                        TaskRowView(task: task)
                    }
                }
                .onDelete(perform: deleteTasks)
            }
        } header: {
            HStack {
                Text("タスク")
                Spacer()
                Button {
                    isAdding = true
                } label: {
                    Image(systemName: "plus.circle")
                }
                .accessibilityLabel("タスクを追加")
            }
        }
        .sheet(isPresented: $isAdding) {
            NavigationStack {
                TaskFormView(fixedCompany: company, companies: [company])
            }
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        let sorted = company.tasks.sorted { ($0.dueAt ?? .distantFuture) < ($1.dueAt ?? .distantFuture) }
        for offset in offsets {
            let task = sorted[offset]
            NotificationService.shared.cancelReminder(for: task)
            modelContext.delete(task)
        }
        company.touch()
    }
}
