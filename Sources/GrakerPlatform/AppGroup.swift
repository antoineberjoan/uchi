import Foundation

/// Identifiant partagé entre l’app iOS et le clavier (préférences ; trousseau avec access group côté iOS).
public enum AppGroup {
    public static let identifier = "group.local.graker.personnel"

    public static var defaults: UserDefaults {
        guard let suite = UserDefaults(suiteName: identifier) else {
            preconditionFailure("Impossible d’ouvrir le conteneur partagé \(identifier). Vérifiez l’App Group.")
        }
        return suite
    }
}
