//
//  ReaderTrackerApp.swift
//  ReaderTracker
//
//  Created by stud on 09/11/2026.
//

import SwiftUI
import SwiftData

@main
struct ReaderTrackerApp: App {
    @State private var library = LibraryViewModel(
            store: JSONLibraryStore(url: URL.documentsDirectory.appending(path: "library.json")))
    
    var body: some Scene {
        WindowGroup {
            ContentView(
//                library: library
            )
        }
    }
}

