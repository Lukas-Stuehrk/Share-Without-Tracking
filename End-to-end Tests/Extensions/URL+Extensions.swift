import Foundation


extension URL {
    /// Foundation's `URL(string:)` initializer is failable for good reasons. But for the URLs which are defined in our
    /// tests, we assume that the hardcoded test URLs will not fail.
    ///
    /// - Parameter staticString: The URL. Must be a valid URL.
    init(staticString: StaticString) {
        self.init(string: staticString.description)! // swiftlint:disable:this force_unwrapping
    }
}
