import Foundation
import SwiftUI

struct TitleDetailView: View {
    let title: Title
    let vm: LibraryViewModel
    @State private var detailVM: TitleDetailViewModel

    init(title: Title, vm: LibraryViewModel) {
        self.title = title
        self.vm = vm
        _detailVM = State(initialValue: TitleDetailViewModel(title: title, library: vm))
    }

    @State private var showingReadingSample = false
    @State private var showingAudioSample = false
    @State private var showingTrailer = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 16) {
                    CoverView(cover: title.cover).frame(width: 112)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title.name).font(.title2.bold())
                        Text(title.author).foregroundStyle(.secondary)
                        if let year = title.year { Text(String(year)).foregroundStyle(.secondary) }
                        if let rating = title.rating {
                            Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                        StatusBadge(status: vm.library.entry(for: title.id)?.status ?? .want)
                    }
                }

                HStack(spacing: 10) {
                    if vm.library.entry(for: title.id) == nil {
                        Button("Add to Library") { detailVM.addToLibrary() }
                    } else {
                        Button("Start Reading") { detailVM.startReading() }
                            .disabled(vm.library.entry(for: title.id)?.status == .inProgress)
                        Button("Mark Finished") { detailVM.markFinished() }
                            .disabled(vm.library.entry(for: title.id)?.status == .finished)
                    }
                }
                .buttonStyle(.borderedProminent)

                if let summary = title.summary {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About").font(.headline)
                        Text(summary).foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Media").font(.headline)
                    if title.format == .print {
                        Button { showingReadingSample = true } label: {
                            Label("Read sample", systemImage: "doc.text")
                        }
                    } else {
                        Button { showingAudioSample = true } label: {
                            Label("Listen to sample", systemImage: "headphones")
                        }
                        Button { showingTrailer = true } label: {
                            Label("Watch trailer", systemImage: "play.rectangle")
                        }
                    }
                }

                if let entry = vm.library.entry(for: title.id) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Reading").font(.headline)
                        let done = vm.library.done(for: title.id)
                        let progress = title.total > 0 ? min(Double(done) / Double(title.total), 1) : 0
                        ProgressView(value: progress)
                        Text(title.format == .print
                             ? "Page \(done) of \(title.total)"
                             : "\(done / 3600)h \(done % 3600 / 60)m listened")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(title.format == .print ? "Book Details" : "Audiobook Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReadingSample) {
            ReadingSampleView(title: title)
        }
        .sheet(isPresented: $showingAudioSample) {
            AudioSampleView(title: title)
        }
        .sheet(isPresented: $showingTrailer) {
            TrailerView(title: title)
        }
    }
}

struct ReadingSampleView: View {
    let title: Title
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Excerpt from \(title.name)")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                Text("The opening page is a quiet invitation into the story. Turn the page, follow the characters, and discover where the first chapter leads.")
                    .font(.body)
                    .lineSpacing(6)
            }
            .padding()
            .navigationTitle("Reading Sample")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

struct AudioSampleView: View {
    let title: Title
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: isPlaying ? "waveform" : "headphones")
                    .font(.system(size: 64))
                    .symbolEffect(.variableColor.iterative, isActive: isPlaying)
                Text(title.name).font(.title3.bold())
                Text("Audiobook sample") .foregroundStyle(.secondary)
                Button(isPlaying ? "Pause preview" : "Play preview") { isPlaying.toggle() }
                    .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding()
            .navigationTitle("Audio Preview")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

struct TrailerView: View {
    let title: Title
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(.black.opacity(0.9))
                VStack(spacing: 16) {
                    Image(systemName: "play.circle.fill").font(.system(size: 64)).foregroundStyle(.white)
                    Text(title.name).font(.headline).foregroundStyle(.white)
                    Text("Official audiobook trailer") .foregroundStyle(.white.opacity(0.75))
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
            .padding()
            .navigationTitle("Trailer")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

struct CustomEntryView: View {
    let vm: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var entryVM: CustomEntryViewModel

    init(vm: LibraryViewModel) {
        self.vm = vm
        _entryVM = State(initialValue: CustomEntryViewModel(library: vm))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $entryVM.name)
                    TextField("Author", text: $entryVM.author)
                    TextField("Year", text: $entryVM.yearText).keyboardType(.numberPad)
                    Picker("Format", selection: $entryVM.format) {
                        Text("Book").tag(Format.print)
                        Text("Audiobook").tag(Format.audio)
                    }
                    TextField(entryVM.format == .print ? "Pages" : "Duration (minutes)", text: $entryVM.totalText)
                        .keyboardType(.numberPad)
                }
                Section("Shelf") {
                    Picker("Status", selection: $entryVM.status) {
                        Text("Want to Read").tag(ProgressStatus.want)
                        Text("Currently Reading").tag(ProgressStatus.inProgress)
                        Text("Finished").tag(ProgressStatus.finished)
                    }
                }
            }
            .navigationTitle("Add Custom Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        entryVM.save()
                        dismiss()
                    }.disabled(!entryVM.isValid)
                }
            }
        }
    }
}
