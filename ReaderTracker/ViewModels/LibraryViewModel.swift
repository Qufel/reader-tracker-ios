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

    public func dismissError() {
        errorMessage = nil
    }

    // Section 1. Both formats mixed.
    public var currentlyReading: [EntryCardState] {
        cards(where: { $0 == .inProgress })
    }

    // Section 2. Finished and Want.
    public var shelves: [EntryCardState] {
        cards(where: { $0 != .inProgress })
    }

    public var isEmpty: Bool {
        currentlyReading.isEmpty && shelves.isEmpty
    }

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

    public func addTitle(_ title: Title, status: ProgressStatus = .want) {
        if !library.titles.contains(where: { $0.id == title.id }) {
            library.titles.append(title)
        }
        if !library.entries.contains(where: { $0.titleID == title.id }) {
            library.entries.append(LibraryEntry(titleID: title.id, status: status,
                                               startedAt: status == .want ? nil : Date()))
        }
        save()
    }

    public func addCustom(title: Title, status: ProgressStatus = .want) {
        guard !library.titles.contains(where: { $0.id == title.id }) else { return }
        library.titles.append(title)
        var entry = LibraryEntry(titleID: title.id, status: status,
                                 startedAt: status == .want ? nil : Date())
        if status == .finished {
            entry.finish(on: Date())
        }
        library.entries.append(entry)
        if status == .finished, title.total > 0 {
            library.sessions.append(Session(titleID: title.id, date: Date(),
                                            amount: title.total, isCompletion: true))
        }
        save()
    }

    public func logSession(_ title: Title, amount: Int, date: Date = .now) {
        guard amount > 0 else { return }
        let id = title.id
        let remaining = remainingAmount(for: title)
        guard remaining > 0 else { return }
        let loggedAmount = min(amount, remaining)

        if !library.titles.contains(where: { $0.id == id }) {
            library.titles.append(title)
        }
        if !library.entries.contains(where: { $0.titleID == id }) {
            library.entries.append(LibraryEntry(titleID: id, status: .want))
        }
        guard let index = library.entries.firstIndex(where: { $0.titleID == id }) else { return }

        library.sessions.append(Session(titleID: id, date: date, amount: loggedAmount))
        if title.total > 0, library.done(for: id) >= title.total {
            LibraryService().finish(id, in: &library, on: date)
        } else if library.entries[index].status == .want {
            library.entries[index].start(on: date)
        }
        save()
    }

    public func remainingAmount(for title: Title) -> Int {
        guard title.total > 0 else { return Int.max }
        return max(title.total - library.done(for: title.id), 0)
    }

    public func removeSession(_ id: UUID, title: Title) {
        library.sessions.removeAll { $0.id == id }

        guard let index = library.entries.firstIndex(where: { $0.titleID == title.id }) else {
            save()
            return
        }

        let done = library.done(for: title.id)
        if done <= 0 {
            library.entries[index].moveToWant()
        } else if title.total <= 0 || done < title.total {
            library.entries[index].start(on: library.entries[index].startedAt ?? Date())
        } else {
            library.entries[index].finish(on: library.sessions(for: title.id).map(\.date).max() ?? Date())
        }
        save()
    }

    public func updateNotes(_ id: TitleID, notes: String) {
        guard let index = library.entries.firstIndex(where: { $0.titleID == id }) else { return }
        library.entries[index].notes = notes
        save()
    }

    public func setStatus(_ id: TitleID, to status: ProgressStatus) {
        guard let index = library.entries.firstIndex(where: { $0.titleID == id }) else { return }
        switch status {
        case .want:
            library.entries[index].moveToWant()
        case .inProgress:
            library.entries[index].start(on: Date())
        case .finished:
            LibraryService().finish(id, in: &library, on: Date())
        }
        save()
    }

    public func recordRecentSearchSelection(_ title: Title) {
        library.recentTitles.removeAll { $0.id == title.id }
        library.recentTitles.insert(title, at: 0)
        if library.recentTitles.count > 10 {
            library.recentTitles = Array(library.recentTitles.prefix(10))
        }
        save()
    }

    public func setAppearance(_ appearance: Appearance) {
        library.appearance = appearance
        save()
    }

    public var customEntries: [EntryCardState] {
        library.titles
            .filter(\.isCustom)
            .compactMap { title in
                guard let entry = library.entry(for: title.id) else { return nil }
                return EntryCardState(title: title, entry: entry, done: library.done(for: title.id))
            }
    }

    public func deleteCustomEntry(_ id: TitleID) {
        guard id.source == .custom else { return }
        library.titles.removeAll { $0.id == id }
        library.entries.removeAll { $0.titleID == id }
        library.sessions.removeAll { $0.titleID == id }
        save()
    }

    public func resetLibrary() {
        library = Library()
        save()
    }

    public func exportData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(library)
    }

    public func title(for id: TitleID) -> Title? {
        library.titles.first(where: { $0.id == id })
    }

    private func save() {
        do { try store.save(library) }
        catch { errorMessage = "Could not save." }
    }
}
