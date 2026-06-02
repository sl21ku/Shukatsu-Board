import SwiftData
import SwiftUI

@main
struct ShukatsuBoardApp: App {
    private let modelContainer = AppModelContainer.make()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
