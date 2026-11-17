// ReaderCore/Persistence/LibraryStore.swift
import Foundation

public protocol LibraryStore {
    func load() throws -> Library
    func save(_ library: Library) throws
}
