import XCTest
import Rules


class RuleSetTests: XCTestCase {
    func testItShouldApplyARuleSet() {
        let ruleSet = [
            ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["a"]),
            ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["b"]),
        ]

        let url = URL(testUrl: "https://lukas.stuehrk.net/?a=a&b=b&c=c")
        let cleanedUpUrl = url.apply(ruleSet: ruleSet)

        XCTAssertEqual(URL(testUrl: "https://lukas.stuehrk.net/?c=c"), cleanedUpUrl)
    }
}
