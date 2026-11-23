import Foundation

public struct AppMetadata: Equatable, Sendable {
    public let version: String
    public let build: String

    public init(version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                build: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1") {
        self.version = version
        self.build = build
    }
}
