import Foundation
import GrakerCore
import GrakerPlatform
import GrakerUI

public enum KeyboardTextService {
    public static let emptySelectionMessage =
        "Sélectionnez du texte dans le champ, puis choisissez une action."

    public static func loadConfiguration() throws -> Configuration {
        try PreferencesStore().load()
    }

    public static func process(
        source: String,
        mode: Mode,
        configuration: Configuration
    ) async throws -> String {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw KeyboardTextFailure.emptySelection }
        let output = try await TextSessionRunner.run(source: source, mode: mode, configuration: configuration)
        return output.text
    }
}

public enum KeyboardTextFailure: LocalizedError {
    case emptySelection

    public var errorDescription: String? {
        switch self {
        case .emptySelection: return KeyboardTextService.emptySelectionMessage
        }
    }
}
