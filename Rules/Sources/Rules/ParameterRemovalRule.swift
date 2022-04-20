import Foundation


public struct ParameterRemovalRule: Codable, Equatable, Hashable {
    public let matchingHost: String
    public let parametersToBeRemoved: Set<String>

    public init(host: String, parametersToBeRemoved: Set<String>) {
        self.matchingHost = host
        self.parametersToBeRemoved = parametersToBeRemoved
    }

    public func matches(url: URL) -> Bool {
        url.host == matchingHost
    }

    public func apply(on originalUrl: URL) -> URL {
        guard matches(url: originalUrl) else { return originalUrl }
        guard var components = URLComponents(string: originalUrl.absoluteString) else {
            assertionFailure()
            return originalUrl
        }

        guard var queryItems = components.queryItems else { return originalUrl }
        queryItems.removeAll(where: { parametersToBeRemoved.contains($0.name) })
        if queryItems.isEmpty {
            components.queryItems = nil
        } else {
            components.queryItems = queryItems
        }

        guard let newUrl = components.url else {
            assertionFailure()
            return originalUrl
        }
        return newUrl
    }
}
