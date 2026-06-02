import Foundation
import LocalAuthentication

enum BiometricAuthError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable: "Face ID / Touch ID または端末パスコードが利用できません。"
        }
    }
}

struct BiometricAuthService {
    static let shared = BiometricAuthService()

    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            throw error ?? BiometricAuthError.unavailable
        }

        return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
    }
}
