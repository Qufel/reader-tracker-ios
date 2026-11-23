import Foundation

actor OpenLibrarySearchCache {
    static let shared = OpenLibrarySearchCache()

    private struct Entry: Codable {
        let titles: [Title]
        let cachedAt: Date
    }

    private let directory: URL

    init(directory: URL? = nil) {
        if let directory {
            self.directory = directory
        } else {
            let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.directory = cacheDirectory.appendingPathComponent("ReaderTracker/OpenLibrarySearch/v1", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    func load(query: String, now: Date = .now) -> [Title]? {
        guard let data = try? Data(contentsOf: fileURL(for: query)),
              let entry = try? JSONDecoder().decode(Entry.self, from: data)
        else { return nil }

        let lifetime: TimeInterval = entry.titles.isEmpty ? 6 * 60 * 60 : 24 * 60 * 60
        guard now.timeIntervalSince(entry.cachedAt) <= lifetime else { return nil }
        return entry.titles
    }

    func loadIncludingExpired(query: String) -> [Title]? {
        guard let data = try? Data(contentsOf: fileURL(for: query)),
              let entry = try? JSONDecoder().decode(Entry.self, from: data)
        else { return nil }

        let maximumAge: TimeInterval = 7 * 24 * 60 * 60
        guard Date.now.timeIntervalSince(entry.cachedAt) <= maximumAge else { return nil }
        return entry.titles
    }

    func save(query: String, titles: [Title], now: Date = .now) {
        let entry = Entry(titles: titles, cachedAt: now)
        guard let data = try? JSONEncoder().encode(entry) else { return }
        try? data.write(to: fileURL(for: query), options: .atomic)
        pruneIfNeeded()
    }

    private func pruneIfNeeded() {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ), files.count > 500 else { return }

        let oldestFirst = files.sorted {
            let lhsDate = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let rhsDate = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return lhsDate < rhsDate
        }

        for file in oldestFirst.prefix(files.count - 500) {
            try? FileManager.default.removeItem(at: file)
        }
    }

    private func fileURL(for query: String) -> URL {
        let normalized = query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
            .data(using: .utf8)!
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in normalized {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        let name = String(format: "%016llx", hash)
        return directory.appendingPathComponent(name).appendingPathExtension("json")
    }
}

actor OpenLibraryRequestGate {
    static let shared = OpenLibraryRequestGate()

    private var nextAllowedRequest = Date.distantPast

    func waitForTurn() async throws {
        let now = Date()
        let delay = max(0, nextAllowedRequest.timeIntervalSince(now))
        nextAllowedRequest = max(now, nextAllowedRequest).addingTimeInterval(1.0)

        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }
    }

    func pause(for seconds: TimeInterval) {
        nextAllowedRequest = Date().addingTimeInterval(max(seconds, 1))
    }
}
