import XCTest


protocol App {
    static var bundleIdentifier: String { get }
}

extension App {
    var app: XCUIApplication { XCUIApplication(bundleIdentifier: Self.bundleIdentifier) }
}


struct Safari: App {
    static let bundleIdentifier: String = "com.apple.mobilesafari"

    var shareButton: XCUIElement {
        app.buttons["ShareButton"]
    }

    func open(url: URL) {
        app.launch()
        app.textFields["TabBarItemTitle"].tap()
        app.textFields["URL"].typeText("\(url.absoluteString)\n")
    }
}
