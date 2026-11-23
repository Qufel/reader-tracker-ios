import SwiftUI

struct LibraryView: View {
    let vm: LibraryViewModel
    @State private var showingCustomEntry = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if vm.isEmpty {
                        MockEmptyState(icon: "books.vertical",
                                       title: "Your Library Is Empty",
                                       message: "Add a book or audiobook to start tracking your reading.")
                            .padding(.top, 40)
                    } else {
                        if !vm.currentlyReading.isEmpty {
                            SectionHeader(title: "Currently Reading")
                            ForEach(vm.currentlyReading) { card in
                                if let title = vm.title(for: card.id) {
                                    NavigationLink(value: title.id) {
                                        EntryCardView(state: card)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if !vm.shelves.isEmpty {
                            SectionHeader(title: "Shelves")
                            ForEach(vm.shelves) { card in
                                if let title = vm.title(for: card.id) {
                                    NavigationLink(value: title.id) {
                                        EntryCardView(state: card)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingCustomEntry = true } label: {
                        Label("Add Custom Entry", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: TitleID.self) { id in
                if let title = vm.title(for: id) {
                    TitleDetailView(title: title, vm: vm)
                }
            }
            .sheet(isPresented: $showingCustomEntry) {
                CustomEntryView(vm: vm)
            }
        }
    }
}
