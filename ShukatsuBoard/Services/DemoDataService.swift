import Foundation
import SwiftData

enum DemoDataService {
    static func insertDemoData(into context: ModelContext) {
        let future = Calendar.current.date(byAdding: .day, value: 5, to: .now)

        let company = Company(
            name: "サンプル株式会社",
            industry: "IT",
            priority: 4,
            status: .firstInterview,
            myPageUrl: "https://example.com/mypage",
            jobPageUrl: "https://example.com/jobs",
            loginId: "demo@example.com",
            memo: "審査用デモデータ。実在情報は含まない。"
        )

        let entrySheet = EntrySheet(
            company: company,
            question: "学生時代に力を入れたことを400字以内で教えてください。",
            answer: "チーム開発で課題整理と進行管理を担当しました。",
            characterLimit: 400
        )

        let posting = JobPosting(
            company: company,
            position: "総合職",
            location: "東京",
            salary: "月給 250,000円",
            benefits: "交通費支給、住宅補助",
            deadline: future,
            selectionFlow: "ES -> Webテスト -> 一次面接 -> 最終面接",
            sourceUrl: "https://example.com/jobs"
        )

        let task = TaskItem(
            company: company,
            title: "一次面接の準備",
            type: .interview,
            dueAt: future,
            reminderAt: Calendar.current.date(byAdding: .hour, value: -2, to: future ?? .now)
        )

        context.insert(company)
        context.insert(entrySheet)
        context.insert(posting)
        context.insert(task)
    }
}
