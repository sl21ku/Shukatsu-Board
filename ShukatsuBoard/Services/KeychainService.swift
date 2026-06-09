import Foundation
import Security

enum KeychainError: LocalizedError {
    case unexpectedStatus(OSStatus)
    case dataEncodingFailed
    case itemNotFound

    var errorDescription: String? {
        switch self {
        case .unexpectedStatus(let status): "Keychain error: \(status)"
        case .dataEncodingFailed: "パスワードの変換に失敗しました。"
        case .itemNotFound: "保存されたパスワードが見つかりません。"
        }
    }
}

struct KeychainService {
    static let shared = KeychainService()

    private let service = "com.sl21ku.ShukatsuBoard.passwords"

    func savePassword(_ password: String, id: String = UUID().uuidString) throws -> String {
        guard let data = password.data(using: .utf8) else {
            throw KeychainError.dataEncodingFailed
        }

        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id
        ]

        SecItemDelete(baseQuery as CFDictionary)

        var addQuery = baseQuery
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        return id
    }

    func loadPassword(id: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        guard
            let data = result as? Data,
            let password = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.dataEncodingFailed
        }

        return password
    }

    func deletePassword(id: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
