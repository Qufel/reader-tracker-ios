import Foundation

actor OpenLibrarySearchCoordinator {
    static let shared = OpenLibrarySearchCoordinator()

    private var activeSearches: [String: Task<[Title], Error>] = [:]

    func search(
        query: String,
        operation: @escaping @Sendable (String) async throws -> [Title]
    ) async throws -> [Title] {
        let key = normalizedKey(query)

        if let task = activeSearches[key] {
            return try await task.value
        }

        let task = Task {
            try await operation(query)
        }
        activeSearches[key] = task

        defer { activeSearches[key] = nil }
        return try await task.value
    }

    private func normalizedKey(_ query: String) -> String {
        query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
    }
}
