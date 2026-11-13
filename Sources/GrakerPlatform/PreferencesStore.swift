import Foundation
import GrakerCore

public struct PreferencesStore {
    private let key = "configuration"

    public init() {}

    #if os(iOS)
  /// Migre une fois depuis UserDefaults.standard si le groupe est vide.
    private func migrateFromStandardIfNeeded() throws -> Configuration? {
        let shared = AppGroup.defaults
        if shared.data(forKey: key) != nil { return nil }
        guard let legacy = UserDefaults.standard.data(forKey: key) else { return nil }
        let configuration = try JSONDecoder().decode(Configuration.self, from: legacy)
        _ = try configuration.validate()
        shared.set(legacy, forKey: key)
        UserDefaults.standard.removeObject(forKey: key)
        return configuration
    }
    #endif

    private var defaults: UserDefaults {
        #if os(iOS)
        AppGroup.defaults
        #else
        .standard
        #endif
    }

    public func load() throws -> Configuration {
        #if os(iOS)
        if let migrated = try migrateFromStandardIfNeeded() { return migrated }
        #endif
        guard let data = defaults.data(forKey: key) else { return Configuration() }
        let configuration = try JSONDecoder().decode(Configuration.self, from: data)
        _ = try configuration.validate()
        return configuration
    }

    public func save(_ configuration: Configuration) throws {
        _ = try configuration.validate()
        defaults.set(try JSONEncoder().encode(configuration), forKey: key)
    }
}
