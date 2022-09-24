import UIKit


/// Highlights the difference between a URL and its cleanup up version where query parameters are removed.
///
/// - Parameters:
///   - initialUrl: The full URL with all query parameters.
///   - newUrl: The cleaned-up version of the URL where some or all query parameters are removed.
/// - Returns: An attributed string where the string contents are the initial URL. All characters which are removed
///     in the query string of `newUrl` are highlighted with red text color.
public func highlightDifferences(initialUrl: URL, newUrl: URL) -> AttributedString {
    let urlString = initialUrl.absoluteString
    var attributedString = AttributedString(urlString)

    // First run: Highlight the removed ampersands and question marks
    for change in newUrl.absoluteString.difference(from: urlString).removals {
        guard case let .remove(offset, character, _) = change else {
            assertionFailure()
            break
        }
        guard ["&", "?"].contains(character) else { continue }
        let index = attributedString.index(attributedString.startIndex, offsetByCharacters: offset)
        attributedString[index..<attributedString.index(afterCharacter: index)].setAttributes(.init([
            .foregroundColor: UIColor.red
        ]))
    }

    // Second run: Highlight the removed parameters
    let initialParameters = (URLComponents(string: initialUrl.absoluteString)?.queryItems ?? []).map {
        $0.description
    }
    let newParameters = (URLComponents(string: newUrl.absoluteString)?.queryItems ?? []).map {
        $0.description
    }
    let difference = newParameters.difference(from: initialParameters).inferringMoves()
    for change in difference.removals {
        guard case let .remove(_, parameter, _) = change else {
            assertionFailure()
            break
        }
        // Replace every occurrence of the query parameter. Somehow this uses an implementation detail of the URL
        // cleanup: At the moment, its not possible to remove a query parameter only one time. If this behavior will
        // change in the rules implementation and therefore it will be possible to remove a query parameter which
        // occurs multiple times only once, then this highlighting will have the wrong highlighting.
        var searchStartIndex = urlString.startIndex
        while
            searchStartIndex < urlString.endIndex,
            let range = urlString.range(of: parameter.description, range: searchStartIndex..<urlString.endIndex),
            !range.isEmpty
        {
            searchStartIndex = range.upperBound
            guard
                let startIndex = AttributedString.Index(range.lowerBound, within: attributedString),
                let endIndex = AttributedString.Index(range.upperBound, within: attributedString)
            else {
                assertionFailure()
                continue
            }
            attributedString[startIndex..<endIndex].setAttributes(.init([
                .foregroundColor: UIColor.red
            ]))
        }
    }

    return attributedString
}
