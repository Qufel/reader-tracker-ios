import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Library", systemImage: "book") {
                LibraryView()
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

#Preview {
    ContentView()
}
