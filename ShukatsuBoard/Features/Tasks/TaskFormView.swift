import SwiftData
import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let task: TaskItem?
    private let fixedCompany: Company?
    private let companies: [Company]

    @State private var title: String
    @State private var type: TaskType
    @State private var companyId: UUID?
    @State private var hasDueAt: Bool
    @State private var dueAt: Date
    @State private var hasReminderAt: Bool
    @State private var reminderAt: Date
    @State private var shouldAddToCalendar: Bool
    @State private var isRequestingCalendarAccess = false
    @State private var isCompleted: Bool
    @State private var note: String
    @State private var errorMessage: String?

    init(task: TaskItem? = nil, fixedCompany: Company? = nil, companies: [Company]) {
        self.task = task
        self.fixedCompany = fixedCompany
        self.companies = companies
        _title = State(initialValue: task?.title ?? "")
        _type = State(initialValue: task?.type ?? .other)
        _companyId = State(initialValue: fixedCompany?.id ?? task?.company?.id)
        _hasDueAt = State(initialValue: task?.dueAt != nil)
        _dueAt = State(initialValue: task?.dueAt ?? .now)
        _hasReminderAt = State(initialValue: task?.reminderAt != nil)
        _reminderAt = State(initialValue: task?.reminderAt ?? .now)
        _shouldAddToCalendar = State(initialValue: false)
        _isCompleted = State(initialValue: task?.isCompleted ?? false)
        _note = State(initialValue: task?.note ?? "")
    }

    var body: some View {
        Form {
            Section("内容") {
                TextField("タイトル", text: $title)
                Picker("種類", selection: $type) {
                    ForEach(TaskType.allCases) { type in
                        Label(type.title, systemImage: type.iconName).tag(type)
                    }
                }

                if fixedCompany == nil {
                    Picker("企業", selection: $companyId) {
                        Text("未指定").tag(UUID?.none)
                        ForEach(companies) { company in
                            Text(company.name).tag(Optional(company.id))
                        }
                    }
                } else if let fixedCompany {
                    LabeledContent("企業", value: fixedCompany.name)
                }

                Toggle("完了", isOn: $isCompleted)
            }

            Section("日時") {
                Toggle("期限あり", isOn: $hasDueAt)
                if hasDueAt {
                    DatePicker("期限", selection: $dueAt, displayedComponents: [.date, .hourAndMinute])
                }

                Toggle("通知あり", isOn: $hasReminderAt)
                if hasReminderAt {
                    DatePicker("通知", selection: $reminderAt, displayedComponents: [.date, .hourAndMinute])
                }

                Toggle("カレンダーに追加", isOn: $shouldAddToCalendar)
                    .disabled(!hasDueAt || isRequestingCalendarAccess)
            }

            Section("メモ") {
                TextEditor(text: $note)
                    .frame(minHeight: 100)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(task == nil ? "タスクを追加" : "タスクを編集")
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
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onChange(of: shouldAddToCalendar) { _, wantsCalendarEvent in
            guard wantsCalendarEvent else { return }
            requestCalendarAccess()
        }
        .onChange(of: hasDueAt) { _, hasDueAt in
            if !hasDueAt {
                shouldAddToCalendar = false
            }
        }
    }

    private func save() {
        Task {
            let selectedCompany = fixedCompany ?? companies.first { $0.id == companyId }
            let targetTask: TaskItem

            if let task {
                NotificationService.shared.cancelReminder(for: task)
                task.title = title
                task.type = type
                task.company = selectedCompany
                task.dueAt = hasDueAt ? dueAt : nil
                task.reminderAt = hasReminderAt ? reminderAt : nil
                task.isCompleted = isCompleted
                task.note = note.nilIfEmpty
                task.touch()
                targetTask = task
            } else {
                let newTask = TaskItem(
                    company: selectedCompany,
                    title: title,
                    type: type,
                    dueAt: hasDueAt ? dueAt : nil,
                    reminderAt: hasReminderAt ? reminderAt : nil,
                    isCompleted: isCompleted,
                    note: note.nilIfEmpty
                )
                modelContext.insert(newTask)
                selectedCompany?.touch()
                targetTask = newTask
            }

            do {
                if !targetTask.isCompleted {
                    _ = try await NotificationService.shared.requestAuthorization()
                    try await NotificationService.shared.scheduleReminder(for: targetTask)
                }

                if shouldAddToCalendar {
                    try await CalendarService.shared.addEvent(for: targetTask)
                }

                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func requestCalendarAccess() {
        isRequestingCalendarAccess = true
        errorMessage = nil

        Task {
            do {
                let granted = try await CalendarService.shared.requestAccess()
                await MainActor.run {
                    isRequestingCalendarAccess = false
                    if !granted {
                        shouldAddToCalendar = false
                        errorMessage = CalendarServiceError.accessDenied.localizedDescription
                    }
                }
            } catch {
                await MainActor.run {
                    isRequestingCalendarAccess = false
                    shouldAddToCalendar = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
