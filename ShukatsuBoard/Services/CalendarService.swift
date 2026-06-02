import EventKit
import Foundation

enum CalendarServiceError: LocalizedError {
    case accessDenied
    case missingDate

    var errorDescription: String? {
        switch self {
        case .accessDenied: "カレンダーへのアクセスが許可されていません。"
        case .missingDate: "カレンダーに追加する日時がありません。"
        }
    }
}

struct CalendarService {
    static let shared = CalendarService()

    private let eventStore = EKEventStore()

    func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }

    func addEvent(for task: TaskItem) async throws {
        guard let dueAt = task.dueAt else {
            throw CalendarServiceError.missingDate
        }

        let granted = try await requestAccess()
        guard granted else {
            throw CalendarServiceError.accessDenied
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = [task.company?.name, task.title]
            .compactMap { $0 }
            .joined(separator: " ")
        event.notes = task.note
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.startDate = dueAt
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: dueAt) ?? dueAt

        try eventStore.save(event, span: .thisEvent)
    }
}
