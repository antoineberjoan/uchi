import Foundation
import Security

public struct KeyStore {
    private let service = "local.imi.personnel"

    public init() {}

    private func makeQuery(account: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: false,
        ]
        #if os(iOS)
        query[kSecAttrAccessGroup as String] = AppGroup.identifier
        #endif
        return query
    }

    public func read(account: String) throws -> String? {
        var query = makeQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else { throw KeyFailure(status: status) }
        return key
    }

    public func save(_ key: String, account: String) throws {
        let query = makeQuery(account: account)
        let data = Data(key.utf8)
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var insert = query
            insert[kSecValueData as String] = data
            insert[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let added = SecItemAdd(insert as CFDictionary, nil)
            guard added == errSecSuccess else { throw KeyFailure(status: added) }
        } else if status != errSecSuccess { throw KeyFailure(status: status) }
    }
}

public struct KeyFailure: LocalizedError {
    public let status: OSStatus
    public var errorDescription: String? {
        "Le trousseau n’a pas autorisé l’opération (\(status)). Déverrouillez l’appareil et autorisez imi, puis réessayez."
    }
}
