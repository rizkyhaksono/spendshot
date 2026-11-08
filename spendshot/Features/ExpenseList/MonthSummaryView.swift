import SwiftData
import SwiftUI

struct MonthSummaryView: View {
    let expenses: [Expense]

    private var total: Decimal { Summary.total(expenses) }
    private var rows: [(category: Category, total: Decimal)] { Summary.totalsByCategory(expenses) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TOTAL")
                .font(.pixel(11, relativeTo: .caption))
                .foregroundStyle(.secondary)
            Text(total, format: .idr)
                .font(.pixel(28, relativeTo: .largeTitle))
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            if total > 0 {
                PixelBar(rows: rows, total: total)
                    .frame(height: 12)
                    .accessibilityHidden(true)

                ForEach(rows, id: \.category) { row in
                    HStack {
                        Rectangle().fill(row.category.color).frame(width: 10, height: 10)
                        Text(row.category.name).font(.subheadline)
                        Spacer()
                        Text(row.total, format: .idr)
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pixelCard()
    }
}

/// Stacked horizontal bar, one hard-edged segment per category.
private struct PixelBar: View {
    let rows: [(category: Category, total: Decimal)]
    let total: Decimal

    var body: some View {
        GeometryReader { geo in
            // Segment widths share what is left after the 2pt gaps, so the bar never overflows.
            let available = max(0, geo.size.width - CGFloat(rows.count - 1) * 2)
            HStack(spacing: 2) {
                ForEach(rows, id: \.category) { row in
                    Rectangle()
                        .fill(row.category.color)
                        .frame(width: available * share(row.total))
                }
            }
        }
        .clipped()
        .overlay(Rectangle().strokeBorder(Color.ink, lineWidth: 2))
    }

    private func share(_ value: Decimal) -> CGFloat {
        CGFloat(truncating: (value / total) as NSDecimalNumber)
    }
}

#Preview {
    MonthSummaryView(expenses: [
        Expense(merchant: "A", amount: 120_000, category: .food),
        Expense(merchant: "B", amount: 50_000, category: .transport),
        Expense(merchant: "C", amount: 200_000, category: .bills),
    ])
    .padding()
    .modelContainer(PreviewData.container)
}
