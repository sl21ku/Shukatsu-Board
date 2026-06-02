import Foundation
import UserNotifications

struct NotificationService {
    static let shared = NotificationService()

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleReminder(for task: TaskItem) async throws {
        guard let reminderAt = task.reminderAt, reminderAt > .now else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = task.company?.name ?? "Shukatsu Board"
        content.body = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderAt)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: task),
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier(for: task)])
        try await UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for task: TaskItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier(for: task)])
    }

    private func notificationIdentifier(for task: TaskItem) -> String {
        "task-\(task.id.uuidString)"
    }
}
