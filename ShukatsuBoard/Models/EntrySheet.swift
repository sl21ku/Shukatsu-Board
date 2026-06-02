import Foundation
import SwiftData

@Model
final class EntrySheet {
    @Attribute(.unique) var id: UUID
    var question: String
    var answer: String
    var characterLimit: Int?
    var submittedAt: Date?
    var version: Int
    var memo: String?
    var createdAt: Date
    var updatedAt: Date
    var company: Company?

    init(
        id: UUID = UUID(),
        company: Company? = nil,
        question: String,
        answer: String = "",
        characterLimit: Int? = nil,
        submittedAt: Date? = nil,
        version: Int = 1,
        memo: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.company = company
        self.question = question
        self.answer = answer
        self.characterLimit = characterLimit
        self.submittedAt = submittedAt
        self.version = version
        self.memo = memo
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var currentCharacterCount: Int {
        answer.count
    }

    func touch() {
        updatedAt = .now
        company?.touch()
    }
}
