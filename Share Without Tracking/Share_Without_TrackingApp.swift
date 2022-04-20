import SwiftUI
import Rules

@main
struct Share_Without_TrackingApp: App {

    init() {
        guard let url = [ParameterRemovalRule].storageUrl else { return }
        if !FileManager.default.fileExists(atPath: url.path) {
            let defaultRuleSet: [ParameterRemovalRule] = [
                .init(host: "twitter.com", parametersToBeRemoved: ["s", "t"]),
                .init(host: "mobile.twitter.com", parametersToBeRemoved: ["s", "t"]),
                .init(host: "www.instagram.com", parametersToBeRemoved: ["igshid"]),
                .init(host: "medium.com", parametersToBeRemoved: ["source"])
            ]
            defaultRuleSet.write()
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
