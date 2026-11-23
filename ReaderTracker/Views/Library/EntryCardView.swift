import SwiftUI

struct EntryCardView: View {
    let state: EntryCardState

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            CoverView(cover: state.cover)
                .frame(width: 64)

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(state.name).font(.headline).lineLimit(2)
                        Text(state.subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                    Spacer()
                    StatusBadge(status: state.status ?? .want)
                }

                if let progress = state.progress, let text = state.progressText {
                    ProgressView(value: progress)
                    Text(text).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.separator.opacity(0.5), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
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
