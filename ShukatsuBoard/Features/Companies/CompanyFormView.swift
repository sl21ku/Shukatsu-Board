import SwiftData
import SwiftUI

struct CompanyFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let editingCompany: Company?

    @State private var name: String
    @State private var industry: String
    @State private var priority: Int
    @State private var status: SelectionStatus
    @State private var myPageUrl: String
    @State private var jobPageUrl: String
    @State private var loginId: String
    @State private var password: String
    @State private var memo: String
    @State private var errorMessage: String?

    init(company: Company? = nil) {
        self.editingCompany = company
        _name = State(initialValue: company?.name ?? "")
        _industry = State(initialValue: company?.industry ?? "")
        _priority = State(initialValue: company?.priority ?? 3)
        _status = State(initialValue: company?.status ?? .considering)
        _myPageUrl = State(initialValue: company?.myPageUrl ?? "")
        _jobPageUrl = State(initialValue: company?.jobPageUrl ?? "")
        _loginId = State(initialValue: company?.loginId ?? "")
        _password = State(initialValue: "")
        _memo = State(initialValue: company?.memo ?? "")
    }

    var body: some View {
        Form {
            Section("基本情報") {
                TextField("企業名", text: $name)
                TextField("業界", text: $industry)
                Stepper("志望度 \(priority)", value: $priority, in: 1...5)
                Picker("ステータス", selection: $status) {
                    ForEach(SelectionStatus.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
            }

            Section("マイページ") {
                TextField("マイページURL", text: $myPageUrl)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                TextField("募集ページURL", text: $jobPageUrl)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                TextField("ログインID", text: $loginId)
                    .textInputAutocapitalization(.never)
                SecureField(editingCompany == nil ? "パスワード" : "新しいパスワード（変更時のみ）", text: $password)
            }

            Section("メモ") {
                TextEditor(text: $memo)
                    .frame(minHeight: 100)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(editingCompany == nil ? "企業を追加" : "企業を編集")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    save()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        do {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordKeychainId = try savePasswordIfNeeded()

            if let editingCompany {
                editingCompany.name = trimmedName
                editingCompany.industry = industry.nilIfEmpty
                editingCompany.priority = priority
                editingCompany.status = status
                editingCompany.myPageUrl = myPageUrl.nilIfEmpty
                editingCompany.jobPageUrl = jobPageUrl.nilIfEmpty
                editingCompany.loginId = loginId.nilIfEmpty
                if let passwordKeychainId {
                    editingCompany.passwordKeychainId = passwordKeychainId
                }
                editingCompany.memo = memo.nilIfEmpty
                editingCompany.touch()
            } else {
                let company = Company(
                    name: trimmedName,
                    industry: industry.nilIfEmpty,
                    priority: priority,
                    status: status,
                    myPageUrl: myPageUrl.nilIfEmpty,
                    jobPageUrl: jobPageUrl.nilIfEmpty,
                    loginId: loginId.nilIfEmpty,
                    passwordKeychainId: passwordKeychainId,
                    memo: memo.nilIfEmpty
                )
                modelContext.insert(company)
            }

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func savePasswordIfNeeded() throws -> String? {
        guard !password.isEmpty else {
            return nil
        }

        let existingId = editingCompany?.passwordKeychainId
        return try KeychainService.shared.savePassword(password, id: existingId ?? UUID().uuidString)
    }
}

extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
