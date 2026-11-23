import Foundation

public struct OpenLibrarySearchProvider: TitleSearchProvider {
    public enum ProviderError: LocalizedError, Equatable {
        case invalidResponse
        case requestFailed

        public var errorDescription: String? {
            switch self {
            case .invalidResponse: "Open Library returned an unexpected response."
            case .requestFailed: "Could not reach Open Library."
            }
        }
    }

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func search(query: String) async throws -> [Title] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return [] }

        var components = URLComponents(string: "https://openlibrary.org/search.json")
        components?.queryItems = [
            URLQueryItem(name: "q", value: normalized),
            URLQueryItem(name: "fields", value: "key,title,author_name,first_publish_year,number_of_pages_median,cover_i,subject,ratings_average,first_sentence"),
            URLQueryItem(name: "limit", value: "30")
        ]

        guard let url = components?.url else { throw ProviderError.requestFailed }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("ReaderTracker/1.0 (open library integration)", forHTTPHeaderField: "User-Agent")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            if error is CancellationError { throw error }
            throw ProviderError.requestFailed
        }

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else { throw ProviderError.invalidResponse }

        let decoded = try JSONDecoder().decode(OpenLibraryResponse.self, from: data)
        var seen = Set<TitleID>()

        return decoded.docs.compactMap { document -> Title? in
            guard let key = document.key,
                  key.hasPrefix("/works/")
            else { return nil }

            let value = String(key.dropFirst("/works/".count))
            let id = TitleID(source: .openLibrary, value: value)
            guard seen.insert(id).inserted else { return nil }

            let name = document.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let name, !name.isEmpty else { return nil }

            let author = document.authorNames?.first?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let cover: Cover
            if let coverID = document.coverID {
                cover = .url(URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-L.jpg")!)
            } else {
                cover = .color(hex: "#0F6B5B")
            }

            let summary = document.firstSentence?.first

            return Title(
                id: id,
                name: name,
                author: author?.isEmpty == false ? author! : "Unknown author",
                year: document.firstPublishYear,
                format: .print,
                total: document.pageCount ?? 0,
                summary: summary,
                rating: document.rating,
                cover: cover
            )
        }
    }
}

private struct OpenLibraryResponse: Decodable {
    let docs: [OpenLibraryDocument]
}

private struct OpenLibraryDocument: Decodable {
    let key: String?
    let title: String?
    let authorNames: [String]?
    let firstPublishYear: Int?
    let pageCount: Int?
    let coverID: Int?
    let rating: Double?
    let firstSentence: [String]?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorNames = "author_name"
        case firstPublishYear = "first_publish_year"
        case pageCount = "number_of_pages_median"
        case coverID = "cover_i"
        case rating = "ratings_average"
        case firstSentence = "first_sentence"
    }
}
