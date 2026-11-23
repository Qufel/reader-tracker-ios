import Foundation
import Observation

@MainActor
@Observable
public final class StatsViewModel {
    public var period: StatsPeriod = .week
    private let library: LibraryViewModel
    private let calculator: StatsCalculator

    public init(library: LibraryViewModel, calculator: StatsCalculator = StatsCalculator()) {
        self.library = library
        self.calculator = calculator
    }

    public var stats: ReadingStats {
        calculator.calculate(library: library.library, period: period)
    }
}
