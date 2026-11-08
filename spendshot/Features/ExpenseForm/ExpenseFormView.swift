import SwiftData
import SwiftUI

/// Add (expense == nil) or edit an expense. Edits a draft and writes only on Save.
@MainActor
struct ExpenseFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let expense: Expense?

    @State private var draft: ExpenseDraft
    @FocusState private var focusedField: Field?

    private enum Field { case amount, merchant }

    init(expense: Expense?, defaultDate: Date) {
        self.expense = expense
        _draft = State(initialValue: expense.map(ExpenseDraft.init) ?? ExpenseDraft(date: defaultDate))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        // Raw digits only: reformatting while typing makes the cursor jump.
                        TextField("Jumlah", text: $draft.amountText)
                            .keyboardType(.numberPad)
                            .onChange(of: draft.amountText) { _, new in
                                let digits = String(new.filter(\.isWholeNumber).prefix(12))
                                if digits != new { draft.amountText = digits }
                            }
                        Text(draft.amount, format: .idr)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                        .font(.pixel(24, relativeTo: .title))
                        .focused($focusedField, equals: .amount)
                    TextField("Toko / merchant", text: $draft.merchant)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .merchant)
                }

                Section("Kategori") {
                    CategoryPicker(selection: $draft.category)
                }

                Section {
                    DatePicker("Tanggal", selection: $draft.date, in: ...Date.now, displayedComponents: .date)
                        .environment(\.locale, .app)
                    TextField("Catatan (opsional)", text: $draft.note, axis: .vertical)
                }

                if expense != nil {
                    Section {
                        Button("Hapus pengeluaran", role: .destructive, action: delete)
                    }
                }
            }
            .navigationTitle(expense == nil ? "Pengeluaran baru" : "Ubah pengeluaran")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan", action: save).disabled(!draft.isValid)
                }
            }
            .onAppear { if expense == nil { focusedField = .amount } }
        }
        .interactiveDismissDisabled(draft != (expense.map(ExpenseDraft.init) ?? draft))
    }

    private func save() {
        guard draft.isValid else { return }
        let merchant = draft.merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = draft.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if let expense {
            expense.merchant = merchant
            expense.amount = draft.amount
            expense.date = draft.date
            expense.category = draft.category
            expense.note = note
        } else {
            context.insert(Expense(merchant: merchant, amount: draft.amount, date: draft.date,
                                   category: draft.category, note: note))
        }
        dismiss()
    }

    private func delete() {
        if let expense { context.delete(expense) }
        dismiss()
    }
}

/// Editable copy of an expense. Value type so Cancel discards changes for free.
struct ExpenseDraft: Equatable {
    var merchant = ""
    /// Raw digits as typed, e.g. "45000".
    var amountText = ""
    var date = Date.now
    var category = Category.food
    var note = ""

    init(date: Date = .now) { self.date = date }

    init(_ expense: Expense) {
        merchant = expense.merchant
        amountText = "\(NSDecimalNumber(decimal: expense.amount).int64Value)"
        date = expense.date
        category = expense.category
        note = expense.note
    }

    var amount: Decimal { Decimal(string: amountText) ?? 0 }

    var isValid: Bool {
        amount > 0 && !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct CategoryPicker: View {
    @Binding var selection: Category

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 8)], spacing: 8) {
            ForEach(Category.allCases) { category in
                let isSelected = category == selection
                Button { selection = category } label: {
                    VStack(spacing: 4) {
                        PixelIcon(name: category.iconName, size: 32, label: category.name)
                            .accessibilityHidden(true)
                        Text(category.name).font(.caption2).lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? category.color.opacity(0.35) : .clear)
                    .overlay(Rectangle().strokeBorder(isSelected ? Color.ink : .secondary.opacity(0.3),
                                                      lineWidth: isSelected ? 2 : 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(category.name)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("New") {
    ExpenseFormView(expense: nil, defaultDate: .now).modelContainer(PreviewData.container)
}

#Preview("Edit") {
    ExpenseFormView(expense: PreviewData.expense, defaultDate: .now).modelContainer(PreviewData.container)
}
