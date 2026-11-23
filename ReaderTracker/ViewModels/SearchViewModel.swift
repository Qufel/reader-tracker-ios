import Foundation
import Observation

@MainActor
@Observable
public final class SearchViewModel {
    public var query: String = ""
    public private(set) var results: [Title] = []
    public private(set) var isSearching = false
    public private(set) var errorMessage: String?

    private let provider: any TitleSearchProvider

    public init(provider: any TitleSearchProvider) {
        self.provider = provider
        results = []
    }

    public func search() async {
        let searchQuery = query
        isSearching = true
        defer { isSearching = false }
        errorMessage = nil
        do {
            let found = try await provider.search(query: searchQuery)
            guard query == searchQuery else { return }
            results = found
        } catch {
            guard query == searchQuery else { return }
            results = []
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Could not complete the search."
        }
    }

    public static func local(library: LibraryViewModel) -> SearchViewModel {
        SearchViewModel(provider: LocalTitleSearchProvider { library.library.titles })
    }

    public static func remote() -> SearchViewModel {
        SearchViewModel(provider: OpenLibrarySearchProvider())
    }
}
