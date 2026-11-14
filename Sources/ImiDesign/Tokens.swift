// Pont vers les rôles fabriqués ; les valeurs de disposition propres au panneau vivent ici jusqu'à migration dans tokens.json (décision 2026-11-13-plateformes-apple.md).
import SwiftUI

public enum Tokens {
    public static let background = DesignColor.background
    public static let surface = DesignColor.surface
    public static let input = DesignColor.surface
    public static let text = DesignColor.text
    public static let textMuted = DesignColor.textMuted
    public static let accent = DesignColor.accent
    public static let onAccent = DesignColor.onAccent
    public static let danger = DesignColor.danger
    public static let success = DesignColor.success
    public static let border = DesignColor.rule
    public static let focus = DesignColor.focus
    public static let variantExplanationBackground = DesignColor.surface
    public static let variantExplanationText = DesignColor.text

    public static let spaceInline = DesignSpace.markInsetInline
    public static let spaceSection = DesignSpace.cardInset
    public static let spacePanel = DesignScale.space20
    public static let spaceCompact = DesignScale.space4

    public static let radiusPanel = DesignRadius.card
    public static let radiusCard = DesignRadius.block
    public static let radiusControl = DesignRadius.control
    public static let sizeBorder = DesignBorder.width

    public static var fontBody: Font { DesignTypeRole.body.font }
    public static var fontLabel: Font { DesignTypeRole.label.font }
    public static var fontCaption: Font { DesignTypeRole.caption.font }
    public static var fontTitle: Font { DesignTypeRole.section.font }
    public static var fontHeading: Font { DesignTypeRole.title.font }
    public static let weightBody = DesignType.bodyWeight
    public static let weightLabel = DesignType.labelWeight
    public static let weightTitle = DesignType.titleWeight

    public static let sizePanelCompact: CGFloat = 440
    public static let sizePanelWide: CGFloat = 840
    public static let sizePanelHeight: CGFloat = 640
    public static let sizePanelMinimum: CGFloat = 360
    public static let sizeEditorHeight: CGFloat = 144
    public static let sizeSettingsWidth: CGFloat = 760
    public static let sizeSettingsHeight: CGFloat = 560
    public static let sizeSidebar: CGFloat = 180
    public static let sizeButton: CGFloat = 28
    public static let sizeIcon = DesignIcon.size
    public static let sizeTouch = DesignTarget.min
    public static let sizeLineSpacing: CGFloat = 4
    public static let sizeExplanation: CGFloat = 320
    public static let sizeRefinement: CGFloat = 40
    public static let sizeBreakpoint: CGFloat = 600
    public static let opacityDisabled = CGFloat(DesignOpacity.disabled)
    public static let opacityTint: CGFloat = 0.12
    public static let durationMicro = CGFloat(DesignDuration.press)
    public static let durationSurface = CGFloat(DesignDuration.wide)
    public static let durationExit = CGFloat(DesignDuration.fast)
    public static let shadowRadius: CGFloat = 16
    public static let shadowOffset: CGFloat = 4
    public static let layerContent: CGFloat = 0
    public static let layerOverlay = CGFloat(DesignLayer.menu)
    public static let ratioScreenHeight: CGFloat = 0.8
}
