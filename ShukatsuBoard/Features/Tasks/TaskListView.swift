import SwiftData
import SwiftUI

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query(sort: \Company.name) private var companies: [Company]

    @State private var showCompleted = false
    @State private var isAdding = false

    private var filteredTasks: [TaskItem] {
        tasks
            .filter { showCompleted || !$0.isCompleted }
            .sorted { ($0.dueAt ?? .distantFuture) < ($1.dueAt ?? .distantFuture) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("完了済みも表示", isOn: $showCompleted)
                }

                if filteredTasks.isEmpty {
                    EmptyStateView(title: "タスクはありません", systemImage: "calendar")
                } else {
                    ForEach(filteredTasks) { task in
                        NavigationLink {
                            TaskFormView(task: task, companies: companies)
                        } label: {
                            TaskRowView(task: task)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                task.isCompleted.toggle()
                                task.touch()
                                if task.isCompleted {
                                    NotificationService.shared.cancelReminder(for: task)
                                } else {
                                    Task {
                                        try? await NotificationService.shared.scheduleReminder(for: task)
                                    }
                                }
                            } label: {
                                Label(task.isCompleted ? "未完了" : "完了", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
            .navigationTitle("タスク")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAdding = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("タスクを追加")
                }
            }
            .sheet(isPresented: $isAdding) {
                NavigationStack {
                    TaskFormView(companies: companies)
                }
            }
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        for offset in offsets {
            let task = filteredTasks[offset]
            NotificationService.shared.cancelReminder(for: task)
            modelContext.delete(task)
        }
    }
}
