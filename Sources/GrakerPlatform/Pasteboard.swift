import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum Pasteboard {
    static func readString() -> String? {
#if os(macOS)
        NSPasteboard.general.string(forType: .string)
#else
        UIPasteboard.general.string
#endif
    }

    @discardableResult
    static func writeString(_ text: String) -> Bool {
#if os(macOS)
        NSPasteboard.general.clearContents()
        return NSPasteboard.general.setString(text, forType: .string)
#else
        UIPasteboard.general.string = text
        return true
#endif
    }
}
