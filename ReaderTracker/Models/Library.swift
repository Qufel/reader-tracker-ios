// Library.swift
public struct Library: Codable, Equatable, Sendable {
    public var titles: [Title]        // snapshot of every title user touched
    public var entries: [LibraryEntry]
    public var sessions: [Session]
    public var appearance: Appearance
    public var recentTitles: [Title]

    public init(titles: [Title] = [], entries: [LibraryEntry] = [],
                sessions: [Session] = [], appearance: Appearance = .system,
                recentTitles: [Title] = []) {
        self.titles = titles; self.entries = entries
        self.sessions = sessions; self.appearance = appearance
        self.recentTitles = recentTitles
    }

    private enum CodingKeys: String, CodingKey {
        case titles, entries, sessions, appearance, recentTitles
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titles = try container.decode([Title].self, forKey: .titles)
        entries = try container.decode([LibraryEntry].self, forKey: .entries)
        sessions = try container.decode([Session].self, forKey: .sessions)
        appearance = try container.decodeIfPresent(Appearance.self, forKey: .appearance) ?? .system
        recentTitles = try container.decodeIfPresent([Title].self, forKey: .recentTitles) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(titles, forKey: .titles)
        try container.encode(entries, forKey: .entries)
        try container.encode(sessions, forKey: .sessions)
        try container.encode(appearance, forKey: .appearance)
        try container.encode(recentTitles, forKey: .recentTitles)
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
