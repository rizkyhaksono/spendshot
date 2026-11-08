import SwiftData
import SwiftUI

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            PixelIcon(name: expense.category.iconName, label: expense.category.name)
                .padding(6)
                .background(expense.category.color.opacity(0.25))

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.merchant)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text(expense.amount, format: .idr)
                .font(.pixel(13, relativeTo: .body))
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    List { ExpenseRow(expense: PreviewData.expense) }
        .modelContainer(PreviewData.container)
}
