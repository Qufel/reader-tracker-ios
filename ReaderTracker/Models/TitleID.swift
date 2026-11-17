import Foundation

public struct TitleID: Hashable, Codable, Sendable {
    public let source: Source
    public let value: String   // "OL45804W" | "1342" | UUID string

    public init(source: Source, value: String) {
        self.source = source
        self.value = value
    }

    public static func custom() -> TitleID {
        TitleID(source: .custom, value: UUID().uuidString)
    }
}
