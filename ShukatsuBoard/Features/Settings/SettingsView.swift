import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    @Query private var companies: [Company]

    @AppStorage("privacyPolicyURL") private var privacyPolicyURL = "https://example.com/privacy"
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("セキュリティ") {
                    Label("パスワードはKeychainに保存", systemImage: "key")
                    Label("コピー前にFace ID / Touch ID認証", systemImage: "faceid")
                    Label("企業サイトへの自動ログインなし", systemImage: "hand.raised")
                }

                Section("通知") {
                    Button {
                        Task {
                            await requestNotifications()
                        }
                    } label: {
                        Label("通知を許可", systemImage: "bell")
                    }
                }

                Section("デモモード") {
                    Button {
                        DemoDataService.insertDemoData(into: modelContext)
                        alertMessage = "デモデータを追加しました。"
                    } label: {
                        Label("デモデータを追加", systemImage: "sparkles")
                    }
                }

                Section("プライバシー") {
                    TextField("プライバシーポリシーURL", text: $privacyPolicyURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)

                    Button {
                        if let url = URL(string: privacyPolicyURL) {
                            openURL(url)
                        }
                    } label: {
                        Label("プライバシーポリシーを開く", systemImage: "lock.shield")
                    }
                }
            }
            .navigationTitle("設定")
            .alert("設定", isPresented: .constant(alertMessage != nil)) {
                Button("OK") {
                    alertMessage = nil
                }
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    @MainActor
    private func requestNotifications() async {
        do {
            let granted = try await NotificationService.shared.requestAuthorization()
            alertMessage = granted ? "通知が許可されました。" : "通知は許可されませんでした。"
        } catch {
            alertMessage = error.localizedDescription
        }
    }
}
