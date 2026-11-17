//
//  InMemoryStore.swift
//  ReaderTracker
//
//  Created by stud on 17/11/2026.
//


// InMemoryStore.swift. Fake. Tests and Previews use.
public final class InMemoryStore: LibraryStore {
    public var library: Library
    public init(library: Library = Library()) { self.library = library }
    public func load() throws -> Library { library }
    public func save(_ library: Library) throws { self.library = library }
}