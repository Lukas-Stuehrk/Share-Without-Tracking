import UIKit
import Rules
import UserInterface

class ShareViewController: UIViewController {

    @IBOutlet private var activityIndicator: UIActivityIndicatorView?

    @IBOutlet private var label: UILabel?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        getSharedUrls { [weak self] urls in
            self?.displaySharedUrl(urls: urls)
        }
    }

    func displaySharedUrl(urls: [URL]) {
        activityIndicator?.stopAnimating()
        // When an URL is shared, there are multiple versions of the URL in the shared attachments. One version of
        // the URL is without any query parameters, even the ones which are not required. To get the actual URL
        // which was shared, we simply take the longest URL.
        guard let relevantUrl = urls.longestUrl else { return }
        let newUrl = relevantUrl.trackingParametersRemoved()
        label?.attributedText = NSAttributedString(
            highlightDifferences(
                initialUrl: relevantUrl,
                newUrl: newUrl
            )
        )

        let share = UIActivityViewController(activityItems: [newUrl as NSURL], applicationActivities: nil)
        share.completionWithItemsHandler = { _, _, _, _ in
            self.extensionContext?.completeRequest(returningItems: [])
        }
        present(share, animated: false)
    }

    func getSharedUrls(callback: @escaping ([URL]) -> Void) {

        var allSharedUrls: [URL] = []

        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let group = DispatchGroup()
        for item in extensionContext?.inputItems as? [NSExtensionItem] ?? [] {
            for attachment in item.attachments ?? [] {
                if attachment.hasItemConformingToTypeIdentifier("public.url") {
                    group.enter()
                    attachment.loadObject(ofClass: NSURL.self) { maybeItem, maybeError  in
                        defer { group.leave() }
                        guard let url = maybeItem as? NSURL as? URL else { return }
                        allSharedUrls.append(url)
                    }
                } else if attachment.hasItemConformingToTypeIdentifier("public.text"), let detector = detector {
                    group.enter()
                    // TODO: Find out why `attachment.loadObject(NSString.self)` doesn't work.
                    // loadItem is significantly slower.
                    attachment.loadItem(forTypeIdentifier: "public.plain-text") { maybeItem, maybeError in
                        defer { group.leave() }
                        guard let nsString = maybeItem as? NSString else { return }
                        let string = nsString as String
                        for result in detector.matches(in: string, range: NSRange(location: 0, length: nsString.length)) {
                            if let url = result.url {
                                allSharedUrls.append(url)
                            }
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            callback(allSharedUrls)
        }
        _ = group.wait(timeout: .now() + 5)
    }

}

private let ruleSet: [ParameterRemovalRule] = .read()


extension URL {
    func trackingParametersRemoved() -> URL {
        apply(ruleSet: ruleSet)
    }
}


extension Array where Element == URL {
    var longestUrl: URL? {
        self.map { $0.standardized }
            .sorted { $0.absoluteString.count > $1.absoluteString.count }
            .first
    }
}
