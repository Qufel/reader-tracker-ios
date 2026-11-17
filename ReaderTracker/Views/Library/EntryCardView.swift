// ReaderTrackerApp/Views/Library/EntryCardView.swift
import SwiftUI

struct EntryCardView: View {
    let state: EntryCardState

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CoverView(cover: state.cover)
                .frame(width: 56, height: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(state.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(state.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                }

                if let progress = state.progress,
                   let text = state.progressText {
                    ProgressView(value: progress, )
                    Text(text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
    }
}

#Preview {
    EntryCardView(state: .init(
        id: .init(source: .openLibrary, value: "OL1W"),
        name: "Dune", subtitle: "Frank Herbert · 1965",
        format: .print, cover: .color(hex: "#0F6B5B"),
        status: .inProgress, progress: 0.3,
        progressText: "Page 160 of 533"))
    .padding()
}
