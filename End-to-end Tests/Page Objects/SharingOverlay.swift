import XCTest
import Vision


extension XCUIApplication {
    var sharingDialogue: XCUIElement {
        windows.containing(.other, identifier: "PopoverDismissRegion").firstMatch
    }
}


extension App {
    var sharingOverlay: SharingOverlay {
        SharingOverlay(app: app)
    }
}


struct SharingOverlay {
    let app: XCUIApplication

    var sharingOptions: [SharingOption] {
        app.sharingDialogue.cells.allElementsBoundByIndex.map { cell in
            SharingOption(
                element: cell,
                /// It's not possible to read the labels of apps in the sharing dialog for most apps, including the
                /// Share Without Tracking app. The value of the label is always
                /// `XCElementSnapshotPrivilegedValuePlaceholder`. That's why we do this workaround to do a screenshot
                /// and then extract the text from the screenshot.
                text: extractText(in: cell)
            )
        }
    }

    struct SharingOption {
        let element: XCUIElement
        let text: String
    }
}


private func extractText(in cell: XCUIElement) -> String {
    guard let image = cell.screenshot().image.cgImage else { return "" }
    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    var isFinished = false
    let request = VNRecognizeTextRequest { _, _ in
        isFinished = true
    }
    // The texts of the sharing cells are only at the bottom of the cell.
    request.regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 0.4)
    try? handler.perform([request])

    var count = 0
    while !isFinished || count > 10 {
        RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
        count += 1
    }

    let text = (request.results ?? []).compactMap {
        $0.topCandidates(1).first?.string
    }.joined(separator: " ")

    return text
}
