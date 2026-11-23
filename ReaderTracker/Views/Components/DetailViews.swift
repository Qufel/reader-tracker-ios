import Foundation
import SwiftUI

struct TitleDetailView: View {
    let title: Title
    let vm: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var detailVM: TitleDetailViewModel

    init(title: Title, vm: LibraryViewModel) {
        self.title = title
        self.vm = vm
        _detailVM = State(initialValue: TitleDetailViewModel(title: title, library: vm))
    }

    @State private var showingReadingSample = false
    @State private var showingAudioSample = false
    @State private var showingTrailer = false
    @State private var showingLogSession = false
    @State private var showingDeleteConfirmation = false
    @State private var showFullSummary = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    CoverView(cover: title.cover)
                        .frame(width: 112, height: 168)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 7) {
                        Text(title.name)
                            .font(.title3.bold())
                            .lineLimit(3)
                        Text(title.author)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let year = title.year {
                            Text(year.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let rating = title.rating {
                            HStack(spacing: 2) {
                                ForEach(0..<5, id: \.self) { index in
                                    Image(systemName: Double(index) < rating ? "star.fill" : "star")
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                }
                                Text(String(format: " %.1f", rating)).font(.caption)
                            }
                        }
                        Text(title.format == .print ? "Book" : "Audiobook")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.teal)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.teal.opacity(0.12), in: Capsule())
                        Text(title.format == .print ? "\(title.total) Pages" : "\(title.total / 60) Minutes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let summary = title.summary {
                    Text(summary)
                        .font(.subheadline)
                        .lineLimit(showFullSummary ? nil : 3)
                    Button(showFullSummary ? "Less" : "More") {
                        showFullSummary.toggle()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.teal)
                }

                HStack(spacing: 8) {
                    Button(title.format == .print ? "Read Sample" : "Listen to Sample") {
                        if title.format == .print { showingReadingSample = true } else { showingAudioSample = true }
                    }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        .tint(.teal)
                    Button("Watch Trailer") { showingTrailer = true }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        .tint(.teal)
                }

                if let entry = vm.library.entry(for: title.id) {
                    statusSegment(entry.status)

                    if entry.status == .inProgress || entry.status == .finished {
                        ProgressCard(title: title, vm: vm)
                        if entry.status == .inProgress {
                            Button("Log Reading Session") { showingLogSession = true }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .background(.teal, in: RoundedRectangle(cornerRadius: 16))
                        }
                    } else if entry.status == .want {
                        Button("Start Reading") { detailVM.startReading() }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .background(.teal, in: RoundedRectangle(cornerRadius: 16))
                    }

                    SessionList(title: title, vm: vm)
                    NotesEditor(title: title, vm: vm, entry: entry)
                } else {
                    statusSegment(nil)
                    Button("Start Reading") {
                        detailVM.addToLibrary()
                        detailVM.startReading()
                    }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .background(.teal, in: RoundedRectangle(cornerRadius: 16))
                    NotesEditor(title: title, vm: vm, entry: nil)
                }

                if title.isCustom {
                    Button("Delete Custom Entry", role: .destructive) { showingDeleteConfirmation = true }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .confirmationDialog("Delete Custom Entry?", isPresented: $showingDeleteConfirmation) {
                            Button("Delete", role: .destructive) {
                                vm.deleteCustomEntry(title.id)
                                dismiss()
                            }
                        } message: {
                            Text("This removes the title and all of its reading sessions.")
                        }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
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
        .sheet(isPresented: $showingLogSession) {
            LogSessionView(title: title, vm: vm)
        }
    }
}

extension TitleDetailView {
    func statusSegment(_ status: ProgressStatus?) -> some View {
        HStack(spacing: 0) {
            segment("Want", selected: status == .want) { selectStatus(.want) }
            segment("Reading", selected: status == .inProgress) { selectStatus(.inProgress) }
            segment("Finished", selected: status == .finished) { selectStatus(.finished) }
        }
        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 0.5))
        .frame(height: 48)
    }

    private func segment(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(selected ? .white : .clear, in: RoundedRectangle(cornerRadius: 10))
                .shadow(color: selected ? .black.opacity(0.08) : .clear, radius: 2, y: 1)
                .padding(4)
        }
        .buttonStyle(.plain)
    }

    private func selectStatus(_ status: ProgressStatus) {
        if vm.library.entry(for: title.id) == nil {
            vm.addTitle(title, status: status)
        } else {
            vm.setStatus(title.id, to: status)
        }
    }
}

struct ProgressCard: View {
    let title: Title
    let vm: LibraryViewModel

    var body: some View {
        let done = vm.library.done(for: title.id)
        let progress = title.total > 0 ? min(Double(done) / Double(title.total), 1) : 0
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(Int(progress * 100))%").font(.title3.bold())
                Spacer()
                Text(title.format == .print
                     ? "\(done) of \(title.total) pages"
                     : "\(done / 3600)h \(done % 3600 / 60)m listened")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: progress)
                .tint(.teal)
            let entry = vm.library.entry(for: title.id)
            if let started = entry?.startedAt {
                let startedText = "Started \(started.formatted(.dateTime.day().month(.abbreviated).year()))"
                if let finished = entry?.finishedAt {
                    Text("\(startedText) · Finished \(finished.formatted(.dateTime.day().month(.abbreviated).year()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(startedText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray4), lineWidth: 0.5))
    }
}

struct SessionList: View {
    let title: Title
    let vm: LibraryViewModel

    var body: some View {
        let sessions = vm.library.sessions(for: title.id)
        if !sessions.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Last Sessions").font(.title3.bold())
                ForEach(sessions.prefix(5)) { session in
                    HStack {
                        Text(session.date.formatted(.dateTime.day().month(.abbreviated).weekday(.wide).year()))
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text("+\(title.format == .print ? "\(session.amount) Pages" : "\(session.amount / 60) Minutes")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray4), lineWidth: 0.5))
                }
            }
        }
    }
}

struct NotesEditor: View {
    let title: Title
    let vm: LibraryViewModel
    let entry: LibraryEntry?
    @State private var notes = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes").font(.title3.bold())
            TextField("Add a thought or quote…", text: $notes, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .frame(minHeight: 60, alignment: .top)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray4), lineWidth: 0.5))
                .onAppear { notes = entry?.notes ?? "" }
                .onChange(of: notes) { _, newValue in
                    vm.updateNotes(title.id, notes: newValue)
                }
        }
    }
}

struct LogSessionView: View {
    let title: Title
    let vm: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()
    @State private var amountText = ""

    private var amount: Int? {
        guard let amount = Int(amountText), amount > 0 else { return nil }
        return title.format == .audio ? amount * 60 : amount
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                TextField(title.format == .print ? "Pages read" : "Minutes listened",
                          text: $amountText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Log Reading Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount {
                            vm.logSession(title, amount: amount, date: date)
                            dismiss()
                        }
                    }
                    .disabled(amount == nil)
                }
            }
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
