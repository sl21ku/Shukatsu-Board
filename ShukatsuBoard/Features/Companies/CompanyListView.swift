import SwiftData
import SwiftUI

struct CompanyListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Company.updatedAt, order: .reverse) private var companies: [Company]

    @State private var searchText = ""
    @State private var selectedStatus: SelectionStatus?
    @State private var isAddingCompany = false

    private var filteredCompanies: [Company] {
        companies.filter { company in
            let matchesSearch = searchText.isEmpty ||
                company.name.localizedCaseInsensitiveContains(searchText) ||
                (company.industry?.localizedCaseInsensitiveContains(searchText) ?? false)
            let matchesStatus = selectedStatus == nil || company.status == selectedStatus
            return matchesSearch && matchesStatus
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("ステータス", selection: $selectedStatus) {
                        Text("すべて").tag(SelectionStatus?.none)
                        ForEach(SelectionStatus.allCases) { status in
                            Text(status.title).tag(Optional(status))
                        }
                    }
                }

                if filteredCompanies.isEmpty {
                    EmptyStateView(title: "企業がありません", systemImage: "building.2")
                } else {
                    ForEach(filteredCompanies) { company in
                        NavigationLink {
                            CompanyDetailView(company: company)
                        } label: {
                            CompanyCompactRow(company: company)
                        }
                    }
                    .onDelete(perform: deleteCompanies)
                }
            }
            .navigationTitle("企業")
            .searchable(text: $searchText, prompt: "企業名・業界")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingCompany = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("企業を追加")
                }
            }
            .sheet(isPresented: $isAddingCompany) {
                NavigationStack {
                    CompanyFormView()
                }
            }
        }
    }

    private func deleteCompanies(at offsets: IndexSet) {
        for offset in offsets {
            let company = filteredCompanies[offset]
            if let keychainId = company.passwordKeychainId {
                try? KeychainService.shared.deletePassword(id: keychainId)
            }
            modelContext.delete(company)
        }
    }
}
