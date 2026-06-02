import Foundation
import SwiftUI

enum TaskType: String, CaseIterable, Identifiable {
    case esDeadline
    case interview
    case webTest
    case seminar
    case documentSubmit
    case followUp
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .esDeadline: "ES締切"
        case .interview: "面接"
        case .webTest: "Webテスト"
        case .seminar: "説明会"
        case .documentSubmit: "書類提出"
        case .followUp: "フォロー"
        case .other: "その他"
        }
    }

    var iconName: String {
        switch self {
        case .esDeadline: "doc.text"
        case .interview: "person.2"
        case .webTest: "desktopcomputer"
        case .seminar: "megaphone"
        case .documentSubmit: "tray.and.arrow.up"
        case .followUp: "arrow.uturn.forward"
        case .other: "checkmark.circle"
        }
    }
}
