import Foundation
#if canImport(CoreGraphics)
// Sur macOS, l'overlay fournit les accès géométriques de CGRect.
import CoreGraphics
#endif

public enum PanelPlacement {
    /// Toutes les coordonnées sont dans l'espace AppKit, origine en bas à gauche.
    public static func position(selection: CGRect?, screen: CGRect, size: CGSize, margin: CGFloat) -> CGPoint {
        let x = selection?.minX ?? screen.midX - size.width / 2
        let below = selection.map { $0.minY - margin - size.height }
        let y: CGFloat
        if let below, below >= screen.minY + margin { y = below }
        else if let selection { y = selection.maxY + margin }
        else { y = screen.midY - size.height / 2 }
        return CGPoint(x: max(screen.minX + margin, min(x, screen.maxX - size.width - margin)),
                       y: max(screen.minY + margin, min(y, screen.maxY - size.height - margin)))
    }

    public static func convertAccessibilityRect(_ rect: CGRect, desktopTop: CGFloat) -> CGRect {
        CGRect(x: rect.minX, y: desktopTop - rect.maxY, width: rect.width, height: rect.height)
    }
}
