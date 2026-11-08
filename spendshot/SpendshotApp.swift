import SwiftData
import SwiftUI

@main
struct SpendshotApp: App {
    var body: some Scene {
        WindowGroup {
            ExpenseListView()
                .tint(.accentPixel)
                .environment(\.locale, .app)
                #if DEBUG
                .modifier(DebugSeed())
                #endif
        }
        .modelContainer(for: Expense.self)
    }
}
