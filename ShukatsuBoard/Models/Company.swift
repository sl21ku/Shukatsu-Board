import Foundation
import SwiftData

@Model
final class Company {
    @Attribute(.unique) var id: UUID
    var name: String
    var industry: String?
    var priority: Int
    var statusRawValue: String
    var myPageUrl: String?
    var jobPageUrl: String?
    var loginId: String?
    var passwordKeychainId: String?
    var memo: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \EntrySheet.company)
    var entrySheets: [EntrySheet]

    @Relationship(deleteRule: .cascade, inverse: \JobPosting.company)
    var jobPostings: [JobPosting]

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.company)
    var tasks: [TaskItem]

    init(
        id: UUID = UUID(),
        name: String,
        industry: String? = nil,
        priority: Int = 3,
        status: SelectionStatus = .considering,
        myPageUrl: String? = nil,
        jobPageUrl: String? = nil,
        loginId: String? = nil,
        passwordKeychainId: String? = nil,
        memo: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.industry = industry
        self.priority = priority
        self.statusRawValue = status.rawValue
        self.myPageUrl = myPageUrl
        self.jobPageUrl = jobPageUrl
        self.loginId = loginId
        self.passwordKeychainId = passwordKeychainId
        self.memo = memo
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.entrySheets = []
        self.jobPostings = []
        self.tasks = []
    }

    var status: SelectionStatus {
        get { SelectionStatus(rawValue: statusRawValue) ?? .custom }
        set {
            statusRawValue = newValue.rawValue
            touch()
        }
    }

    func touch() {
        updatedAt = .now
    }
}
