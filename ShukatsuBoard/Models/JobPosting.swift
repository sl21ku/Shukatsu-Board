import Foundation
import SwiftData

@Model
final class JobPosting {
    @Attribute(.unique) var id: UUID
    var position: String?
    var location: String?
    var salary: String?
    var benefits: String?
    var requirements: String?
    var deadline: Date?
    var selectionFlow: String?
    var sourceUrl: String?
    var rawText: String?
    var createdAt: Date
    var updatedAt: Date
    var company: Company?

    init(
        id: UUID = UUID(),
        company: Company? = nil,
        position: String? = nil,
        location: String? = nil,
        salary: String? = nil,
        benefits: String? = nil,
        requirements: String? = nil,
        deadline: Date? = nil,
        selectionFlow: String? = nil,
        sourceUrl: String? = nil,
        rawText: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.company = company
        self.position = position
        self.location = location
        self.salary = salary
        self.benefits = benefits
        self.requirements = requirements
        self.deadline = deadline
        self.selectionFlow = selectionFlow
        self.sourceUrl = sourceUrl
        self.rawText = rawText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func touch() {
        updatedAt = .now
        company?.touch()
    }
}
