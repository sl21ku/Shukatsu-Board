import SwiftData
import SwiftUI

struct JobPostingsSectionView: View {
    @Environment(\.modelContext) private var modelContext

    let company: Company

    @State private var isAdding = false

    var body: some View {
        Section {
            if company.jobPostings.isEmpty {
                EmptyStateView(title: "募集要項がありません", systemImage: "briefcase")
            } else {
                ForEach(company.jobPostings.sorted { $0.updatedAt > $1.updatedAt }) { posting in
                    NavigationLink {
                        JobPostingFormView(company: company, jobPosting: posting)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(posting.position ?? "募集要項")
                                .font(.headline)
                            if let location = posting.location {
                                Label(location, systemImage: "mappin.and.ellipse")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if let deadline = posting.deadline {
                                Label(Formatters.date.string(from: deadline), systemImage: "clock")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deletePostings)
            }
        } header: {
            HStack {
                Text("募集要項")
                Spacer()
                Button {
                    isAdding = true
                } label: {
                    Image(systemName: "plus.circle")
                }
                .accessibilityLabel("募集要項を追加")
            }
        }
        .sheet(isPresented: $isAdding) {
            NavigationStack {
                JobPostingFormView(company: company)
            }
        }
    }

    private func deletePostings(at offsets: IndexSet) {
        let sorted = company.jobPostings.sorted { $0.updatedAt > $1.updatedAt }
        for offset in offsets {
            modelContext.delete(sorted[offset])
        }
        company.touch()
    }
}
