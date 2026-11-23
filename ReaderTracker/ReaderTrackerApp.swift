//
//  ReaderTrackerApp.swift
//  ReaderTracker
//
//  Created by stud on 09/11/2026.
//

import SwiftUI

@main
struct ReaderTrackerApp: App {
    init() {
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 500 * 1024 * 1024,
            directory: URL.cachesDirectory.appendingPathComponent("ReaderTracker/URLCache")
        )
    }

    @State private var libraryViewModel = LibraryViewModel(
            store: JSONLibraryStore(url: URL.documentsDirectory.appending(path: "library.json")))
    
    var body: some Scene {
        WindowGroup {
            ContentView(library: libraryViewModel)
        }
    }
}
