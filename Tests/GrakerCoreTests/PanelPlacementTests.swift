import XCTest
@testable import GrakerCore

final class PanelPlacementTests: XCTestCase {
    func testPlacesBelowSelectionWhenThereIsRoom() {
        let result = PanelPlacement.position(selection: CGRect(x: 100, y: 700, width: 200, height: 20),
                                              screen: CGRect(x: 0, y: 0, width: 1440, height: 900),
                                              size: CGSize(width: 440, height: 500), margin: 8)
        XCTAssertEqual(result, CGPoint(x: 100, y: 192))
    }

    func testPlacesAboveAndClampsToSecondScreen() {
        let result = PanelPlacement.position(selection: CGRect(x: -100, y: 40, width: 80, height: 20),
                                              screen: CGRect(x: -1280, y: 0, width: 1280, height: 900),
                                              size: CGSize(width: 440, height: 500), margin: 8)
        XCTAssertEqual(result, CGPoint(x: -448, y: 68))
    }

    func testConvertsAccessibilityCoordinatesUsingPrimaryDisplayTop() {
        let result = PanelPlacement.convertAccessibilityRect(CGRect(x: -500, y: -100, width: 80, height: 20), desktopTop: 900)
        XCTAssertEqual(result, CGRect(x: -500, y: 980, width: 80, height: 20))
    }
}
