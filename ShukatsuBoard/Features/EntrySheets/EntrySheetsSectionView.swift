import SwiftData
import SwiftUI

struct EntrySheetsSectionView: View {
    @Environment(\.modelContext) private var modelContext

    let company: Company

    @State private var isAdding = false

    var body: some View {
        Section {
            if company.entrySheets.isEmpty {
                EmptyStateView(title: "ES設問がありません", systemImage: "doc.text")
            } else {
                ForEach(company.entrySheets.sorted { $0.updatedAt > $1.updatedAt }) { entrySheet in
                    NavigationLink {
                        EntrySheetFormView(company: company, entrySheet: entrySheet)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(entrySheet.question)
                                .font(.headline)
                                .lineLimit(2)

                            HStack {
                                Text("\(entrySheet.currentCharacterCount)字")
                                if let characterLimit = entrySheet.characterLimit {
                                    Text("/ \(characterLimit)字")
                                }
                                Text("v\(entrySheet.version)")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteEntrySheets)
            }
        } header: {
            HStack {
                Text("ES")
                Spacer()
                Button {
                    isAdding = true
                } label: {
                    Image(systemName: "plus.circle")
                }
                .accessibilityLabel("ESを追加")
            }
        }
        .sheet(isPresented: $isAdding) {
            NavigationStack {
                EntrySheetFormView(company: company)
            }
        }
    }

    private func deleteEntrySheets(at offsets: IndexSet) {
        let sorted = company.entrySheets.sorted { $0.updatedAt > $1.updatedAt }
        for offset in offsets {
            modelContext.delete(sorted[offset])
        }
        company.touch()
    }
}
