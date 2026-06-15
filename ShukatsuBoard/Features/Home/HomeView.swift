import SwiftData
import SwiftUI

struct HomeView: View {
    @Query private var companies: [Company]
    @Query private var tasks: [TaskItem]

    private var dueSoonTasks: [TaskItem] {
        pendingTasks.filter { task in
            guard let dueAt = task.dueAt else {
                return false
            }

            let limit = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
            return dueAt <= limit
        }
    }

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
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("今日の就活ボード")
                            .font(.title3)
                            .fontWeight(.bold)

                        HStack(spacing: 10) {
                            HomeMetricView(title: "選考中", value: "\(activeCompanies.count)", systemImage: "building.2")
                            HomeMetricView(title: "未完了", value: "\(pendingTasks.count)", systemImage: "checklist")
                            HomeMetricView(title: "7日以内", value: "\(dueSoonTasks.count)", systemImage: "clock")
                        }
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(AppTheme.softBackground)

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
            .navigationTitle("就活マイページ登録アプリ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("設定")
                }
            }
        }
    }
}

private struct HomeMetricView: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(AppTheme.teal)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}
