import Foundation

public protocol TitleSearchProvider {
    func search(query: String) async throws -> [Title]
}

public struct LocalTitleSearchProvider: TitleSearchProvider {
    private let titles: () -> [Title]

    public init(titles: @escaping () -> [Title]) {
        self.titles = titles
    }

    public func search(query: String) async throws -> [Title] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return titles().filter { title in
            normalized.isEmpty
            || title.name.localizedCaseInsensitiveContains(normalized)
            || title.author.localizedCaseInsensitiveContains(normalized)
        }
    }
}
