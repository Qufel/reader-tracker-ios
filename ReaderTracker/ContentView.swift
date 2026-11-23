import SwiftUI

struct ContentView: View {
    let library: LibraryViewModel

    var body: some View {
        TabView {
            Tab("Library", systemImage: "book") {
                LibraryView(vm: library)
            }
            
            Tab("Search", systemImage: "magnifyingglass") {
                SearchView(vm: library)
            }
            
            Tab("Stats", systemImage: "chart.bar") {
                StatsView(vm: library)
            }
            
            Tab("Settings", systemImage: "gearshape") {
                SettingsView(vm: library)
            }
        }
        .preferredColorScheme(library.library.appearance == .dark ? .dark : (library.library.appearance == .light ? .light : nil))
        .alert(
            "Library Error",
            isPresented: Binding(
                get: { library.errorMessage != nil },
                set: { if !$0 { library.dismissError() } }),
            presenting: library.errorMessage) { _ in
                Button("OK") {
                    library.dismissError()
                }
            } message: { message in
                Text(message)
            }
    }

}

#Preview("Light") {
    ContentView(library: .preview)
}

#Preview("Dark") {
    ContentView(library: .preview)
        .preferredColorScheme(.dark)
}

#Preview("Empty") {
    ContentView(library: .previewEmpty)
}
