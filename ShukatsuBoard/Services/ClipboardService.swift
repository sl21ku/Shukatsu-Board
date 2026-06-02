import Foundation
import UIKit

@MainActor
struct ClipboardService {
    static let shared = ClipboardService()

    func copy(_ value: String, clearAfter seconds: TimeInterval = 60) {
        UIPasteboard.general.string = value

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(seconds))
            if UIPasteboard.general.string == value {
                UIPasteboard.general.string = ""
            }
        }
    }
}
