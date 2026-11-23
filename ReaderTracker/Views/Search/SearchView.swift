import SwiftUI

struct SearchView: View {
    let vm: LibraryViewModel
    @State private var searchVM: SearchViewModel
    @State private var showingCustomEntry = false

    init(vm: LibraryViewModel) {
        self.vm = vm
        _searchVM = State(initialValue: .local(library: vm))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button { showingCustomEntry = true } label: {
                        Label("Add a custom entry", systemImage: "plus.circle.fill")
                    }
                }

                if searchVM.results.isEmpty {
                    Section {
                        MockEmptyState(icon: "magnifyingglass", title: "No Results",
                                       message: "Try a title or author name.")
                    }
                } else {
                    Section(searchVM.query.isEmpty ? "Discover" : "Results") {
                        ForEach(searchVM.results) { title in
                            NavigationLink(value: title.id) {
                                HStack(spacing: 12) {
                                    CoverView(cover: title.cover).frame(width: 50)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(title.name).font(.headline)
                                        Text(title.author).font(.caption).foregroundStyle(.secondary)
                                        Text(title.format == .print ? "Book" : "Audiobook")
                                            .font(.caption2).foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Search")
            .searchable(text: $searchVM.query, prompt: "Titles or authors")
            .task(id: searchVM.query) {
                try? await Task.sleep(for: .milliseconds(250))
                await searchVM.search()
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

#Preview {
    SearchView(vm: .preview)
}
