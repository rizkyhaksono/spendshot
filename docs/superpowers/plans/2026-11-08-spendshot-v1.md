# Spendshot v1 Implementation Plan

**Goal:** Manual expense tracking with monthly summary, pixel-art style, iPhone only.
**Spec:** `docs/superpowers/specs/2026-11-08-spendshot-v1-design.md`
**Stack:** SwiftUI, SwiftData, Swift Testing.

## Tasks

- [x] **1. Docs** — spec, this plan, `CLAUDE.md`.
- [ ] **2. Design** — Superdesign mockups: list + summary, add/edit form, empty state (pixel art, light/dark).
- [ ] **3. Assets** — pixel app icon, 7 category icons, empty-state illustration, palette colors in Asset Catalog, pixel font (OFL).
- [x] **4. Models** — `Expense` (`@Model`, `Decimal` amount), `Category` enum.
- [x] **5. Shared** — `Formatting` (IDR currency, month range), `Theme` (palette, pixel font, `PixelIcon`), `PreviewData`.
- [x] **6. List screen** — `ExpenseListView` with month navigation, `MonthSummaryView`, `ExpenseRow`, day grouping, swipe to delete, empty state.
- [x] **7. Form** — `ExpenseFormView` for add + edit, validation (amount > 0, merchant not empty).
- [x] **8. App entry** — `SpendshotApp` with `.modelContainer(for: Expense.self)`; delete `ContentView`.
- [x] **9. Build settings** — iPhone only, bundle id, deployment target matching the owner's iPhone.
- [x] **10. Tests** — month range (incl. Dec→Jan), category totals, form validation.
- [x] **11. Verify** — build + test via `xcodebuild`, run in Simulator, screenshots light/dark.

## Phase 2 (not in this plan)
Receipt photo → owner's backend → Gemini → JSON `{merchant, total, date, category}` → prefilled form.
