import Foundation
import SwiftData

@Model
final class Expense {
    var merchant: String
    var amount: Decimal
    var date: Date
    // Stored as raw string so #Predicate can filter on it.
    var categoryRaw: String
    var note: String
    var createdAt: Date

    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(merchant: String, amount: Decimal, date: Date = .now, category: Category, note: String = "") {
        self.merchant = merchant
        self.amount = amount
        self.date = date
        self.categoryRaw = category.rawValue
        self.note = note
        self.createdAt = .now
    }
}

extension Expense {
    /// Expenses whose date falls inside `interval`, newest first.
    static func descriptor(in interval: DateInterval) -> FetchDescriptor<Expense> {
        let start = interval.start, end = interval.end
        return FetchDescriptor(
            predicate: #Predicate { $0.date >= start && $0.date < end },
            sortBy: [SortDescriptor(\.date, order: .reverse), SortDescriptor(\.createdAt, order: .reverse)]
        )
    }
}
