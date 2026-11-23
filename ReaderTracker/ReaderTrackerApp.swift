//
//  ReaderTrackerApp.swift
//  ReaderTracker
//
//  Created by stud on 09/11/2026.
//

import SwiftUI

@main
struct ReaderTrackerApp: App {
    @State private var libraryViewModel = LibraryViewModel(
            store: JSONLibraryStore(url: URL.documentsDirectory.appending(path: "library.json")))
    
    var body: some Scene {
        WindowGroup {
            ContentView(library: libraryViewModel)
        }
    }
}
