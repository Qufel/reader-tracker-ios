//
//  ReaderTrackerTests.swift
//  ReaderTrackerTests
//
//  Created by stud on 09/11/2026.
//

import Testing
import Foundation
@testable import ReaderTracker

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
