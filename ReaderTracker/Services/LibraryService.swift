//
//  LibraryService.swift
//  ReaderTracker
//
//  Created by stud on 17/11/2026.
//

import Foundation

// Services/LibraryService.swift
public struct LibraryService {
    public init() {}

    public func finish(_ id: TitleID, in lib: inout Library, on date: Date) {
        guard let title = lib.titles.first(where: { $0.id == id }),
              let i = lib.entries.firstIndex(where: { $0.titleID == id })
        else { return }

        let missing = title.total - lib.done(for: id)
        if missing > 0 {
            lib.sessions.append(
                Session(titleID: id, date: date, amount: missing, isCompletion: true))
        }
        lib.entries[i].finish(on: date)
    }
}
