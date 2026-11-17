import Foundation

// Session.swift
public struct Session: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let titleID: TitleID
    public var date: Date
    public var amount: Int          // pages, or seconds of content
    public var isCompletion: Bool   // auto-made on Finish

    public init(id: UUID = UUID(), titleID: TitleID, date: Date,
                amount: Int, isCompletion: Bool = false) {
        self.id = id; self.titleID = titleID; self.date = date
        self.amount = amount; self.isCompletion = isCompletion
    }
}
