import XCTest


/// The extension of iOS' built in Reminders app which is displayed when a user taps on share in Reminders in a sharing
/// overlay.
struct RemindersExtension: App {
    static let bundleIdentifier: String = "com.apple.reminders.sharingextension"

    var noteField: XCUIElement {
        app.textFields.matching(identifier: "Sharing Extension Note Field").firstMatch
    }
}
