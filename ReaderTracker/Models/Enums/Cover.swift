import Foundation

public enum Cover: Codable, Equatable, Hashable, Sendable {
    case url(URL)
    case asset(String)
    case color(hex: String)
}
