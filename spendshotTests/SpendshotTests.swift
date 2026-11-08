import Foundation
import Testing
@testable import spendshot

struct MonthIntervalTests {
    let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Jakarta")!
        return c
    }()

    private func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d, hour: h))!
    }

    @Test func containsWholeMonth() {
        let month = calendar.monthInterval(containing: date(2026, 11, 15))
        #expect(month.start == date(2026, 11, 1, 0))
        #expect(month.end == date(2026, 12, 1, 0))
        #expect(month.contains(date(2026, 11, 30, 23)))
    }

    @Test func decemberRollsOverToJanuary() {
        let month = calendar.monthInterval(containing: date(2026, 12, 31, 23))
        #expect(month.end == date(2027, 1, 1, 0))
    }

    @Test func februaryInLeapYear() {
        let month = calendar.monthInterval(containing: date(2028, 2, 10))
        #expect(month.end == date(2028, 3, 1, 0))
    }
}

@MainActor
struct SummaryTests {
    @Test func totalsGroupAndSortByCategory() {
        let expenses = [
            Expense(merchant: "A", amount: 10_000, category: .food),
            Expense(merchant: "B", amount: 25_000, category: .transport),
            Expense(merchant: "C", amount: 20_000, category: .food),
        ]
        let rows = Summary.totalsByCategory(expenses)
        #expect(rows.map(\.category) == [.food, .transport])
        #expect(rows.map(\.total) == [30_000, 25_000])
        #expect(Summary.total(expenses) == 55_000)
    }

    @Test func decimalAvoidsFloatingPointDrift() {
        let expenses = (0..<10).map { _ in Expense(merchant: "x", amount: Decimal(string: "0.1")!, category: .other) }
        #expect(Summary.total(expenses) == 1)
    }

    @Test func emptyInput() {
        #expect(Summary.totalsByCategory([]).isEmpty)
        #expect(Summary.total([]) == 0)
    }
}

@MainActor
struct ExpenseDraftTests {
    @Test func requiresPositiveAmountAndMerchant() {
        var draft = ExpenseDraft()
        #expect(!draft.isValid)
        draft.amountText = "45000"
        #expect(!draft.isValid)
        draft.merchant = "   "
        #expect(!draft.isValid)
        draft.merchant = "Indomaret"
        #expect(draft.isValid)
        draft.amountText = "0"
        #expect(!draft.isValid)
    }

    @Test func parsesDigits() {
        var draft = ExpenseDraft()
        draft.amountText = "45000"
        #expect(draft.amount == 45_000)
        draft.amountText = ""
        #expect(draft.amount == 0)
    }

    @Test func roundTripsFromExpense() {
        let expense = Expense(merchant: "Gojek", amount: 18_500, category: .transport, note: "ke kantor")
        let draft = ExpenseDraft(expense)
        #expect(draft.amountText == "18500")
        #expect(draft.amount == 18_500)
        #expect(draft.category == .transport)
        #expect(draft.note == "ke kantor")
    }
}
