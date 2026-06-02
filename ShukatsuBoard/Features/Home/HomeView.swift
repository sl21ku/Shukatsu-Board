import SwiftData
import SwiftUI

struct HomeView: View {
    @Query private var companies: [Company]
    @Query private var tasks: [TaskItem]

    private var pendingTasks: [TaskItem] {
        tasks
            .filter { !$0.isCompleted }
            .sorted { ($0.dueAt ?? .distantFuture) < ($1.dueAt ?? .distantFuture) }
    }

    private var activeCompanies: [Company] {
        companies
            .filter { ![SelectionStatus.declined, .rejected].contains($0.status) }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("今日・直近の予定") {
                    if pendingTasks.isEmpty {
                        EmptyStateView(title: "未完了タスクはありません", systemImage: "checkmark.circle")
                    } else {
                        ForEach(pendingTasks.prefix(5)) { task in
                            TaskRowView(task: task)
                        }
                    }
                }

                Section("選考中企業") {
                    if activeCompanies.isEmpty {
                        EmptyStateView(title: "企業を追加してください", systemImage: "building.2")
                    } else {
                        ForEach(activeCompanies.prefix(5)) { company in
                            NavigationLink {
                                CompanyDetailView(company: company)
                            } label: {
                                CompanyCompactRow(company: company)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Shukatsu Board")
        }
    }
}
