import Foundation
import Observation

@MainActor
@Observable
public final class LibraryViewModel {
    public private(set) var library: Library
    public private(set) var errorMessage: String?

    private let store: LibraryStore

    public init(store: LibraryStore) {
        self.store = store
        do {
            self.library = try store.load()
        } catch {
            self.library = Library()
            self.errorMessage = "Could not load library."
        }
    }

    // Section 1. Both formats mixed.
    public var currentlyReading: [EntryCardState] {
        cards(where: { $0 == .inProgress })
    }

    // Section 2. Finished and Want.
    public var shelves: [EntryCardState] {
        cards(where: { $0 != .inProgress })
    }

    public var isEmpty: Bool { library.entries.isEmpty }

    private func cards(where match: (ProgressStatus) -> Bool) -> [EntryCardState] {
        library.entries
            .filter { match($0.status) }
            .compactMap { entry in
                guard let title = library.titles.first(where: { $0.id == entry.titleID })
                else { return nil }
                return EntryCardState(title: title, entry: entry,
                                      done: library.done(for: title.id))
            }
    }

    // Action. Change data, then save.
    public func markFinished(_ id: TitleID) {
        LibraryService().finish(id, in: &library, on: Date())
        save()
    }

    private func save() {
        do { try store.save(library) }
        catch { errorMessage = "Could not save." }
    }
}
