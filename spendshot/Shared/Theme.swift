import CoreText
import SwiftUI

extension Color {
    static let ink = Color("Palette/ink")
    static let paper = Color("Palette/paper")
    static let accentPixel = Color("Palette/accent")
}

/// Registers the bundled font once, on first use. Works in the app and in #Preview without Info.plist edits.
private let pixelFontRegistered: Void = {
    guard let url = Bundle.main.url(forResource: "Silkscreen-Regular", withExtension: "ttf") else {
        assertionFailure("Silkscreen-Regular.ttf missing from bundle")
        return
    }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
}()

extension Font {
    /// Pixel display font for titles and amounts. Scales with Dynamic Type via `relativeTo`.
    static func pixel(_ size: CGFloat, relativeTo style: TextStyle = .body) -> Font {
        _ = pixelFontRegistered
        return .custom("Silkscreen-Regular", size: size, relativeTo: style)
    }
}

/// Crisp pixel-art image: no smoothing when scaled.
struct PixelIcon: View {
    let name: String
    var size: CGFloat = 28
    var label: String

    var body: some View {
        Image(name)
            .resizable()
            .interpolation(.none)
            .frame(width: size, height: size)
            .accessibilityLabel(label)
    }
}

/// Hard-edged "pixel" card: square corners, offset shadow, 2pt border.
struct PixelCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.paper)
            .overlay(Rectangle().strokeBorder(Color.ink, lineWidth: 2))
            .background(Color.ink.offset(x: 4, y: 4))
    }
}

extension View {
    func pixelCard() -> some View { modifier(PixelCard()) }
}
