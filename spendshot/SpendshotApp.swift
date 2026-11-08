import SwiftData
import SwiftUI

@main
struct SpendshotApp: App {
    var body: some Scene {
        WindowGroup {
            ExpenseListView()
                .tint(.accentPixel)
                .environment(\.locale, .app)
        }
        .modelContainer(for: Expense.self)
    }
}
