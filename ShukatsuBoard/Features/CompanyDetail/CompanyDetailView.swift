import SwiftData
import SwiftUI

struct CompanyDetailView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext

    let company: Company

    @State private var selectedTab = CompanyDetailTab.overview
    @State private var isEditingCompany = false
    @State private var alertMessage: String?

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(company.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        StatusBadge(status: company.status)
                    }

                    HStack(spacing: 14) {
                        Label(company.industry ?? "業界未設定", systemImage: "tag")
                        Label("志望度 \(company.priority)", systemImage: "star")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section {
                Picker("表示", selection: $selectedTab) {
                    ForEach(CompanyDetailTab.allCases) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
            }

            switch selectedTab {
            case .overview:
                overviewSection
            case .entrySheets:
                EntrySheetsSectionView(company: company)
            case .jobPostings:
                JobPostingsSectionView(company: company)
            case .tasks:
                CompanyTasksSectionView(company: company)
            }
        }
        .navigationTitle(company.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditingCompany = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .accessibilityLabel("企業情報を編集")
            }
        }
        .sheet(isPresented: $isEditingCompany) {
            NavigationStack {
                CompanyFormView(company: company)
            }
        }
        .alert("確認", isPresented: .constant(alertMessage != nil)) {
            Button("OK") {
                alertMessage = nil
            }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var overviewSection: some View {
        Group {
            Section("マイページ") {
                if let loginId = company.loginId {
                    Button {
                        ClipboardService.shared.copy(loginId, clearAfter: 60)
                        alertMessage = "IDをコピーしました。"
                    } label: {
                        Label("IDをコピー", systemImage: "doc.on.doc")
                    }
                }

                if company.passwordKeychainId != nil {
                    Button {
                        Task {
                            await copyPassword()
                        }
                    } label: {
                        Label("Face IDで認証してパスワードをコピー", systemImage: "faceid")
                    }
                }

                if let myPageUrl = company.myPageUrl, let url = URL(string: myPageUrl) {
                    Button {
                        openURL(url)
                    } label: {
                        Label("マイページを開く", systemImage: "safari")
                    }
                }

                if let jobPageUrl = company.jobPageUrl, let url = URL(string: jobPageUrl) {
                    Button {
                        openURL(url)
                    } label: {
                        Label("募集ページを開く", systemImage: "link")
                    }
                }
            }

            Section("メモ") {
                if let memo = company.memo, !memo.isEmpty {
                    Text(memo)
                } else {
                    Text("メモはありません")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @MainActor
    private func copyPassword() async {
        guard let keychainId = company.passwordKeychainId else {
            return
        }

        do {
            _ = try await BiometricAuthService.shared.authenticate(reason: "マイページのパスワードをコピーします。")
            let password = try KeychainService.shared.loadPassword(id: keychainId)
            ClipboardService.shared.copy(password, clearAfter: 60)
            alertMessage = "パスワードをコピーしました。60秒後にクリップボードをクリアします。"
        } catch {
            alertMessage = error.localizedDescription
        }
    }
}

private enum CompanyDetailTab: String, CaseIterable, Identifiable {
    case overview
    case entrySheets
    case jobPostings
    case tasks

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "概要"
        case .entrySheets: "ES"
        case .jobPostings: "募集"
        case .tasks: "タスク"
        }
    }
}
