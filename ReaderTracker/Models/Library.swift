// Library.swift
public struct Library: Codable, Equatable, Sendable {
    public var titles: [Title]        // snapshot of every title user touched
    public var entries: [LibraryEntry]
    public var sessions: [Session]
    public var appearance: Appearance

    public init(titles: [Title] = [], entries: [LibraryEntry] = [],
                sessions: [Session] = [], appearance: Appearance = .system) {
        self.titles = titles; self.entries = entries
        self.sessions = sessions; self.appearance = appearance
    }

    public func entry(for id: TitleID) -> LibraryEntry? {
        entries.first { $0.titleID == id }
    }

    public func sessions(for id: TitleID) -> [Session] {
        sessions.filter { $0.titleID == id }.sorted { $0.date > $1.date }
    }

    public func done(for id: TitleID) -> Int {
        sessions.lazy.filter { $0.titleID == id }.map(\.amount).reduce(0, +)
    }
}
