import Foundation

public struct StatsCalculator {
    public init() {}

    public func calculate(library: Library, period: StatsPeriod, now: Date = .now,
                          calendar: Calendar = .current) -> ReadingStats {
        let intervalStart = startOfInterval(for: period, now: now, calendar: calendar)
        let sessions = library.sessions.filter { $0.date >= intervalStart && $0.date <= now }

        var pages = 0
        var audioSeconds = 0
        for session in sessions {
            guard let title = library.titles.first(where: { $0.id == session.titleID }) else { continue }
            if title.format == .print { pages += session.amount }
            if title.format == .audio { audioSeconds += session.amount }
        }

        let highlights = library.entries
            .filter { $0.status == .finished }
            .compactMap { entry in library.titles.first(where: { $0.id == entry.titleID }) }
            .prefix(3)

        return ReadingStats(
            finishedCount: library.entries.filter { $0.status == .finished }.count,
            pagesRead: pages,
            audioMinutes: audioSeconds / 60,
            readingStreakDays: readingStreak(in: library.sessions, calendar: calendar, now: now),
            activity: groupedActivity(sessions: sessions, period: period, now: now, calendar: calendar),
            recentHighlights: Array(highlights))
    }

    public func startOfInterval(for period: StatsPeriod, now: Date, calendar: Calendar) -> Date {
        switch period {
        case .week:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        case .month:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        case .year:
            return calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        }
    }

    private func groupedActivity(sessions: [Session], period: StatsPeriod, now: Date,
                                 calendar: Calendar) -> [ActivityBucket] {
        let start = startOfInterval(for: period, now: now, calendar: calendar)
        let formatter = DateFormatter()
        formatter.calendar = calendar

        switch period {
        case .week:
            formatter.dateFormat = "EEE"
            return (0..<7).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
                let day = calendar.startOfDay(for: date)
                let amount = sessions.reduce(0) { total, session in
                    calendar.isDate(session.date, inSameDayAs: day) ? total + session.amount : total
                }
                return ActivityBucket(id: day, label: formatter.string(from: day), amount: amount)
            }

        case .month:
            formatter.dateFormat = "MMM d"
            guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: start) else { return [] }
            var cursor = start
            var buckets: [ActivityBucket] = []
            while cursor < monthEnd {
                let bucketEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: cursor) ?? monthEnd
                let end = min(bucketEnd, monthEnd)
                let amount = sessions.reduce(0) { total, session in
                    session.date >= cursor && session.date < end ? total + session.amount : total
                }
                buckets.append(ActivityBucket(id: cursor, label: formatter.string(from: cursor), amount: amount))
                cursor = end
            }
            return buckets

        case .year:
            formatter.dateFormat = "MMM"
            return (0..<12).compactMap { offset in
                guard let date = calendar.date(byAdding: .month, value: offset, to: start) else { return nil }
                let key = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
                let next = calendar.date(byAdding: .month, value: 1, to: key) ?? date
                let amount = sessions.reduce(0) { total, session in
                    session.date >= key && session.date < next ? total + session.amount : total
                }
                return ActivityBucket(id: key, label: formatter.string(from: key), amount: amount)
            }
        }
    }

    private func readingStreak(in sessions: [Session], calendar: Calendar, now: Date) -> Int {
        let activeDays = Set(sessions.map { calendar.startOfDay(for: $0.date) })
        guard !activeDays.isEmpty else { return 0 }
        var cursor = calendar.startOfDay(for: now)
        if !activeDays.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = yesterday
        }
        var streak = 0
        while activeDays.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }
}
