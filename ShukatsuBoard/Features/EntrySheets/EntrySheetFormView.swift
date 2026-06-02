import SwiftUI

struct EntrySheetFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let company: Company
    let entrySheet: EntrySheet?

    @State private var question: String
    @State private var answer: String
    @State private var characterLimit: Int?
    @State private var hasSubmittedAt: Bool
    @State private var submittedAt: Date
    @State private var version: Int
    @State private var memo: String

    init(company: Company, entrySheet: EntrySheet? = nil) {
        self.company = company
        self.entrySheet = entrySheet
        _question = State(initialValue: entrySheet?.question ?? "")
        _answer = State(initialValue: entrySheet?.answer ?? "")
        _characterLimit = State(initialValue: entrySheet?.characterLimit)
        _hasSubmittedAt = State(initialValue: entrySheet?.submittedAt != nil)
        _submittedAt = State(initialValue: entrySheet?.submittedAt ?? .now)
        _version = State(initialValue: entrySheet?.version ?? 1)
        _memo = State(initialValue: entrySheet?.memo ?? "")
    }

    var body: some View {
        Form {
            Section("設問") {
                TextEditor(text: $question)
                    .frame(minHeight: 80)
            }

            Section("回答") {
                TextEditor(text: $answer)
                    .frame(minHeight: 180)
                HStack {
                    Text("\(answer.count)字")
                    Spacer()
                    if let characterLimit {
                        Text("上限 \(characterLimit)字")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Section("管理") {
                Stepper("バージョン \(version)", value: $version, in: 1...99)
                Stepper(
                    characterLimit == nil ? "文字数上限なし" : "文字数上限 \(characterLimit ?? 0)字",
                    value: Binding(
                        get: { characterLimit ?? 0 },
                        set: { characterLimit = $0 == 0 ? nil : $0 }
                    ),
                    in: 0...5000,
                    step: 50
                )

                Toggle("提出済み", isOn: $hasSubmittedAt)
                if hasSubmittedAt {
                    DatePicker("提出日", selection: $submittedAt, displayedComponents: [.date])
                }
            }

            Section("メモ") {
                TextEditor(text: $memo)
                    .frame(minHeight: 80)
            }
        }
        .navigationTitle(entrySheet == nil ? "ESを追加" : "ESを編集")
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
                .disabled(question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        if let entrySheet {
            entrySheet.question = question
            entrySheet.answer = answer
            entrySheet.characterLimit = characterLimit
            entrySheet.submittedAt = hasSubmittedAt ? submittedAt : nil
            entrySheet.version = version
            entrySheet.memo = memo.nilIfEmpty
            entrySheet.touch()
        } else {
            let newEntrySheet = EntrySheet(
                company: company,
                question: question,
                answer: answer,
                characterLimit: characterLimit,
                submittedAt: hasSubmittedAt ? submittedAt : nil,
                version: version,
                memo: memo.nilIfEmpty
            )
            modelContext.insert(newEntrySheet)
            company.touch()
        }
        dismiss()
    }
}
