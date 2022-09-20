import XCTest


extension XCTestCase {
    func expectation(closure: @escaping () -> Bool) ->  XCTestExpectation {
        let predicate = NSPredicate(block: { _, _ in
            return closure()
        })

        return expectation(for: predicate, evaluatedWith: nil, handler: .none)
    }
}
