import EventKit
import Foundation

enum CalendarServiceError: LocalizedError {
    case accessDenied
    case accessRestricted
    case missingDate
    case missingCalendar

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            "カレンダーへのアクセスが許可されていません。設定アプリでカレンダーへの追加を許可してください。"
        case .accessRestricted:
            "この端末ではカレンダーへのアクセスが制限されています。"
        case .missingDate:
            "カレンダーに追加する日時がありません。"
        case .missingCalendar:
            "追加先のカレンダーが見つかりません。"
        }
    }
}

struct CalendarService {
    static let shared = CalendarService()

    private let eventStore = EKEventStore()

    func requestAccess() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            switch status {
            case .fullAccess, .writeOnly:
                return true
            case .notDetermined:
                return try await withCheckedThrowingContinuation { continuation in
                    eventStore.requestWriteOnlyAccessToEvents { granted, error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: granted)
                        }
                    }
                }
            case .denied:
                return false
            case .restricted:
                throw CalendarServiceError.accessRestricted
            @unknown default:
                return false
            }
        }

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        case .denied:
            return false
        case .restricted:
            throw CalendarServiceError.accessRestricted
        @unknown default:
            return false
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

        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            throw CalendarServiceError.missingCalendar
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = [task.company?.name, task.title]
            .compactMap { $0 }
            .joined(separator: " ")
        event.notes = task.note
        event.calendar = calendar
        event.startDate = dueAt
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: dueAt) ?? dueAt

        try eventStore.save(event, span: .thisEvent)
    }
}
