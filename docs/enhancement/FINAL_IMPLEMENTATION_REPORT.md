# UntungKu Pro v2 — laporan validasi lokal

Tanggal checkpoint: 6 November 2026 (Asia/Jakarta).

## IMPLEMENTATION SUMMARY

Implementasi software lokal mencakup pelanggan, pemasok/pembelian/penerimaan, kas/rekening, opname, retur/refund, kasir/barcode/manual, struk PDF/gambar, panel berbagi Android, Bluetooth Classic SPP ESC/POS, CSV, insight offline, PIN dan backup terenkripsi. Arsitektur Flutter Material 3/Riverpod Store/Drift dan seluruh file fitur lama dipertahankan. Dirty work v1.1.0 tetap ada; tidak ada reset, push, upload Play atau publikasi.

Printer menyediakan pilihan perangkat berpasangan, izin CONNECT, batas waktu socket 15 detik, profil teks 58/80 mm, uji cetak dan retry dengan peringatan kemungkinan cetak parsial. Retry tidak memposting transaksi. Kompatibilitas printer fisik belum dibuktikan.

CSV UI memakai callback compute top-level agar tidak menangkap state Riverpod. Pratinjau, pembatalan dan commit diuji. Insight tetap deterministik/offline dengan penjelasan periode dan snooze. Beranda memakai cash ledger untuk penerimaan, serta menambahkan utang pemasok dan tautan insight.

## DATABASE

Drift schema 2 additive; fixture schema 1 dan snapshot migrasi dipertahankan. Regression mencakup upgrade/reopen database representatif, historical sale snapshots, rollback, idempotensi serta backup legacy v1/v2. Payload baru v3 terpisah dari encrypted envelope v1. Tidak ada migrasi baru untuk PIN: verifikator tidak masuk database usaha atau backup. Uang tetap integer Rupiah, tarif basis points, pembayaran parsial bukan pendapatan baru, pembelian bukan pengeluaran operasional dan transfer bukan pemasukan.

## VALIDATION

| Pemeriksaan | Hasil dieksekusi |
| --- | --- |
| Formatter | 92 file, tidak ada perubahan pada run penutup |
| Flutter analyzer | Bersih, no issues |
| Full unit/widget/database regression | 128 lulus, 4 skip adapter live pada konfigurasi offline |
| Adapter consent wajib dengan ADMOB_ENABLED=true / ADMOB_USE_MOCK=false | 4 lulus; skip offline tercakup oleh run ini |
| Native Android legacy flow + scanner/manual exit + v2 financial/crypto/secure-storage | 4 lulus |
| Native Android PDF/PNG share cancellation + save PDF | 1 lulus; host helper membatalkan panel, tidak memilih penerima |
| Native Google sample ads | 2 lulus: banner setelah UMP dan preload interstitial tanpa tampil saat startup |
| Layout 320/360/1024, light/dark, teks 1.3x | 6 lulus |
| Accessibility beranda | Label, target sentuh Android, kontras terang/gelap lulus |
| Interaksi keamanan | Setup PIN aktual, konfirmasi/recovery acknowledgement, idle/background, aktivitas keyboard, dialog password mismatch/accept/cancel lulus |
| Python release configuration tests | 4 lulus |
| APK/AAB signed lokal dan pemeriksaan artefak | Lulus; upload certificate, identity/SDK/permissions/config cocok |

Perangkat native: emulator Untungku_Test, Android API 37 / arm64-v8a. Tidak ada klaim pengujian kamera/printer fisik atau perangkat Android murah.

Benchmark read-path sintetis memakai 1.000 produk, 10.000 mutasi, 300 pelanggan, 100 pemasok. Run host 10.000 penjualan: load 107 ms, insight 175 ms, RSS 232 MiB; host 50.000: 270 ms / 662 ms / 278 MiB. Emulator 10.000: 131 ms / 236 ms / 436 MiB. Ini fixture in-memory untuk pembacaan, bukan benchmark financial posting atau jaminan perangkat fisik. Detail dan keterbatasan di IMPLEMENTATION_NOTES.md.

Log final disalin ke `build/v2-validation/logs/`, metadata/hash di `build/v2-validation/artifacts.json`. Run terdahulu yang gagal saat penyempurnaan UI atau konflik native-asset tidak dihitung sebagai pass; hasil penutup di atas sudah dieksekusi ulang dan lulus.

## SECURITY

Lihat SECURITY_DESIGN.md. PIN 4–6 digit, salted PBKDF2-HMAC-SHA256 600k, secure storage resetOnError=false, lockout persisten, verifikasi perubahan/nonaktif. Root gate menutup seluruh navigator dan mengunci saat idle/background. Guard generasi mencegah verifikasi yang selesai terlambat melewati lock baru; aktivitas keyboard lunak ikut memperbarui timer. Tidak ada PIN plaintext, bypass atau penghapusan otomatis.

Backup memakai cryptography AES-256-GCM, salt/nonce acak unik, PBKDF2 600k dan password 12–256 karakter dengan konfirmasi. Autentikasi dilakukan sebelum parsing record/restore. Wrong password, tag tamper, metadata KDF rusak, restore atomik dan legacy backup diuji. PIN tidak mengenkripsi database. Backup JSON biasa dan recovery snapshot privat tidak terenkripsi; kebijakan pemulihan dijelaskan sebelum mengaktifkan PIN. Plugin/OS mengelola umur cache lampiran berbagi; cipher tidak menulis temporary plaintext/password files.

## ADMOB

`config/admob-release.json` tetap tidak berubah. Semua development/integration memakai mode offline atau Google sample units. UMP, preload-only completion boundary, foreground gating, caps dan cooldown tetap diuji. Release final berisi production App ID dan banner/interstitial sesuai profil eksplisit; konfigurasi unit lainnya dipertahankan. Unit yang tidak dipakai dapat di-tree-shake. Release tidak memuat IntegrationTestPlugin atau folder fixture test.

## RELEASE

Package `id.untungku.untungku_pro`, min SDK 24, target/compile SDK 36, certificate upload lama cocok untuk APK dan AAB. Kamera/Bluetooth tetap opsional; legacy Bluetooth permission dibatasi SDK 30, CONNECT runtime tersedia. Android app backup tetap nonaktif.

**Belum siap publikasi v2.** Sumber/artefak tetap `1.1.0+5` karena kode versi baru yang belum digunakan pada riwayat Play aktual belum terkonfirmasi. Artefak berikut untuk validasi lokal dan tidak boleh dianggap update Play baru. Tidak ada upload/push/publication.

- `build/v2-validation/untungku-v2-local.apk` — 91,426,518 bytes; SHA-256 `f023416c79ce896c2e9bb001453171599a18766d7283847eabdde30d22d40537`.
- `build/v2-validation/untungku-v2-local.aab` — 84,053,871 bytes; SHA-256 `85bc80fe7238ea7910369aa1dcedd19912f4db577a111548dedf89e048b66d11`.

Source digest: `b7ba912ffbc4e2a48da198344ae96494cf6c80f2ab03822e90ce2939fefe89e1` (lihat verifier untuk daftar input).

Tool lokal: `tool/build_signed_aab.py --format both`; `tool/verify_local_artifacts.py` memeriksa signature/certificate, manifest, APK/AAB version agreement, metadata AdMob serta unit aktif dan kebocoran dev plugin. Gradle 8.14 / AGP 8.11.1 / Kotlin 2.2.20 memberi peringatan dukungan Flutter mendatang; build saat ini berhasil. Tidak ada upgrade toolchain spekulatif pada tugas ini.

## NEXT STEPS / BLOCKERS

1. POS-002: pemindaian barcode nyata pada kamera Android fisik, termasuk izin/offline dan pengenalan barcode; emulator/manual fallback tidak membuktikannya.
2. RCP-004 dan cakupan fisik QA-005: cetak 58/80 mm pada printer Classic SPP ESC/POS nyata, putus koneksi/timeout, periksa teks dan retry tanpa duplikasi penjualan. Printer BLE/vendor lain tidak diklaim didukung.
3. REL-007: konfirmasi riwayat Play aktual untuk kode versi monoton berikutnya; baru tetapkan versionName/versionCode v2 dan jalankan kembali validasi lokal yang terkait. Publikasi tetap tidak diotorisasi.

Checkbox yang belum memiliki bukti tetap terbuka di TASKS.md. Implementasi/validasi yang dapat dijalankan lokal sudah selesai; penerimaan hardware dan readiness rilis keseluruhan belum selesai.
