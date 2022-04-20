import Foundation


public extension URL {
    func apply(ruleSet: [ParameterRemovalRule]) -> URL {
        ruleSet.reduce(self, { previousUrl, rule in
            rule.apply(on: previousUrl)
        })
    }
}
