import XCTest


struct ShareWithoutTrackingSharingExtension: App {
    static let bundleIdentifier: String = "net.stuehrk.lukas.Share-Without-Tracking.SharingExtension"

    var urlLabel: XCUIElement {
        app.staticTexts.matching(identifier: "URL").firstMatch
    }
}
