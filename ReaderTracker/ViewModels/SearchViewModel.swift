import Foundation
import Observation

@MainActor
@Observable
public final class SearchViewModel {
    public var query: String = ""
    public private(set) var results: [Title] = []
    public private(set) var isSearching = false

    private let provider: any TitleSearchProvider

    public init(provider: any TitleSearchProvider) {
        self.provider = provider
        results = []
    }

    public func search() async {
        let searchQuery = query
        isSearching = true
        defer { isSearching = false }
        do {
            results = try await provider.search(query: searchQuery)
        } catch {
            results = []
        }
    }

    public static func local(library: LibraryViewModel) -> SearchViewModel {
        SearchViewModel(provider: LocalTitleSearchProvider { library.library.titles })
    }
}
