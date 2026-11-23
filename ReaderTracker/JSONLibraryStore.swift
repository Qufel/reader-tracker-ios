//
//  JSONLibraryStore.swift
//  ReaderTracker
//
//  Created by stud on 17/11/2026.
//


// JSONLibraryStore.swift. Real one. App use.
import Foundation

public struct JSONLibraryStore: LibraryStore {
    private let url: URL

    public init(url: URL) { self.url = url }

    public func load() throws -> Library {
        // No file yet = first launch. Give empty library. Not error.
        guard FileManager.default.fileExists(atPath: url.path) else {
            return Library()
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Library.self, from: data)
    }

    public func save(_ library: Library) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(library)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)  // no half-written file
    }
}