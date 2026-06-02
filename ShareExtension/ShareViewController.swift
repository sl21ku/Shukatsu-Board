import MobileCoreServices
import Social
import UniformTypeIdentifiers
import UIKit

final class ShareViewController: UIViewController {
    private let appGroupIdentifier = "group.com.example.ShukatsuBoard"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        handleSharedItems()
    }

    private func handleSharedItems() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            complete()
            return
        }

        var payload: [String: String] = [:]
        let group = DispatchGroup()

        for item in items {
            payload["title"] = item.attributedTitle?.string ?? item.attributedContentText?.string

            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, _ in
                        if let url = item as? URL {
                            payload["url"] = url.absoluteString
                        }
                        group.leave()
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { item, _ in
                        if let text = item as? String {
                            payload["text"] = text
                        }
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            let defaults = UserDefaults(suiteName: self.appGroupIdentifier)
            defaults?.set(payload, forKey: "latestSharePayload")
            defaults?.synchronize()
            self.complete()
        }
    }

    private func complete() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
