import Foundation


public extension Array where Element == ParameterRemovalRule {

    static var storageUrl: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.net.stuehrk.lukas.sharewithouttracking")?.appendingPathComponent("rules.json")
    }

    static func fromFile(url: URL) throws -> Self {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Self.self, from: data)
    }

    func write(to url: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
    }

    static func read() -> Self {
        guard let url = Self.storageUrl else {
            assertionFailure()
            return []
        }
        return (try? .fromFile(url: url)) ?? []
    }

    func write() {
        guard let url = Self.storageUrl else {
            assertionFailure()
            return
        }
        try? write(to: url)
    }
}
