import Foundation
import SwiftUI

enum SelectionStatus: String, CaseIterable, Identifiable {
    case notApplied
    case considering
    case applied
    case esSubmitted
    case webTest
    case firstInterview
    case secondInterview
    case finalInterview
    case offer
    case declined
    case rejected
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .notApplied: "未応募"
        case .considering: "検討中"
        case .applied: "応募済み"
        case .esSubmitted: "ES提出済み"
        case .webTest: "Webテスト"
        case .firstInterview: "一次面接"
        case .secondInterview: "二次面接"
        case .finalInterview: "最終面接"
        case .offer: "内定"
        case .declined: "辞退"
        case .rejected: "不合格"
        case .custom: "カスタム"
        }
    }

    var tint: Color {
        switch self {
        case .notApplied: .gray
        case .considering: .teal
        case .applied, .esSubmitted, .webTest: .blue
        case .firstInterview, .secondInterview, .finalInterview: .indigo
        case .offer: .green
        case .declined: .orange
        case .rejected: .red
        case .custom: .purple
        }
    }
}
