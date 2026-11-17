//
//  EntryCardState.swift
//  ReaderTracker
//
//  Created by stud on 17/11/2026.
//


// ReaderCore/ViewModels/EntryCardState.swift
public struct EntryCardState: Identifiable, Equatable {
    public let id: TitleID
    public let name: String
    public let subtitle: String        // "Frank Herbert · 1965"
    public let format: Format
    public let cover: Cover
    public let status: ProgressStatus?         // nil = not in library
    public let progress: Double?       // 0...1, only inProgress
    public let progressText: String?   // "Page 160 of 533" | "1h 20m left"
}

extension EntryCardState {
    init(title: Title, entry: LibraryEntry?, done: Int) {
        id = title.id
        name = title.name
        subtitle = [title.author, title.year.map(String.init)]
            .compactMap { $0 }.joined(separator: " · ")
        format = title.format
        cover = title.cover
        status = entry?.status

        if entry?.status == .inProgress, title.total > 0 {
            progress = min(Double(done) / Double(title.total), 1)
            switch title.format {
            case .print:
                progressText = "Page \(done) of \(title.total)"
            case .audio:
                let left = max(title.total - done, 0)
                progressText = "\(left / 3600)h \(left % 3600 / 60)m left"
            }
        } else {
            progress = nil
            progressText = nil
        }
    }
}
