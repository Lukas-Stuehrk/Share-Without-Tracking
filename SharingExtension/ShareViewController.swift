import UIKit
import Rules

class ShareViewController: UIViewController {

    @IBOutlet private var activityIndicator: UIActivityIndicatorView?

    @IBOutlet private var label: UILabel?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        getSharedUrls { [weak self] urls in
            self?.activityIndicator?.stopAnimating()

            // When an URL is shared, there are multiple versions of the URL in the shared attachments. One version of
            // the URL is without any query parameters, even the ones which are not required. To get the actual URL
            // which was shared, we simply take the longest URL.
            guard let relevantUrl = urls.longestUrl else { return }
            let newUrl = relevantUrl.trackingParametersRemoved()
            self?.label?.attributedText = highlightDifferences(initialUrl: relevantUrl, newUrl: newUrl)

            let share = UIActivityViewController(activityItems: [newUrl as NSURL], applicationActivities: nil)
            share.completionWithItemsHandler = { _, _, _, _ in
                self?.extensionContext?.completeRequest(returningItems: [])
            }
            self?.present(share, animated: false)

        }
    }

    func getSharedUrls(callback: @escaping ([URL]) -> Void) {

        var allSharedUrls: [URL] = []

        let group = DispatchGroup()
        for item in extensionContext?.inputItems as? [NSExtensionItem] ?? [] {
            for attachment in item.attachments ?? [] {
                guard attachment.hasItemConformingToTypeIdentifier("public.url") else { continue }
                group.enter()
                attachment.loadItem(forTypeIdentifier: "public.url") { maybeItem, maybeError  in
                    defer { group.leave() }
                    guard let url = maybeItem as? NSURL as? URL else { return }
                    allSharedUrls.append(url)
                }
            }
        }

        group.notify(queue: .main) {
            callback(allSharedUrls)
        }
        _ = group.wait(timeout: .now() + 5)
    }

}


func highlightDifferences(initialUrl: URL, newUrl: URL) -> NSAttributedString {
    let string = NSMutableAttributedString(string: initialUrl.absoluteString)
    let difference = newUrl.absoluteString.difference(from: initialUrl.absoluteString)
    for change in difference.removals {
        guard case let .remove(offset, _, _) = change else {
            assertionFailure()
            break
        }
        string.setAttributes([.foregroundColor: UIColor.red], range: NSRange(location: offset, length: 1))
    }

    return string
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
