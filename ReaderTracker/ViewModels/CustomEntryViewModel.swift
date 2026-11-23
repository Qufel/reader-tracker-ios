import Foundation
import Observation

@MainActor
@Observable
public final class CustomEntryViewModel {
    public var name = ""
    public var author = ""
    public var yearText = ""
    public var format: Format = .print
    public var totalText = ""
    public var status: ProgressStatus = .want

    private let library: LibraryViewModel

    public init(library: LibraryViewModel) {
        self.library = library
    }

    public var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public func save() {
        guard isValid else { return }
        let number = Int(totalText) ?? 0
        let total = format == .audio ? number * 60 : number
        let title = Title(
            id: .custom(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            year: Int(yearText),
            format: format,
            total: total,
            cover: .color(hex: format == .print ? "#4F46E5" : "#B5701A"))
        library.addCustom(title: title, status: status)
    }
}
