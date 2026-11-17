import Foundation

// LibraryEntry.swift
public struct LibraryEntry: Codable, Equatable, Sendable {
    public let titleID: TitleID
    public private(set) var status: ProgressStatus
    public private(set) var startedAt: Date?
    public private(set) var finishedAt: Date?
    public var notes: String

    public init(titleID: TitleID, status: ProgressStatus = .want,
                startedAt: Date? = nil, finishedAt: Date? = nil,
                notes: String = "") {
        self.titleID = titleID; self.status = status
        self.startedAt = startedAt; self.finishedAt = finishedAt
        self.notes = notes
    }

    // Status change live here. One place. Test on Linux.
    public mutating func start(on date: Date) {
        status = .inProgress
        if startedAt == nil { startedAt = date }
        finishedAt = nil
    }

    public mutating func finish(on date: Date) {
        status = .finished
        if startedAt == nil { startedAt = date }
        finishedAt = date
    }

    public mutating func moveToWant() {
        status = .want
        finishedAt = nil
        // startedAt, notes, sessions stay. Rule from Q4.
    }
}
