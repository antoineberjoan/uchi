// Généré depuis Design/tokens.css ; ne pas modifier.
#if os(macOS)
import SwiftUI
import AppKit

enum Tokens {
    static let background = makeColor(light: (0.99032116, 0.97952103, 0.95744492), dark: (0.03360953, 0.02784535, 0.01796229))
    static let surface = makeColor(light: (0.94445386, 0.93374956, 0.91187016), dark: (0.08396877, 0.07670412, 0.06187218))
    static let input = makeColor(light: (0.99032116, 0.97952103, 0.95744492), dark: (0.08396877, 0.07670412, 0.06187218))
    static let text = makeColor(light: (0.08396877, 0.07670412, 0.06187218), dark: (0.99032116, 0.97952103, 0.95744492))
    static let textMuted = makeColor(light: (0.35297432, 0.34400952, 0.32570278), dark: (0.77783861, 0.76751484, 0.74641673))
    static let accent = makeColor(light: (0.00158635, 0.35241771, 0.61465416), dark: (0.50132707, 0.79177974, 1.00000000))
    static let onAccent = makeColor(light: (0.99032116, 0.97952103, 0.95744492), dark: (0.03360953, 0.02784535, 0.01796229))
    static let danger = makeColor(light: (0.57609028, 0.20010082, 0.19116942), dark: (1.00000000, 0.63345050, 0.60062254))
    static let success = makeColor(light: (0.10706824, 0.40768512, 0.24483823), dark: (0.55774775, 0.84580856, 0.65807479))
    static let border = makeColor(light: (0.46480814, 0.45540434, 0.43619585), dark: (0.46480814, 0.45540434, 0.43619585))
    static let focus = makeColor(light: (0.00158635, 0.35241771, 0.61465416), dark: (0.50132707, 0.79177974, 1.00000000))
    static let spaceInline: CGFloat = 8
    static let spaceSection: CGFloat = 16
    static let spacePanel: CGFloat = 20
    static let spaceCompact: CGFloat = 4
    static let radiusPanel: CGFloat = 20
    static let radiusCard: CGFloat = 12
    static let radiusControl: CGFloat = 8
    static let sizeBorder: CGFloat = 1
    static let sizeBody: CGFloat = 15
    static let sizeLabel: CGFloat = 13
    static let sizeCaption: CGFloat = 12
    static let sizeTitle: CGFloat = 18
    static let sizeHeading: CGFloat = 24
    static let sizePanelCompact: CGFloat = 440
    static let sizePanelWide: CGFloat = 840
    static let sizePanelHeight: CGFloat = 640
    static let sizePanelMinimum: CGFloat = 360
    static let sizeEditorHeight: CGFloat = 144
    static let sizeSettingsWidth: CGFloat = 760
    static let sizeSettingsHeight: CGFloat = 560
    static let sizeSidebar: CGFloat = 180
    static let sizeButton: CGFloat = 28
    static let sizeIcon: CGFloat = 16
    static let sizeTouch: CGFloat = 44
    static let sizeLineSpacing: CGFloat = 4
    static let sizeExplanation: CGFloat = 320
    static let sizeRefinement: CGFloat = 40
    static let sizeBreakpoint: CGFloat = 600
    static let opacityDisabled: CGFloat = 0.5
    static let opacityTint: CGFloat = 0.12
    static let durationMicro: CGFloat = 0.15
    static let durationSurface: CGFloat = 0.24
    static let durationExit: CGFloat = 0.144
    static let shadowRadius: CGFloat = 16
    static let shadowOffset: CGFloat = 4
    static let layerContent: CGFloat = 0
    static let layerOverlay: CGFloat = 1
    static let weightBody: Font.Weight = .regular
    static let weightLabel: Font.Weight = .medium
    static let weightTitle: Font.Weight = .semibold
    static let trackingBody: CGFloat = 0
    static let familyBody: Font.Design = .default
    static let ratioScreenHeight: CGFloat = 0.8
    static let variantExplanationBackground = makeColor(light: (0.94445386, 0.93374956, 0.91187016), dark: (0.08396877, 0.07670412, 0.06187218))
    static let variantExplanationText = makeColor(light: (0.08396877, 0.07670412, 0.06187218), dark: (0.99032116, 0.97952103, 0.95744492))
    static let fontBody = Font.system(size: sizeBody, weight: weightBody, design: familyBody)
    static let fontLabel = Font.system(size: sizeLabel, weight: weightBody, design: familyBody)
    static let fontCaption = Font.system(size: sizeCaption, weight: weightBody, design: familyBody)
    static let fontTitle = Font.system(size: sizeTitle, weight: weightTitle, design: familyBody)
    static let fontHeading = Font.system(size: sizeHeading, weight: weightTitle, design: familyBody)

    private static func makeColor(light: (Double, Double, Double), dark: (Double, Double, Double)) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let value = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
            return NSColor(srgbRed: value.0, green: value.1, blue: value.2, alpha: 1)
        })
    }
}
#endif
