# Spendshot

iPhone expense tracker. SwiftUI + SwiftData, local storage only. Pixel-art visual style on top of native iOS structure.

## Layout
- `spendshot/` — app target (folder-synced: new files are picked up automatically, no project edits needed)
  - `Models/` — SwiftData `@Model` types and enums
  - `Features/<Feature>/` — one folder per screen
  - `Shared/` — formatting, theme, preview data
- `spendshotTests/` — Swift Testing unit tests
- `docs/superpowers/specs/` — design specs; `docs/superpowers/plans/` — implementation plans

## Commands
```bash
xcodebuild -scheme spendshot -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -scheme spendshot -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## Rules
- Money is `Decimal`, never `Double`. Currency is IDR, locale `id_ID`.
- Use `@Query` and `@Environment(\.modelContext)` directly in views. No ViewModel/Repository layer unless a screen grows real logic.
- Month filtering happens in `#Predicate`, not in memory.
- Every view has a `#Preview` using `PreviewData.container`.
- Pixel images render with `.interpolation(.none)`; every icon has an accessibility label.
- Pixel font is only for titles and amounts; body text stays system font for Dynamic Type.
- No API keys in the app. Receipt AI (phase 2) goes through the owner's backend, which holds the Gemini key.
