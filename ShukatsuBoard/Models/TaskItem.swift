import Foundation
import SwiftData

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var typeRawValue: String
    var dueAt: Date?
    var reminderAt: Date?
    var isCompleted: Bool
    var note: String?
    var createdAt: Date
    var updatedAt: Date
    var company: Company?

    init(
        id: UUID = UUID(),
        company: Company? = nil,
        title: String,
        type: TaskType = .other,
        dueAt: Date? = nil,
        reminderAt: Date? = nil,
        isCompleted: Bool = false,
        note: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.company = company
        self.title = title
        self.typeRawValue = type.rawValue
        self.dueAt = dueAt
        self.reminderAt = reminderAt
        self.isCompleted = isCompleted
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var type: TaskType {
        get { TaskType(rawValue: typeRawValue) ?? .other }
        set {
            typeRawValue = newValue.rawValue
            touch()
        }
    }

    func touch() {
        updatedAt = .now
        company?.touch()
    }
}
