# Spendshot: PRD + rencana implementasi v1

## Context
Rizky sedang belajar iOS dan ingin langsung melihat kode SwiftUI yang production-grade dan mengikuti best practice. Project Xcode baru saja dibuat di `/Users/rizky/workspace/personal/spendshot`. Isinya masih template: `spendshot/MyApp.swift` dan `spendshot/ContentView.swift` ("Hello, world" dengan blok `#Playground`).

Project memakai format baru `project.xcproj` dengan `"kind": "folder"`. Artinya, file `.swift` baru di folder `spendshot/` otomatis ikut masuk target, tanpa perlu mengedit file project.

Keputusan dari Rizky:
- v1 berisi pencatatan manual.
- Scan struk dengan AI masuk fase berikutnya, memakai **Gemini lewat backend milik Rizky sendiri**.
- Data disimpan dengan **SwiftData lokal**.
- Platform **iPhone saja**.

## PRD (ringkas)

**Problem:** Di akhir bulan, sulit mengetahui uang habis ke mana. Mencatat pengeluaran secara manual terasa merepotkan.

**Target:** Pengguna di Indonesia. Mata uang IDR, format angka dan tanggal mengikuti locale `id_ID`.

**v1 (fase ini):**
1. Menambah pengeluaran dengan field: merchant/toko, jumlah (IDR), tanggal, kategori, dan catatan (opsional).
2. Mengedit dan menghapus pengeluaran (swipe to delete, tap untuk edit).
3. Daftar pengeluaran per bulan, dikelompokkan per hari, terbaru di atas.
4. Ringkasan bulan berjalan: total dan rincian per kategori. Bisa pindah ke bulan sebelumnya atau berikutnya.
5. Empty state memakai `ContentUnavailableView`.
6. Mendukung dark mode, Dynamic Type, dan VoiceOver (label untuk nominal).

**Fase 2 (bukan bagian dari rencana ini):** Foto struk dikirim ke backend Rizky, backend memanggil Gemini, lalu mengembalikan JSON `{merchant, total, date, category}` yang dipakai untuk mengisi form otomatis. API key Gemini **hanya disimpan di backend**, tidak pernah ditanam di app.

**Di luar scope:** akun/login, iCloud sync, budget/notifikasi, multi-mata uang, iPad/Mac.

**Kriteria sukses:** Satu pengeluaran bisa dicatat dalam waktu di bawah 10 detik. Data tetap ada setelah app ditutup dan dibuka lagi.

## Langkah 0: dokumentasi Superpowers + desain Superdesign (sebelum coding)
1. **Dokumentasi Superpowers** di dalam repo, mengikuti konvensi skill superpowers:
   - `docs/superpowers/specs/2026-11-08-spendshot-v1-design.md` berisi PRD dan arsitektur dari file ini (spec).
   - `docs/superpowers/plans/2026-11-08-spendshot-v1.md` berisi rencana implementasi yang dipecah menjadi task kecil dengan checkbox (format skill `superpowers:writing-plans`), supaya bisa dieksekusi dan dilacak per task.
   - `CLAUDE.md` di root berisi konvensi project: struktur folder, perintah build/test, aturan Decimal untuk uang, dan aturan bahwa API key tidak boleh ada di app.
2. **Superdesign**: project ini tidak punya frontend web, jadi init repo dilewati dan desain dimulai lewat jalur *brand new project*.
   - Preflight dengan `npx --yes @superdesign/cli@latest`. Kalau belum login, jalankan `login`.
   - Buat project "Spendshot" berisi mockup iPhone untuk: (a) layar daftar dan ringkasan bulanan, (b) form tambah/edit, (c) empty state. Arah visual: **pixel art** (palet terbatas, ikon 16×16/32×32, aksen font pixel untuk angka/judul), tapi struktur tetap native iOS (List, sheet, navigation) supaya nyaman dipakai. Light dan dark.
3. **Aset pixel art** (pakai asset generation Superdesign, lalu dirapikan):
   - App icon 1024×1024 bergaya pixel (struk + kamera), dimasukkan ke `Assets.xcassets/AppIcon.appiconset`.
   - Satu ikon pixel per kategori (7 buah, PNG @1x/@2x/@3x atau PDF vektor), dimasukkan ke `Assets.xcassets/Category/*.imageset` dengan **Preserve Vector Data off** dan rendering `.interpolation(.none)` di SwiftUI supaya tetap tajam saat diperbesar.
   - Ilustrasi empty state pixel (misalnya dompet kosong).
   - Font pixel open-source (misalnya *Press Start 2P* atau *Silkscreen*, lisensi OFL) hanya untuk judul dan nominal. Body text tetap SF Pro supaya mudah dibaca dan mendukung Dynamic Type. Font didaftarkan lewat `INFOPLIST_KEY_UIAppFonts`.
   - Aksesibilitas: setiap ikon pixel punya `accessibilityLabel`, dan kontras warna palet dicek (WCAG AA).
   - Jalan cadangan kalau generate gagal: pakai SF Symbols untuk ikon, gaya pixel dipertahankan lewat font dan palet saja.
   - Link canvas dibagikan ke Rizky. Setelah Rizky memilih satu arah desain, hasilnya dirangkum di `docs/superpowers/specs/...` (warna, tipografi, layout) dan menjadi acuan untuk SwiftUI.
   - Generate desain memakai kredit Superdesign. Kalau CLI gagal atau login tidak bisa, lanjut tanpa mockup dengan gaya native iOS default.

## Arsitektur
- **SwiftUI + SwiftData**, mengikuti pola bawaan Apple: `@Query` di dalam view, `@Environment(\.modelContext)` untuk menulis data. Tidak memakai ViewModel atau Repository tambahan, karena SwiftData sudah menjadi lapisan modelnya. Ini pola yang direkomendasikan Apple untuk app sebesar ini.
- Jumlah uang disimpan sebagai **`Decimal`**, bukan `Double`, supaya tidak ada error pembulatan pada uang.
- Kategori berupa `enum Category: String, Codable, CaseIterable` dengan SF Symbol dan warna untuk tiap kategori. Di model, kategori disimpan sebagai raw `String` supaya bisa dipakai untuk filter `#Predicate`.
- Filter per bulan dilakukan di `#Predicate` (rentang tanggal awal sampai akhir bulan), bukan dengan memfilter array di memori.
- Project sudah memakai Swift 6 concurrency defaults (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`). Ikuti saja default tersebut.

## File (semua di `spendshot/`)
| File | Isi |
|---|---|
| `MyApp.swift` | Ganti nama menjadi `SpendshotApp.swift`. Isinya `@main` dan `.modelContainer(for: Expense.self)` |
| `Models/Expense.swift` | `@Model final class Expense` (merchant, amount: Decimal, date, categoryRaw, note, createdAt) |
| `Models/Category.swift` | enum kategori: makan, transport, belanja, tagihan, hiburan, kesehatan, lainnya. Tiap kategori punya `iconName` (aset pixel) dan `color` dari palet |
| `Shared/Theme.swift` | Palet pixel (`Color` dari Asset Catalog, light/dark), `Font.pixel(_:)`, dan view `PixelIcon` (`Image` dengan `.interpolation(.none)`) |
| `Features/ExpenseList/ExpenseListView.swift` | Layar utama: header berisi navigasi bulan, kartu ringkasan, dan `List` yang dikelompokkan per hari. Tombol + ada di toolbar |
| `Features/ExpenseList/MonthSummaryView.swift` | Total dan bar per kategori |
| `Features/ExpenseList/ExpenseRow.swift` | Satu baris pengeluaran |
| `Features/ExpenseForm/ExpenseFormView.swift` | Satu form untuk tambah sekaligus edit, ditampilkan sebagai sheet. Ada validasi: jumlah > 0 dan merchant tidak kosong |
| `Shared/Formatting.swift` | `Decimal.FormatStyle.Currency(code: "IDR")` dengan locale `id_ID`, plus helper rentang bulan |
| `Shared/PreviewData.swift` | `ModelContainer` in-memory berisi data contoh untuk `#Preview` |
| `ContentView.swift` | Hapus. Perannya digantikan `ExpenseListView` |

Tambahkan juga target **unit test** (Swift Testing, `@Test`) untuk logika yang tidak trivial: rentang bulan (termasuk Desember ke Januari), total per kategori, dan validasi form.

## Perubahan build setting (`project.xcproj`)
- `TARGETED_DEVICE_FAMILY` menjadi `"1"`, dan `SUPPORTED_PLATFORMS` menjadi `"iphoneos iphonesimulator"` (iPhone saja).
- `PRODUCT_BUNDLE_IDENTIFIER` menjadi `id.rizkyhaksono.spendshot`.
- `IPHONEOS_DEPLOYMENT_TARGET` saat ini `27.2`. **Perlu dicek apakah iPhone 12 Rizky sudah menjalankan iOS 27.** Kalau belum, turunkan target ke versi iOS yang terpasang di HP-nya. Fitur di rencana ini hanya butuh iOS 17 ke atas.
- `SWIFT_VERSION` dinaikkan menjadi `6.0` (strict concurrency).

Catatan: format `project.xcproj` (JSON) masih baru. Edit seminimal mungkin. Kalau build gagal karena perubahan ini, ubah lewat UI Xcode saja.

## Verifikasi
1. `xcodebuild -scheme spendshot -destination 'platform=iOS Simulator,name=iPhone 17' build test` hingga build sukses dan test hijau.
2. Jalankan di Simulator: tambah 3 pengeluaran di 2 kategori, edit satu, hapus satu, cek total dan rincian kategori, pindah bulan, lalu tutup dan buka lagi app untuk memastikan data tetap ada.
3. Ambil screenshot Simulator di light dan dark mode untuk ditunjukkan ke Rizky.
4. Pastikan `#Preview` di setiap view tetap bisa dirender di canvas.
