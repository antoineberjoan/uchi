import Foundation

/// Distingue un collage d'une frappe à la main. Taper ajoute un caractère à la fois.
public enum InputChange {
    public static func isPaste(from old: String, to new: String) -> Bool {
        new.count - old.count >= 2 && !new.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
