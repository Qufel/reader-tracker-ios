//
//  CoverView.swift
//  ReaderTracker
//
//  Created by stud on 17/11/2026.
//


// ReaderTrackerApp/Views/Components/CoverView.swift
import SwiftUI

struct CoverView: View {
    let cover: Cover
    var cornerRadius: CGFloat = 8

    var body: some View {
        Color(.secondarySystemFill)                  // base. Fill what parent give.
            .aspectRatio(5.0 / 7.0, contentMode: .fit)
            .overlay { content }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.separator, lineWidth: 0.5)
            }
            .accessibilityHidden(true)               // name text is right next to it
    }

    @ViewBuilder
    private var content: some View {
        switch cover {
        case .url(let link):
            AsyncImage(url: link,
                       transaction: Transaction(animation: .easeIn(duration: 0.2))) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    placeholder
                default:
                    ProgressView()
                }
            }
        case .asset(let name):
            Image(name).resizable().scaledToFill()
        case .color(let hex):
            (Color(hex: hex) ?? .gray)
        }
    }

    private var placeholder: some View {
        Image(systemName: "book.closed")
            .font(.title2)
            .foregroundStyle(.secondary)
    }
}

// SwiftUI has no hex init. Small one. UInt32(radix:) is built-in.
extension Color {
    init?(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#").union(.whitespaces))
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        self.init(red: Double((v >> 16) & 0xFF) / 255,
                  green: Double((v >> 8) & 0xFF) / 255,
                  blue: Double(v & 0xFF) / 255)
    }
}

#Preview {
    HStack {
        CoverView(cover: .color(hex: "#0F6B5B")).frame(width: 56)
        CoverView(cover: .color(hex: "#B5701A")).frame(width: 100)
        CoverView(cover: .url(URL(string: "https://covers.openlibrary.org/b/id/12547191-M.jpg")!))
            .frame(width: 100)
        CoverView(cover: .color(hex: "nonsense")).frame(width: 56)   // gray
    }
    .padding()
}
