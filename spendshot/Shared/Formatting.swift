import Foundation

extension Locale {
    static let app = Locale(identifier: "id_ID")
}

extension FormatStyle where Self == Decimal.FormatStyle.Currency {
    /// "Rp 45.000" — IDR has no minor unit in daily use.
    static var idr: Decimal.FormatStyle.Currency {
        .currency(code: "IDR").locale(.app).precision(.fractionLength(0))
    }
}

extension Calendar {
    /// The calendar month containing `date`, as [start, start of next month).
    func monthInterval(containing date: Date) -> DateInterval {
        dateInterval(of: .month, for: date)!  // .month always resolves for a valid date
    }
}

enum Summary {
    /// Total per category, largest first. Categories with zero spend are omitted.
    static func totalsByCategory(_ expenses: [Expense]) -> [(category: Category, total: Decimal)] {
        Dictionary(grouping: expenses, by: \.category)
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }

    static func total(_ expenses: [Expense]) -> Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }
}
