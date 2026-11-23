import Foundation

public struct ActivityBucket: Identifiable, Equatable, Sendable {
    public let id: Date
    public let label: String
    public let amount: Int

    public init(id: Date, label: String, amount: Int) {
        self.id = id
        self.label = label
        self.amount = amount
    }
}

public struct ReadingStats: Equatable, Sendable {
    public let finishedCount: Int
    public let pagesRead: Int
    public let audioMinutes: Int
    public let readingStreakDays: Int
    public let activity: [ActivityBucket]
    public let recentHighlights: [Title]

    public init(finishedCount: Int, pagesRead: Int, audioMinutes: Int,
                readingStreakDays: Int, activity: [ActivityBucket], recentHighlights: [Title]) {
        self.finishedCount = finishedCount
        self.pagesRead = pagesRead
        self.audioMinutes = audioMinutes
        self.readingStreakDays = readingStreakDays
        self.activity = activity
        self.recentHighlights = recentHighlights
    }
}
