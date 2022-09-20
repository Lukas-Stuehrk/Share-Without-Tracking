import XCTest
import Vision


class EndToEndTests: XCTestCase {

    /// Tests the full flow. It opens the app to make sure that the sharing extension is installed. Then it opens
    /// Safari, navigates to a URL with tracking parameters, and shares this URL. In the system dialog, the `Share
    /// Without Tracking` extension is selected which will open the UI of the extension. The test validates that the
    /// displayed URL is the same as the shared URL, then it checks if the second sharing overlay is shown. In this
    /// overlay, the built in `Reminders` app is chosen and the test validates that the URL with removed tracking
    /// parameters is handed over to the Reminders app.
    func testSharing() throws {
        let app = XCUIApplication(bundleIdentifier: "net.stuehrk.lukas.Share-Without-Tracking")
        app.launch()

        let safari = Safari()
        safari.app.launch()
        safari.open(url: URL(string: "https://www.google.de/?utm_source=share&client=Safari")!)
        safari.shareButton.tap()

        let shareWithoutTrackingSharingOptions: SharingOverlay.SharingOption = try XCTUnwrap(
            safari.sharingOverlay.sharingOptions.first(where: { $0.text == "Share Without Tracking" }),
            "It should have the sharing option."
        )
        shareWithoutTrackingSharingOptions.element.tap()
        let sharingExtension = ShareWithoutTrackingSharingExtension()
        XCTAssertTrue(sharingExtension.app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertEqual(sharingExtension.urlLabel.label, "Getting shared URL")
        let waitForUrlExpectation = expectation {
            sharingExtension.urlLabel.label != "Getting shared URL"
        }
        wait(for: [waitForUrlExpectation], timeout: 2)

        XCTAssertEqual(sharingExtension.urlLabel.label, "https://www.google.de/?utm_source=share&client=Safari")

        let shareWithReminderOption = try XCTUnwrap(
            sharingExtension.sharingOverlay.sharingOptions.first(where: {
                // TODO: Proper localization and concepts for localization.
                ["Erinnerungen", "Reminders"].contains($0.text)
            }),
            "It should have the sharing option for the Reminder app"
        )
        shareWithReminderOption.element.tap()

        let remindersExtension = RemindersExtension()
        XCTAssertTrue(remindersExtension.app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertEqual(remindersExtension.noteField.value as? String, "https://www.google.de/?client=Safari")
    }
}

