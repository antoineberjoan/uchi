#if os(macOS)
import Foundation
import GrakerCore

struct PreferencesStore {
    private let key = "configuration"
    private var defaults: UserDefaults { .standard }

    func load() throws -> Configuration {
        guard let data = defaults.data(forKey: key) else { return Configuration() }
        let configuration = try JSONDecoder().decode(Configuration.self, from: data)
        _ = try configuration.validate()
        return configuration
    }

    func save(_ configuration: Configuration) throws {
        _ = try configuration.validate()
        defaults.set(try JSONEncoder().encode(configuration), forKey: key)
    }
}
#endif
