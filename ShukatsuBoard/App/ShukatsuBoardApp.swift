import SwiftData
import SwiftUI

@main
struct ShukatsuBoardApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            Company.self,
            EntrySheet.self,
            JobPosting.self,
            TaskItem.self
        ])
    }
}
