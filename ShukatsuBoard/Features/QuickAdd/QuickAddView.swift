import SwiftData
import SwiftUI
import PhotosUI

struct QuickAddView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Company.name) private var companies: [Company]

    @State private var inputText = ""
    @State private var candidate: ParsedImportCandidate?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isRunningOCR = false
    @State private var selectedCompanyId: UUID?
    @State private var shouldCreateTask = true
    @State private var shouldCreateJobPosting = true
    @State private var shouldCreateEntrySheets = true
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("スクショOCR") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("画像から文字を読み取る", systemImage: "text.viewfinder")
                    }

                    if isRunningOCR {
                        ProgressView("文字認識中")
                    }
                }

                Section("取り込みテキスト") {
                    TextEditor(text: $inputText)
                        .frame(minHeight: 180)
                        .overlay(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("メール本文、募集要項、共有されたURLなどを貼り付け")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                        }

                    Button {
                        candidate = ImportParserService.shared.parse(inputText)
                        selectedCompanyId = existingCompanyId(for: candidate?.companyName)
                    } label: {
                        Label("解析する", systemImage: "wand.and.stars")
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if let candidate {
                    Section("候補") {
                        LabeledContent("企業名", value: candidate.companyName ?? "未検出")
                        LabeledContent("URL", value: candidate.url?.absoluteString ?? "未検出")
                        LabeledContent("職種", value: candidate.position ?? "未検出")
                        LabeledContent("勤務地", value: candidate.location ?? "未検出")
                        LabeledContent("給与", value: candidate.salary ?? "未検出")

                        if let firstDate = candidate.detectedDates.first {
                            LabeledContent("日時候補", value: Formatters.dateTime.string(from: firstDate))
                        }
                    }

                    Section("保存先") {
                        Picker("企業", selection: $selectedCompanyId) {
                            Text("新規作成").tag(UUID?.none)
                            ForEach(companies) { company in
                                Text(company.name).tag(Optional(company.id))
                            }
                        }

                        Toggle("募集要項を作成", isOn: $shouldCreateJobPosting)
                        Toggle("タスクを作成", isOn: $shouldCreateTask)
                        Toggle("ES設問を作成", isOn: $shouldCreateEntrySheets)
                    }

                    Section {
                        Button {
                            save(candidate)
                        } label: {
                            Label("確認して保存", systemImage: "checkmark.circle")
                        }
                    }
                }
            }
            .navigationTitle("クイック追加")
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await runOCR(for: newItem)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        loadSharedText()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .accessibilityLabel("共有データを読み込む")
                }
            }
            .alert("Quick Add", isPresented: .constant(alertMessage != nil)) {
                Button("OK") {
                    alertMessage = nil
                }
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    @MainActor
    private func runOCR(for item: PhotosPickerItem?) async {
        guard let item else {
            return
        }

        isRunningOCR = true
        defer { isRunningOCR = false }

        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                throw OCRServiceError.missingImageData
            }

            let recognizedText = try await OCRService.shared.recognizeText(in: image)
            inputText = [inputText, recognizedText]
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .joined(separator: "\n")
            candidate = ImportParserService.shared.parse(inputText)
            selectedCompanyId = existingCompanyId(for: candidate?.companyName)
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    private func save(_ candidate: ParsedImportCandidate) {
        let company = selectedCompanyId.flatMap { id in
            companies.first { $0.id == id }
        } ?? Company(
            name: candidate.companyName ?? "名称未設定の企業",
            status: .considering,
            jobPageUrl: candidate.url?.absoluteString,
            memo: "Quick Addから作成"
        )

        if selectedCompanyId == nil {
            modelContext.insert(company)
        }

        if shouldCreateJobPosting {
            let posting = JobPosting(
                company: company,
                position: candidate.position,
                location: candidate.location,
                salary: candidate.salary,
                deadline: candidate.detectedDates.first,
                sourceUrl: candidate.url?.absoluteString,
                rawText: candidate.rawText
            )
            modelContext.insert(posting)
        }

        if shouldCreateTask, let title = candidate.suggestedTaskTitle {
            let dueAt = candidate.detectedDates.first
            let task = TaskItem(
                company: company,
                title: title,
                type: detectTaskType(from: candidate.rawText),
                dueAt: dueAt,
                reminderAt: dueAt.flatMap { Calendar.current.date(byAdding: .day, value: -1, to: $0) }
            )
            modelContext.insert(task)

            Task {
                _ = try? await NotificationService.shared.requestAuthorization()
                try? await NotificationService.shared.scheduleReminder(for: task)
            }
        }

        if shouldCreateEntrySheets {
            for question in candidate.entrySheetQuestions {
                modelContext.insert(EntrySheet(company: company, question: question))
            }
        }

        company.touch()
        alertMessage = "候補を保存しました。"
        inputText = ""
        self.candidate = nil
    }

    private func existingCompanyId(for name: String?) -> UUID? {
        guard let name else {
            return nil
        }

        return companies.first { $0.name.localizedCaseInsensitiveContains(name) || name.localizedCaseInsensitiveContains($0.name) }?.id
    }

    private func detectTaskType(from text: String) -> TaskType {
        if text.contains("面接") { return .interview }
        if text.contains("Webテスト") || text.contains("WEBテスト") { return .webTest }
        if text.contains("説明会") { return .seminar }
        if text.contains("ES") || text.contains("エントリーシート") { return .esDeadline }
        if text.contains("書類") { return .documentSubmit }
        return .other
    }

    private func loadSharedText() {
        let defaults = UserDefaults(suiteName: "group.com.sl21ku.ShukatsuBoard")
        guard let payload = defaults?.dictionary(forKey: "latestSharePayload") else {
            alertMessage = "共有データはありません。"
            return
        }

        let text = [payload["title"], payload["url"], payload["text"]]
            .compactMap { $0 as? String }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")

        guard !text.isEmpty else {
            alertMessage = "共有データは空でした。"
            return
        }

        inputText = text
        candidate = ImportParserService.shared.parse(text)
        selectedCompanyId = existingCompanyId(for: candidate?.companyName)
        defaults?.removeObject(forKey: "latestSharePayload")
    }
}
