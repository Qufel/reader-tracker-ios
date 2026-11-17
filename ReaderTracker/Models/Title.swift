import Foundation

public struct Title: Identifiable, Codable, Equatable, Sendable {
    public let id: TitleID
    public var name: String
    public var author: String
    public var year: Int?
    public var format: Format
    public var total: Int            // pages, or seconds if audio
    public var summary: String?
    public var rating: Double?       // 0...5
    public var cover: Cover
    public var isCustom: Bool { id.source == .custom }  // derived. Not stored.

    public init(id: TitleID, name: String, author: String, year: Int? = nil,
                format: Format, total: Int, summary: String? = nil,
                rating: Double? = nil, cover: Cover) {
        self.id = id; self.name = name; self.author = author
        self.year = year; self.format = format; self.total = total
        self.summary = summary; self.rating = rating; self.cover = cover
    }
}
