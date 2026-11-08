import Foundation
import SwiftData

@MainActor
enum PreviewData {
    static let container: ModelContainer = {
        let container = try! ModelContainer(
            for: Expense.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let day: TimeInterval = 86_400
        let samples: [Expense] = [
            Expense(merchant: "Indomaret", amount: 45_000, category: .shopping),
            Expense(merchant: "Kopi Kenangan", amount: 28_000, category: .food),
            Expense(merchant: "Gojek", amount: 18_500, date: .now - day, category: .transport),
            Expense(merchant: "PLN Token", amount: 200_000, date: .now - 2 * day, category: .bills),
            Expense(merchant: "Apotek K-24", amount: 62_000, date: .now - 2 * day, category: .health, note: "Vitamin"),
        ]
        samples.forEach(container.mainContext.insert)
        return container
    }()

    static var expense: Expense {
        try! container.mainContext.fetch(FetchDescriptor<Expense>()).first!
    }
}

#if DEBUG
import SwiftUI

/// Debug-only: launch with `-seedSampleData` to fill an empty store (used for README screenshots).
struct DebugSeed: ViewModifier {
    @Environment(\.modelContext) private var context

    func body(content: Content) -> some View {
        content.task {
            guard ProcessInfo.processInfo.arguments.contains("-seedSampleData"),
                  (try? context.fetchCount(FetchDescriptor<Expense>())) == 0 else { return }
            let day: TimeInterval = 86_400
            [
                Expense(merchant: "Kopi Kenangan", amount: 28_000, category: .food),
                Expense(merchant: "Gojek", amount: 18_500, category: .transport, note: "ke kantor"),
                Expense(merchant: "Indomaret", amount: 45_000, date: .now - day, category: .shopping),
                Expense(merchant: "PLN Token", amount: 200_000, date: .now - day, category: .bills),
                Expense(merchant: "Bioskop XXI", amount: 50_000, date: .now - 2 * day, category: .entertainment),
                Expense(merchant: "Apotek K-24", amount: 62_000, date: .now - 2 * day, category: .health, note: "Vitamin"),
            ].forEach(context.insert)
        }
    }
}
#endif
