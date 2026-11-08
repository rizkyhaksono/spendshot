import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case food, transport, shopping, bills, entertainment, health, other

    var id: Self { self }

    var name: String {
        switch self {
        case .food: "Makan"
        case .transport: "Transport"
        case .shopping: "Belanja"
        case .bills: "Tagihan"
        case .entertainment: "Hiburan"
        case .health: "Kesehatan"
        case .other: "Lainnya"
        }
    }

    /// Pixel image in Assets.xcassets/Category.
    var iconName: String { "Category/\(rawValue)" }

    var color: Color { Color("Palette/\(rawValue)") }
}
