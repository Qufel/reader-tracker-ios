import Foundation
import Observation

@MainActor
@Observable
public final class TitleDetailViewModel {
    public let title: Title
    private let library: LibraryViewModel

    public init(title: Title, library: LibraryViewModel) {
        self.title = title
        self.library = library
    }

    public var entry: LibraryEntry? { library.library.entry(for: title.id) }
    public var done: Int { library.library.done(for: title.id) }
    public var progress: Double {
        title.total > 0 ? min(Double(done) / Double(title.total), 1) : 0
    }

    public func addToLibrary() { library.addTitle(title, status: .want) }
    public func startReading() { library.setStatus(title.id, to: .inProgress) }
    public func markFinished() { library.markFinished(title.id) }
}
