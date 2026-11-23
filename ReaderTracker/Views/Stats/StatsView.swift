import SwiftUI

struct StatsView: View {
    let vm: LibraryViewModel
    @State private var statsVM: StatsViewModel

    init(vm: LibraryViewModel) {
        self.vm = vm
        _statsVM = State(initialValue: StatsViewModel(library: vm))
    }

    private var stats: ReadingStats { statsVM.stats }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Picker("Period", selection: $statsVM.period) {
                        Text("Week").tag(StatsPeriod.week)
                        Text("Month").tag(StatsPeriod.month)
                        Text("Year").tag(StatsPeriod.year)
                    }
                    .pickerStyle(.segmented)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MockStatCard(title: "Finished", value: "\(stats.finishedCount)", icon: "checkmark.circle.fill", tint: .green)
                        MockStatCard(title: "Pages Read", value: "\(stats.pagesRead)", icon: "book.pages.fill", tint: .indigo)
                        MockStatCard(title: "Audio Minutes", value: "\(stats.audioMinutes)", icon: "headphones", tint: .orange)
                        MockStatCard(title: "Reading Streak", value: "\(stats.readingStreakDays) days", icon: "flame.fill", tint: .red)
                    }

                    SectionHeader(title: "Reading Activity")
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(stats.activity) { bucket in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.tint)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: CGFloat(activityHeight(for: bucket)))
                                Text(bucket.label).font(.caption2).lineLimit(1)
                            }
                            .frame(height: 86)
                        }
                    }
                    .frame(height: 100, alignment: .bottom)
                    .padding()
                    .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))

                    SectionHeader(title: "Recent Highlights")
                    ForEach(stats.recentHighlights) { title in
                        HStack {
                            Image(systemName: "trophy.fill").foregroundStyle(.yellow)
                            Text("Finished \(title.name)").font(.subheadline)
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding()
            }
            .navigationTitle("Stats")
        }
    }
    private func activityHeight(for bucket: ActivityBucket) -> CGFloat {
        let maximum = max(stats.activity.map(\.amount).max() ?? 1, 1)
        return 12 + (CGFloat(bucket.amount) / CGFloat(maximum) * 58)
    }

}

#Preview {
    StatsView(vm: .preview)
}
