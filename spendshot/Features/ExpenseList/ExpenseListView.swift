import SwiftData
import SwiftUI

struct ExpenseListView: View {
    @State private var month = Calendar.current.monthInterval(containing: .now)
    @State private var editor: EditorTarget?

    var body: some View {
        NavigationStack {
            MonthContent(month: month, editor: $editor)
                // Rebuild so @Query picks up the new month predicate.
                .id(month.start)
                .navigationTitle(Text(month.start, format: .dateTime.month(.wide).year().locale(.app)))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button("Bulan sebelumnya", systemImage: "chevron.left") { shift(-1) }
                        Button("Bulan berikutnya", systemImage: "chevron.right") { shift(1) }
                            .disabled(month.end > .now)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Tambah", systemImage: "plus") { editor = .new }
                    }
                }
                .sheet(item: $editor) { target in
                    switch target {
                    case .new: ExpenseFormView(expense: nil, defaultDate: defaultDate)
                    case .edit(let expense): ExpenseFormView(expense: expense, defaultDate: expense.date)
                    }
                }
        }
    }

    /// New expenses default to today, or the first day of a past month being viewed.
    private var defaultDate: Date { month.contains(.now) ? .now : month.start }

    private func shift(_ months: Int) {
        guard let date = Calendar.current.date(byAdding: .month, value: months, to: month.start) else { return }
        month = Calendar.current.monthInterval(containing: date)
    }
}

enum EditorTarget: Identifiable {
    case new
    case edit(Expense)

    var id: String {
        switch self {
        case .new: "new"
        case .edit(let expense): "\(expense.persistentModelID)"
        }
    }
}

private struct MonthContent: View {
    @Environment(\.modelContext) private var context
    @Query private var expenses: [Expense]
    @Binding var editor: EditorTarget?

    init(month: DateInterval, editor: Binding<EditorTarget?>) {
        _expenses = Query(Expense.descriptor(in: month))
        _editor = editor
    }

    private var days: [(day: Date, items: [Expense])] {
        Dictionary(grouping: expenses) { Calendar.current.startOfDay(for: $0.date) }
            .map { ($0.key, $0.value) }
            .sorted { $0.day > $1.day }
    }

    var body: some View {
        List {
            Section {
                MonthSummaryView(expenses: expenses)
                    .listRowInsets(EdgeInsets(top: 8, leading: 4, bottom: 12, trailing: 8))
                    .listRowBackground(Color.clear)
            }

            ForEach(days, id: \.day) { group in
                Section {
                    ForEach(group.items) { expense in
                        Button { editor = .edit(expense) } label: { ExpenseRow(expense: expense) }
                            .tint(.primary)
                    }
                    .onDelete { offsets in
                        offsets.map { group.items[$0] }.forEach(context.delete)
                    }
                } header: {
                    Text(group.day, format: .dateTime.weekday(.wide).day().month(.wide).locale(.app))
                }
            }
        }
        .overlay {
            if expenses.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("Belum ada pengeluaran")
                    } icon: {
                        PixelIcon(name: "EmptyWallet", size: 64, label: "Dompet kosong")
                    }
                } description: {
                    Text("Ketuk + untuk mencatat pengeluaran pertama bulan ini.")
                } actions: {
                    Button("Tambah pengeluaran") { editor = .new }
                        .buttonStyle(.borderedProminent)
                }
                .padding(.top, 220)
            }
        }
    }
}

#Preview {
    ExpenseListView().modelContainer(PreviewData.container)
}

#Preview("Empty") {
    ExpenseListView().modelContainer(for: Expense.self, inMemory: true)
}
