import SwiftUI

struct SettingsView: View {
    let vm: LibraryViewModel
    @State private var settingsVM: SettingsViewModel
    @State private var showingResetConfirmation = false

    init(vm: LibraryViewModel) {
        self.vm = vm
        _settingsVM = State(initialValue: SettingsViewModel(library: vm))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $settingsVM.appearance) {
                        Text("System").tag(Appearance.system)
                        Text("Light").tag(Appearance.light)
                        Text("Dark").tag(Appearance.dark)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Library") {
                    NavigationLink("Manage Custom Entries") {
                        CustomEntriesManagementView(vm: settingsVM)
                    }
                    HStack { Text("Titles"); Spacer(); Text("\(settingsVM.titleCount)").foregroundStyle(.secondary) }
                    HStack { Text("Reading Sessions"); Spacer(); Text("\(settingsVM.sessionCount)").foregroundStyle(.secondary) }

                    if let data = try? settingsVM.exportData(),
                       let url = exportedLibraryURL(data: data) {
                        ShareLink(item: url) {
                            Label("Export Library", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button("Reset Library", role: .destructive) {
                        showingResetConfirmation = true
                    }
                }

                Section("About") {
                    HStack { Text("Version"); Spacer(); Text(settingsVM.metadata.version).foregroundStyle(.secondary) }
                    HStack { Text("Build"); Spacer(); Text(settingsVM.metadata.build).foregroundStyle(.secondary) }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Reset Library?", isPresented: $showingResetConfirmation) {
                Button("Reset Library", role: .destructive) { settingsVM.resetLibrary() }
            } message: {
                Text("This removes titles, entries, and reading sessions.")
            }
        }
    }

    private func exportedLibraryURL(data: Data) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ReaderTracker-Library.json")
        try? data.write(to: url, options: .atomic)
        return url
    }
}

struct CustomEntriesManagementView: View {
    let vm: SettingsViewModel

    var body: some View {
        List {
            if vm.customEntries.isEmpty {
                Text("No custom entries")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(vm.customEntries) { state in
                    HStack {
                        CoverView(cover: state.cover).frame(width: 44)
                        VStack(alignment: .leading) {
                            Text(state.name).font(.headline)
                            Text(state.subtitle).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) { vm.deleteCustomEntry(state.id) }
                    }
                }
            }
        }
        .navigationTitle("Custom Entries")
    }
}

#Preview {
    SettingsView(vm: .preview)
}
