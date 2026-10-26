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

Build source `0597f97` sudah berhasil dan artifact APK terkonfirmasi: [buka hasil build](https://github.com/ahmadhamdani-L/untungku/actions/runs/39417669228). Rincian ukuran/hash dan masa berlaku ada di [bukti build](docs/build-verification.json).

1. Buka repository → **Actions → Android debug APK**.
2. Pilih **Run workflow**, pilih `main` atau `develop`, lalu jalankan (push ke `main` juga memicu build).
3. Tunggu status **Success** pada commit yang diinginkan.
4. Buka run tersebut → **Artifacts → untungku-android-debug-apk**.
5. Unduh ZIP, ekstrak `app-debug.apk`, lalu instal pada perangkat Android pengujian. Android dapat meminta izin instalasi dari sumber tersebut.

Artifact disimpan 14 hari. Build wajib gagal bila file APK tidak ada. Debug APK menggunakan debug signing dan bukan rilis Play Store. Signature debug lokal dan CI bisa berbeda; ekspor backup sebelum uninstall atau berganti sumber build. Identitas signing rilis memerlukan keystore pemilik yang konsisten.

## AAB bertanda tangan

AAB lokal kode versi 2, source `dea7489` berhasil dibangun dan diverifikasi: [hasil AAB](docs/aab-verification.json), [konfigurasi dan batas verifikasi](docs/ADMOB_RELEASE.md). Profil owner memakai App ID dan banner pemilik; live serving serta publikasi Play belum diverifikasi. GitHub App belum mendapat akses Actions Secrets (403), sehingga AAB remote belum dijalankan.

Buat environment GitHub `release` dan isi secrets:

- `ANDROID_KEYSTORE_BASE64`: file upload keystore dikodekan base64.
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Jalankan **Signed Android AAB**, centang konfirmasi. Pilih profil `offline`, `google-test`, atau `owner` (ID AdMob pemilik; perlu centang `confirm_owner_ads`). Workflow memvalidasi secrets dan profil, menjalankan analisis dan tes, membangun AAB bertanda tangan, dan menyimpan artifact 7 hari. Tidak ada keystore, password, atau token di repository. Tidak ada fallback ke debug signing. Workflow dapat mempublikasikan ke Play jika `publish_to_play` diaktifkan dan secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` tersedia; pilih `play_track` yang sesuai. Tanpa secrets, workflow gagal dengan jelas.

## Konfigurasi iklan

`.env.example` hanya dokumentasi, **tidak otomatis dimuat Flutter**. Konfigurasi Dart menggunakan `--dart-define` atau `--dart-define-from-file`. Default `ADMOB_ENABLED=false`, `ADMOB_USE_MOCK=true`; startup tidak menginisialisasi Google SDK. `MockAdsService` menghasilkan loading/loaded/rewarded/dismissed atau failed secara deterministik tanpa koneksi iklan.

Gradle menerima `ADMOB_ANDROID_APP_ID` dari environment proses build untuk placeholder Android manifest. Default adalah ID aplikasi contoh resmi Google. Environment host tidak otomatis menjadi nilai Dart. Adapter banner/interstitial/rewarded memakai ID test resmi secara default; banner otomatis berada di atas navigasi utama, dan interstitial/rewarded tidak dipasang pada alur transaksi. Adapter UMP meminta persetujuan sebelum SDK aktif dan menyediakan pilihan privasi. Integrasi iklan nyata belum diverifikasi pada perangkat. Profil owner sekarang tersedia atas permintaan pemilik; penggunaannya memerlukan konfirmasi eksplisit pada workflow. Live serving dan pesan consent akun pemilik tetap perlu verifikasi sebelum publikasi. Semua fitur bisnis tetap tersedia tanpa iklan.

## Branch dan verifikasi

`main` untuk hasil stabil, `develop` untuk integrasi, `feature/*` untuk pekerjaan. Perubahan digabung setelah pemeriksaan relevan lulus. Tidak menggunakan force push. CI memeriksa format, analisis, unit/widget test, dan coverage. Tes integrasi perangkat dijalankan terpisah dengan perintah di atas; tidak diklaim dijalankan oleh CI unit test.

Arsitektur, rumus, pembatalan, stok, dan batas schema ada di [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Kebijakan privasi: [docs/PRIVACY.md](docs/PRIVACY.md). Kesiapan Play: [docs/RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md).

## Identitas visual

Ikon pertumbuhan tiga batang adalah desain programatik asli proyek, bukan logo pihak ketiga. Jalankan `python3 tool/generate_brand.py` (Pillow diperlukan) untuk membangun ulang launcher PNG semua density, ikon store 512px, adaptive vector, dan splash hijau. UI memakai emerald, lime, Material 3, tema sistem/terang/gelap, dan ikon Material. Screenshot store harus diambil dari aplikasi berjalan, bukan gambar ilustrasi.

Mode test Google (memerlukan internet, bukan mode mock):

```sh
ADMOB_ANDROID_APP_ID='ca-app-pub-3940256099942544~3347511713' flutter run --dart-define-from-file=config/google-test.json
```

Banner hanya dimuat setelah persetujuan memungkinkan permintaan iklan. Banner test dimuat otomatis di layar utama. Kegagalan iklan tidak menghalangi pencatatan bisnis. Tidak ada penempatan interstitial/rewarded otomatis pada tombol transaksi. Tidak ada klaim pendapatan dari iklan mock/test.

Kebijakan stok: default menolak penjualan jika stok tidak cukup. Pengaturan **Izinkan stok minus** memerlukan konfirmasi dan mencatat unit yang belum tersedia sebagai stok negatif. Penuhi stok tersebut sebelum menonaktifkan kebijakan ini. Backup menyimpan kebijakan dan memvalidasi saldo ledger.

Konfigurasi ID AdMob pemilik, penempatan yang tersedia, signing lokal dan kebutuhan izin GitHub: [docs/ADMOB_RELEASE.md](docs/ADMOB_RELEASE.md). Laporan APK sebelumnya merekam source lama; hasil AAB terbaru dicatat terpisah.

Baru membuat aplikasi di Play Console? Lihat [panduan upload pertama dan nama paket](docs/PLAY_FIRST_UPLOAD.md).

Kebijakan privasi publik: https://ddd-dream-develop-digital.vercel.app/untungku-pro/privacy/ (juga dapat dibaca offline dari Pengaturan). Versi 1.0.0 kode 2 menyertakan identitas dan kontak pengelola yang sama.

Panduan semua urutan Dasbor Play Console dan teks listing siap salin: [docs/PLAY_CONSOLE_SETUP_ID.md](docs/PLAY_CONSOLE_SETUP_ID.md).

Perbaikan pemuatan banner versi 1.0.1 dan kebutuhan rilis dari Windows: [docs/ADS_FIX_RELEASE.md](docs/ADS_FIX_RELEASE.md).
