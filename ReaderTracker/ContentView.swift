import SwiftUI
import SwiftData

struct ContentView: View {
    let library : LibraryViewModel

    var body: some View {
        TabView {
            Tab("Library", systemImage: "book") {
                LibraryView(vm: library)
            }
            
            Tab("Search", systemImage: "magnifyingglass") {
                SearchView()
            }
            
            Tab("Stats", systemImage: "chart.bar") {
                StatsView()
            }
            
            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
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
