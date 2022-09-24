import XCTest
@testable import UserInterface

final class HighlightDifferencesTests: XCTestCase {
    func testHighlightDifferences() throws {
        let initialUrl = URL(testUrl: "https://google.com/?utm_source=Share&client=Safari&utm_campaign=Share")
        let newUrl = URL(testUrl: "https://google.com/?client=Safari")

        let highlightedUrl = highlightDifferences(initialUrl: initialUrl, newUrl: newUrl)

        let expectedUrl =
            AttributedString("https://google.com/?")
            + AttributedString("utm_source=Share&", attributes: .init([.foregroundColor: UIColor.red]))
            + AttributedString("client=Safari")
            + AttributedString("&utm_campaign=Share", attributes: .init([.foregroundColor: UIColor.red]))
        XCTAssertEqual(highlightedUrl, expectedUrl)
    }
}


extension URL {
    init(testUrl: StaticString) {
        self.init(string: "\(testUrl)")!
    }
}
