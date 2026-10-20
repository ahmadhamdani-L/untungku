# UntungKu Pro

Aplikasi Android offline berbahasa Indonesia untuk UMKM: produk, stok, penjualan banyak barang, pengeluaran, kalkulator laba, dashboard, CSV, dan backup JSON. Tidak membutuhkan login atau backend. Data produksi awal kosong.

Hasil pengujian dan batas verifikasi: [docs/VERIFICATION.md](docs/VERIFICATION.md). Screenshot aplikasi: [galeri listing](docs/store-screenshots/README.md).

## Pengembangan

Gunakan Flutter **3.47.7 stable**, Dart bawaan Flutter, Java 17, dan Android SDK. Dependensi dikunci di `pubspec.lock`.

```sh
flutter pub get --enforce-lockfile
dart run build_runner build
dart format lib test integration_test
flutter analyze
flutter test
flutter run --dart-define-from-file=config/development.json
```

`lib/data/database.g.dart` disertakan supaya CI tidak perlu menjalankan generator saat build. Jalankan generator kembali setelah mengubah schema Drift.

```sh
flutter test integration_test/business_flow_test.dart -d <android-device-id>
flutter build apk --debug --dart-define-from-file=config/development.json
```

Database tersimpan di application support. Uninstall bisa menghapus semua data lokal. Ekspor backup JSON secara berkala melalui Pengaturan. Restore memvalidasi versi, referensi, UUID duplikat, dan rekonsiliasi stok sebelum transaksi database. Salinan pemulihan internal dibuat sebelum restore, namun bukan pengganti backup eksternal.

## Unduh APK dari GitHub

1. Buka repository → **Actions → Android debug APK**.
2. Pilih **Run workflow**, pilih `main` atau `develop`, lalu jalankan (push ke `main` juga memicu build).
3. Tunggu status **Success** pada commit yang diinginkan.
4. Buka run tersebut → **Artifacts → untungku-android-debug-apk**.
5. Unduh ZIP, ekstrak `app-debug.apk`, lalu instal pada perangkat Android pengujian. Android dapat meminta izin instalasi dari sumber tersebut.

Artifact disimpan 14 hari. Build wajib gagal bila file APK tidak ada. Debug APK menggunakan debug signing dan bukan rilis Play Store. Signature debug lokal dan CI bisa berbeda; ekspor backup sebelum uninstall atau berganti sumber build. Identitas signing rilis memerlukan keystore pemilik yang konsisten.

## AAB bertanda tangan

Buat environment GitHub `release` dan isi secrets:

- `ANDROID_KEYSTORE_BASE64`: file upload keystore dikodekan base64.
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Jalankan **Signed Android AAB**, centang konfirmasi. Workflow memvalidasi secrets, menjalankan analisis dan tes, membangun AAB bertanda tangan, dan menyimpan artifact 7 hari. Tidak ada keystore, password, atau token di repository. Tidak ada fallback ke debug signing. Workflow tidak mempublikasikan aplikasi ke Play. Tanpa secrets, workflow gagal dengan jelas.

## Konfigurasi iklan

`.env.example` hanya dokumentasi, **tidak otomatis dimuat Flutter**. Konfigurasi Dart menggunakan `--dart-define` atau `--dart-define-from-file`. Default `ADMOB_ENABLED=false`, `ADMOB_USE_MOCK=true`; startup tidak menginisialisasi Google SDK. `MockAdsService` menghasilkan loading/loaded/rewarded/dismissed atau failed secara deterministik tanpa koneksi iklan.

Gradle menerima `ADMOB_ANDROID_APP_ID` dari environment proses build untuk placeholder Android manifest. Default adalah ID aplikasi contoh resmi Google. Environment host tidak otomatis menjadi nilai Dart. Adapter banner/interstitial/rewarded memakai ID test resmi secara default; banner opsional berada di akhir pengaturan, dan interstitial/rewarded tidak dipasang pada alur transaksi. Adapter UMP meminta persetujuan sebelum SDK aktif dan menyediakan pilihan privasi. Integrasi iklan nyata belum diverifikasi pada perangkat. Build produksi beriklan diblokir oleh validator rilis sampai integrasi itu diverifikasi pada perangkat. Semua fitur bisnis tetap tersedia tanpa iklan.

## Branch dan verifikasi

`main` untuk hasil stabil, `develop` untuk integrasi, `feature/*` untuk pekerjaan. Perubahan digabung setelah pemeriksaan relevan lulus. Tidak menggunakan force push. CI memeriksa format, analisis, unit/widget test, dan coverage. Tes integrasi perangkat dijalankan terpisah dengan perintah di atas; tidak diklaim dijalankan oleh CI unit test.

Arsitektur, rumus, pembatalan, stok, dan batas schema ada di [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Kebijakan privasi draf: [docs/PRIVACY.md](docs/PRIVACY.md). Kesiapan Play: [docs/RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md).

## Identitas visual

Ikon pertumbuhan tiga batang adalah desain programatik asli proyek, bukan logo pihak ketiga. Jalankan `python3 tool/generate_brand.py` (Pillow diperlukan) untuk membangun ulang launcher PNG semua density, ikon store 512px, adaptive vector, dan splash hijau. UI memakai emerald, lime, Material 3, tema sistem/terang/gelap, dan ikon Material. Screenshot store harus diambil dari aplikasi berjalan, bukan gambar ilustrasi.

Mode test Google (memerlukan internet, bukan mode mock):

```sh
ADMOB_ANDROID_APP_ID='ca-app-pub-3940256099942544~3347511713' flutter run --dart-define-from-file=config/google-test.json
```

Banner hanya dimuat setelah persetujuan memungkinkan permintaan iklan. Gunakan menu pengaturan untuk penempatan test. Kegagalan iklan tidak menghalangi pencatatan bisnis. Tidak ada penempatan interstitial/rewarded otomatis pada tombol transaksi. Tidak ada klaim pendapatan dari iklan mock/test.

Kebijakan stok: default menolak penjualan jika stok tidak cukup. Pengaturan **Izinkan stok minus** memerlukan konfirmasi dan mencatat unit yang belum tersedia sebagai stok negatif. Penuhi stok tersebut sebelum menonaktifkan kebijakan ini. Backup menyimpan kebijakan dan memvalidasi saldo ledger.
