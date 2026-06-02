import SwiftUI

struct JobPostingFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let company: Company
    let jobPosting: JobPosting?

    @State private var position: String
    @State private var location: String
    @State private var salary: String
    @State private var benefits: String
    @State private var requirements: String
    @State private var hasDeadline: Bool
    @State private var deadline: Date
    @State private var selectionFlow: String
    @State private var sourceUrl: String
    @State private var rawText: String

    init(company: Company, jobPosting: JobPosting? = nil) {
        self.company = company
        self.jobPosting = jobPosting
        _position = State(initialValue: jobPosting?.position ?? "")
        _location = State(initialValue: jobPosting?.location ?? "")
        _salary = State(initialValue: jobPosting?.salary ?? "")
        _benefits = State(initialValue: jobPosting?.benefits ?? "")
        _requirements = State(initialValue: jobPosting?.requirements ?? "")
        _hasDeadline = State(initialValue: jobPosting?.deadline != nil)
        _deadline = State(initialValue: jobPosting?.deadline ?? .now)
        _selectionFlow = State(initialValue: jobPosting?.selectionFlow ?? "")
        _sourceUrl = State(initialValue: jobPosting?.sourceUrl ?? "")
        _rawText = State(initialValue: jobPosting?.rawText ?? "")
    }

    var body: some View {
        Form {
            Section("募集情報") {
                TextField("職種・ポジション", text: $position)
                TextField("勤務地", text: $location)
                TextField("給与", text: $salary)
                TextField("福利厚生", text: $benefits)
                TextField("応募条件", text: $requirements)
            }

            Section("締切・選考") {
                Toggle("締切あり", isOn: $hasDeadline)
                if hasDeadline {
                    DatePicker("締切", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                }
                TextEditor(text: $selectionFlow)
                    .frame(minHeight: 80)
            }

            Section("ソース") {
                TextField("URL", text: $sourceUrl)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                TextEditor(text: $rawText)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle(jobPosting == nil ? "募集要項を追加" : "募集要項を編集")
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
            }
        }
    }

    private func save() {
        if let jobPosting {
            jobPosting.position = position.nilIfEmpty
            jobPosting.location = location.nilIfEmpty
            jobPosting.salary = salary.nilIfEmpty
            jobPosting.benefits = benefits.nilIfEmpty
            jobPosting.requirements = requirements.nilIfEmpty
            jobPosting.deadline = hasDeadline ? deadline : nil
            jobPosting.selectionFlow = selectionFlow.nilIfEmpty
            jobPosting.sourceUrl = sourceUrl.nilIfEmpty
            jobPosting.rawText = rawText.nilIfEmpty
            jobPosting.touch()
        } else {
            let posting = JobPosting(
                company: company,
                position: position.nilIfEmpty,
                location: location.nilIfEmpty,
                salary: salary.nilIfEmpty,
                benefits: benefits.nilIfEmpty,
                requirements: requirements.nilIfEmpty,
                deadline: hasDeadline ? deadline : nil,
                selectionFlow: selectionFlow.nilIfEmpty,
                sourceUrl: sourceUrl.nilIfEmpty,
                rawText: rawText.nilIfEmpty
            )
            modelContext.insert(posting)
            company.touch()
        }
        dismiss()
    }
}
