import Foundation

#if DEBUG
public extension Library {
    public static var preview: Library {
        let day: TimeInterval = 86_400
        let now = Date()

        let dune = Title(
            id: .init(source: .openLibrary, value: "OL893415W"),
            name: "Dune", author: "Frank Herbert", year: 1965,
            format: .print, total: 533,
            summary: "Set on the desert planet Arrakis, Dune is the story of young Paul Atreides.",
            rating: 4.3, cover: .color(hex: "#0F6B5C"))

        let audio = Title(
            id: .init(source: .libriVox, value: "1342"),
            name: "Pride and Prejudice", author: "Jane Austen", year: 1813,
            format: .audio, total: 11 * 3600 + 21 * 60,
            rating: 4.1, cover: .color(hex: "#B8741A"))

        let finished = Title(
            id: .init(source: .openLibrary, value: "OL1W"),
            name: "Last Wish", author: "Andrzej Sapkowski", year: 1993,
            format: .print, total: 360, cover: .color(hex: "#0F6B5C"))

        let want = Title(
            id: .init(source: .openLibrary, value: "OL2W"),
            name: "How To Win Friends And Influence People", author: "Dale Carnegie",
            year: 1936, format: .print, total: 262, cover: .color(hex: "#0F6B5C"))

        return Library(
            titles: [dune, audio, finished, want],
            entries: [
                LibraryEntry(titleID: dune.id, status: .inProgress,
                             startedAt: now - 5 * day),
                LibraryEntry(titleID: audio.id, status: .inProgress,
                             startedAt: now - 3 * day),
                LibraryEntry(titleID: finished.id, status: .finished,
                             startedAt: now - 20 * day, finishedAt: now - 10 * day),
                LibraryEntry(titleID: want.id, status: .want),
            ],
            sessions: [
                Session(titleID: dune.id, date: now - 2 * day, amount: 100),
                Session(titleID: dune.id, date: now - 1 * day, amount: 60),
                Session(titleID: audio.id, date: now - 1 * day, amount: 2 * 3600),
                Session(titleID: finished.id, date: now - 10 * day, amount: 360),
            ])
    }
}

@MainActor
public extension LibraryViewModel {
    public static var preview: LibraryViewModel {
        LibraryViewModel(store: InMemoryStore(library: .preview))
    }
    public static var previewEmpty: LibraryViewModel {
        LibraryViewModel(store: InMemoryStore())
    }
}
#endif
