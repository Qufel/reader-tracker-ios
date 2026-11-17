//
//  LibraryView.swift
//  ReaderTracker
//
//  Created by stud on 09/11/2026.
//

import SwiftUI

struct LibraryView: View {
    let vm: LibraryViewModel
    
    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Currently Reading")
                        ForEach(vm.currentlyReading) { card in
                            NavigationLink(value: card.id) {
                                EntryCardView(state: card)
                            }
                            .buttonStyle(.plain)
                        }

                        Text("Shelves")
                        ForEach(vm.shelves) { card in
                            NavigationLink(value: card.id) {
                                EntryCardView(state: card)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
    
}
