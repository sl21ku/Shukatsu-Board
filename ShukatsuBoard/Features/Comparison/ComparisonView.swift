import SwiftData
import SwiftUI

struct ComparisonView: View {
    @Query(sort: \Company.priority, order: .reverse) private var companies: [Company]

    private var comparableCompanies: [Company] {
        companies.sorted {
            if $0.priority == $1.priority {
                return $0.updatedAt > $1.updatedAt
            }
            return $0.priority > $1.priority
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if comparableCompanies.isEmpty {
                    EmptyStateView(title: "比較する企業がありません", systemImage: "tablecells")
                } else {
                    Section("企業比較") {
                        ForEach(comparableCompanies) { company in
                            ComparisonCompanyRow(company: company)
                        }
                    }
                }
            }
            .navigationTitle("比較")
        }
    }
}

private struct ComparisonCompanyRow: View {
    let company: Company

    private var latestPosting: JobPosting? {
        company.jobPostings.sorted { $0.updatedAt > $1.updatedAt }.first
    }

    private var nextTask: TaskItem? {
        company.tasks
            .filter { !$0.isCompleted }
            .sorted { ($0.dueAt ?? .distantFuture) < ($1.dueAt ?? .distantFuture) }
            .first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(company.name)
                        .font(.headline)
                    Text(company.industry ?? "業界未設定")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: company.status)
                    Label("\(company.priority)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    ComparisonField(title: "職種", value: latestPosting?.position)
                    ComparisonField(title: "勤務地", value: latestPosting?.location)
                }
                GridRow {
                    ComparisonField(title: "給与", value: latestPosting?.salary)
                    ComparisonField(title: "福利厚生", value: latestPosting?.benefits)
                }
                GridRow {
                    ComparisonField(
                        title: "次の予定",
                        value: nextTask.flatMap { task in
                            if let dueAt = task.dueAt {
                                return "\(task.title) \(Formatters.date.string(from: dueAt))"
                            }
                            return task.title
                        }
                    )
                    ComparisonField(
                        title: "締切",
                        value: latestPosting?.deadline.map { Formatters.date.string(from: $0) }
                    )
                }
            }
        }
        .padding(.vertical, 6)
    }
}

private struct ComparisonField: View {
    let title: String
    let value: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value?.isEmpty == false ? value! : "未設定")
                .font(.caption)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
