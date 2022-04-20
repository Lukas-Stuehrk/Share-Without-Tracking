import SwiftUI
import Rules


extension ParameterRemovalRule: Identifiable {
    public var id: Self {
        self
    }

    static var empty: ParameterRemovalRule {
        .init(host: "", parametersToBeRemoved: [])
    }
}
