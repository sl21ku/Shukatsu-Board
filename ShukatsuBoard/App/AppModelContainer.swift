import Foundation
import SwiftData

enum AppModelContainer {
    static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
            ProcessInfo.processInfo.environment["UI_TESTING"] == "1"
    }

    static func make() -> ModelContainer {
        do {
            let schema = Schema([
                Company.self,
                EntrySheet.self,
                JobPosting.self,
                TaskItem.self
            ])

            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: isRunningTests
            )

            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create SwiftData model container: \(error)")
        }
    }
}
