# Spendshot design system

## Product
iPhone expense tracker for Indonesian users (IDR, Bahasa Indonesia UI). Job: "log a purchase in under 10 seconds, see where my money went this month."
Screens: (1) monthly list + summary, (2) add/edit expense sheet, (3) empty state. Phase 2 adds receipt photo scan.

## Style: pixel art on native iOS structure
- Native iOS skeleton: navigation bar with month title, grouped inset list, bottom sheet forms, SF Pro body text.
- Pixel accents: hard square corners on custom cards, 2px solid ink borders, 4px offset solid shadow (no blur), 16x16 pixel icons scaled with nearest-neighbor, Silkscreen pixel font ONLY for "TOTAL" labels and money amounts (uppercase).
- No gradients, no glassmorphism, no soft blurred shadows on custom elements.

## Color tokens (light / dark)
- ink #1B1B2F / #F2E9D8 (borders, offset shadow, primary text on cards)
- paper #FFF8E7 / #23233A (summary card background)
- accent #FF6B4A / #FF8466 (tint, primary buttons)
- background: iOS grouped background (#F2F2F7 / #000000)
- Categories: food #FF9F1C, transport #2EC4B6, shopping #E71D73, bills #3A86FF, entertainment #8338EC, health #06D6A0, other #8D99AE. Used for icon tile tint (25% opacity), stacked bar segments, legend squares.

## Typography
- Body: SF Pro (system), Dynamic Type sizes.
- Display: Silkscreen 28pt for monthly total, 13pt for row amounts, 11pt for "TOTAL" label.
- Money format: "Rp45.000" (id_ID).

## Components
- Summary card: paper background, 2px ink border, 4px ink offset shadow; TOTAL label, big pixel amount, 12px stacked category bar with ink border, legend rows (color square, name, amount).
- Expense row: 40px pixel icon tile tinted by category, merchant (semibold), optional note (caption, secondary), amount right-aligned in pixel font.
- Day section header: "Minggu, 8 November".
- Category picker: 4-column grid of square tiles (pixel icon + label); selected = category tint 35% + 2px ink border.
- Empty state: 64px pixel wallet, title "Belum ada pengeluaran", hint, accent capsule button "Tambah pengeluaran".

## Motion
Default iOS sheet and list animations only. No custom motion.
