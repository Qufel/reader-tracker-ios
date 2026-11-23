import Foundation
import Observation

@MainActor
@Observable
public final class SettingsViewModel {
    public let metadata: AppMetadata
    private let library: LibraryViewModel

    public init(library: LibraryViewModel, metadata: AppMetadata = AppMetadata()) {
        self.library = library
        self.metadata = metadata
    }

    public var appearance: Appearance {
        get { library.library.appearance }
        set { library.setAppearance(newValue) }
    }

    public var customEntries: [EntryCardState] { library.customEntries }
    public var titleCount: Int { library.library.titles.count }
    public var sessionCount: Int { library.library.sessions.count }

    public func deleteCustomEntry(_ id: TitleID) {
        library.deleteCustomEntry(id)
    }

    public func resetLibrary() {
        library.resetLibrary()
    }

    public func exportData() throws -> Data {
        try library.exportData()
    }
}
