import XCTest
import Rules

final class ParameterRemovalRuleTests: XCTestCase {
    func testRuleIsCodable() throws {
        let rule = ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["a", "b"])

        let data = try JSONEncoder().encode(rule)
        let recreatedRule = try JSONDecoder().decode(ParameterRemovalRule.self, from: data)

        XCTAssertEqual(rule.matchingHost, recreatedRule.matchingHost)
        XCTAssertEqual(rule.parametersToBeRemoved, rule.parametersToBeRemoved)
    }

    func testRuleIsEqualIfHostAndParametersAreEqual() {
        let rule = ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["a", "b"])

        XCTAssertEqual(ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["b", "a"]), rule)
        XCTAssertNotEqual(ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["b"]), rule)
        XCTAssertNotEqual(ParameterRemovalRule(host: "example.com", parametersToBeRemoved: ["b", "a"]), rule)
    }

    func testItShouldMatchCorrectDomains() {
        let rule = ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["a", "b"])
        let matchingUrl = URL(testUrl: "https://lukas.stuehrk.net/somePath?someQuery=Value")
        let notMatchingUrl = URL(testUrl: "https://stuehrk.net/somePath?someQuery=Value")

        XCTAssertTrue(rule.matches(url: matchingUrl))
        XCTAssertFalse(rule.matches(url: notMatchingUrl))
    }

    func testItShouldRemoveTheParameters() {
        let rule = ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["a", "b"])

        let url = URL(testUrl: "https://lukas.stuehrk.net/somePath?a=a&b=b&c=c")
        let cleanedUpUrl = rule.apply(on: url)

        XCTAssertEqual(URL(testUrl: "https://lukas.stuehrk.net/somePath?c=c"), cleanedUpUrl)
    }

    func testItShouldRemoveTheQueryIfNotNeeded() {
        let rule = ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["a", "b"])

        let url = URL(testUrl: "https://lukas.stuehrk.net/somePath?a=a&b=b")
        let cleanedUpUrl = rule.apply(on: url)

        XCTAssertEqual(URL(testUrl: "https://lukas.stuehrk.net/somePath"), cleanedUpUrl)
    }

    func testItShouldNotRemoveParametersIfRuleIsNotApplicable() {
        let rule = ParameterRemovalRule(host: "lukas.stuehrk.net", parametersToBeRemoved: ["a", "b"])

        let url = URL(testUrl: "https://example.com/somePath?a=a&b=b")
        let cleanedUpUrl = rule.apply(on: url)

        XCTAssertEqual(url, cleanedUpUrl)
    }

    func testItShouldSupportWildcardHosts() {
        let rule = ParameterRemovalRule(host: "*.stuehrk.net", parametersToBeRemoved: [])

        let matchingUrl = URL(testUrl: "https://lukas.stuehrk.net")
        let notMatchingUrl = URL(testUrl: "https://example.com")

        XCTAssertTrue(rule.matches(url: matchingUrl))
        XCTAssertFalse(rule.matches(url: notMatchingUrl))
    }

    func testItShouldSupportGlobalWildcardHost() {
        let rule = ParameterRemovalRule(host: "*", parametersToBeRemoved: [])

        XCTAssertTrue(rule.matches(url: URL(testUrl: "https://example.com")))
        XCTAssertTrue(rule.matches(url: URL(testUrl: "https://lukas.stuerk.net")))
    }
}


extension URL {
    init(testUrl: StaticString) {
        self.init(string: "\(testUrl)")!
    }
}
