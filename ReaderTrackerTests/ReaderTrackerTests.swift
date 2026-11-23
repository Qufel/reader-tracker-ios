//
//  ReaderTrackerTests.swift
//  ReaderTrackerTests
//
//  Created by stud on 09/11/2026.
//

import Testing
import Foundation
@testable import ReaderTracker

private final class MockOpenLibraryURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let json = """
        {"docs":[{
          "key":"/works/OL893415W",
          "title":"Dune",
          "author_name":["Frank Herbert"],
          "first_publish_year":1965,
          "number_of_pages_median":533,
          "cover_i":123,
          "ratings_average":4.3,
          "first_sentence":["A beginning is the time for taking the most delicate care."]
        }]}
        """
        let response = HTTPURLResponse(url: request.url!, statusCode: 200,
                                       httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(json.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

struct ReaderTrackerTests {

    @Test func finishingEntryAddsOnlyTheMissingAmount() {
        let title = Title(
            id: TitleID(source: .custom, value: "test"),
            name: "Test",
            author: "Author",
            format: .print,
            total: 100,
            cover: .color(hex: "#000000"))
        var library = Library(
            titles: [title],
            entries: [LibraryEntry(titleID: title.id)],
            sessions: [Session(titleID: title.id, date: .now, amount: 40)])

        LibraryService().finish(title.id, in: &library, on: .now)

        #expect(library.done(for: title.id) == 100)
        #expect(library.sessions.last?.amount == 60)
        #expect(library.entries.first?.status == .finished)
    }

    @Test func loggingSessionAddsSessionAndStartsEntry() {
        let store = InMemoryStore()
        let vm = LibraryViewModel(store: store)
        let title = Title(
            id: TitleID(source: .custom, value: "session-test"),
            name: "Session Test", author: "Author", format: .print,
            total: 100, cover: .color(hex: "#000000"))

        vm.logSession(title, amount: 25)

        #expect(vm.library.done(for: title.id) == 25)
        #expect(vm.library.entry(for: title.id)?.status == .inProgress)
        #expect(vm.library.sessions(for: title.id).count == 1)
    }

    @Test func deletingCustomEntryRemovesAllRelatedData() {
        let title = Title(
            id: TitleID(source: .custom, value: "delete-test"),
            name: "Delete Test", author: "Author", format: .print,
            total: 100, cover: .color(hex: "#000000"))
        let store = InMemoryStore(library: Library(
            titles: [title],
            entries: [LibraryEntry(titleID: title.id, status: .inProgress)],
            sessions: [Session(titleID: title.id, date: .now, amount: 20)]))
        let vm = LibraryViewModel(store: store)

        vm.deleteCustomEntry(title.id)

        #expect(vm.library.titles.isEmpty)
        #expect(vm.library.entries.isEmpty)
        #expect(vm.library.sessions.isEmpty)
    }

    @Test func jsonStoreRoundTripsDates() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("library.json")
        let title = Title(
            id: TitleID(source: .custom, value: "test"),
            name: "Test",
            author: "Author",
            format: .print,
            total: 100,
            cover: .color(hex: "#000000"))
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let library = Library(
            titles: [title],
            entries: [LibraryEntry(titleID: title.id, startedAt: date)],
            sessions: [Session(titleID: title.id, date: date, amount: 10)])

        let store = JSONLibraryStore(url: url)
        try store.save(library)
        let loaded = try store.load()

        #expect(loaded == library)
        try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }

    @Test func statsCalculateWithinCalendarWeek() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let title = Title(
            id: TitleID(source: .custom, value: "stats"),
            name: "Stats", author: "Author", format: .print,
            total: 100, cover: .color(hex: "#000000"))
        let monday = calendar.date(from: DateComponents(year: 2026, month: 11, day: 23))!
        let sunday = calendar.date(from: DateComponents(year: 2026, month: 11, day: 29))!
        let library = Library(
            titles: [title],
            entries: [LibraryEntry(titleID: title.id, status: .inProgress)],
            sessions: [
                Session(titleID: title.id, date: monday, amount: 20),
                Session(titleID: title.id, date: sunday, amount: 30),
                Session(titleID: title.id, date: calendar.date(byAdding: .day, value: -8, to: monday)!, amount: 500)
            ])

        let stats = StatsCalculator().calculate(library: library, period: .week, now: monday, calendar: calendar)

        #expect(stats.pagesRead == 20)
    }

    @Test func openLibrarySearchMapsDocumentToPrintTitle() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockOpenLibraryURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let provider = OpenLibrarySearchProvider(session: session)

        let titles = try await provider.search(query: "Dune")

        #expect(titles.count == 1)
        #expect(titles.first?.name == "Dune")
        #expect(titles.first?.author == "Frank Herbert")
        #expect(titles.first?.format == .print)
        #expect(titles.first?.year == 1965)
        #expect(titles.first?.id.source == .openLibrary)
        #expect(titles.first?.cover == .url(URL(string: "https://covers.openlibrary.org/b/id/123-L.jpg")!))
    }

    @Test func openLibrarySearchIgnoresBlankQuery() async throws {
        let provider = OpenLibrarySearchProvider()
        #expect(try await provider.search(query: "   ") == [])
    }

    @Test func localSearchMatchesNameAndAuthor() async throws {
        let title = Title(
            id: TitleID(source: .custom, value: "search"),
            name: "The Left Hand", author: "Ursula Le Guin", format: .print,
            total: 300, cover: .color(hex: "#000000"))
        let provider = LocalTitleSearchProvider { [title] }

        #expect(try await provider.search(query: "guin") == [title])
        #expect(try await provider.search(query: "left") == [title])
    }

}
