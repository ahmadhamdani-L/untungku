# Verifikasi UntungKu Pro

Tanggal pemeriksaan akhir: 20 Oktober 2026. Source aplikasi: `0597f974ee436ac9f4fabb4947737c4f34ff835e`. Commit dokumentasi sesudahnya tidak mengubah aplikasi.

## A — Sudah diterapkan dan diverifikasi

- Flutter 3.47.7 / Dart 3.13.5; Java 17; Android minimum API 24, target 36.
- Format Dart dan analisis statis bersih; **33 unit/widget test lulus**, termasuk hitungan uang, transaksi atomik, pembatalan, stok, restore, persistensi, iklan mock, kirim formulir berulang, dan perubahan kategori produk.
- **1 integration test Android lulus** pada emulator ARM64 dalam mode pesawat: alur bisnis offline, pencatatan dan perubahan data. Tes perangkat terpisah dari unit test CI.
- Ekspor JSON dan CSV melalui pemilih berkas Android, pembacaan kembali format, serta restore JSON lewat konfirmasi native diuji manual. Preferensi tema bertahan setelah aplikasi dihentikan dan dibuka kembali.
- APK debug aplikasi normal dibangun setelah tes integrasi dan lolos `apksigner verify`. SHA-256 lokal: `658a4dc2a7c93af3ccb841bcd13f55017896082781bcbf1c3f9a4aafcfc7ab79`; ukuran 216616737 byte. Nama salinan: `UntungKu-Pro-1.0.0-debug-0597f97.apk`.
- Produk, penjualan banyak barang, pengeluaran, ledger stok, laporan, kalkulator, CSV, backup/restore, onboarding dan tema tersedia tanpa login/backend. Data bisnis produksi awal kosong. Contoh kalkulator pada screenshot hanya simulasi.
- Stok minus default ditolak; pengaktifan membutuhkan konfirmasi. Penonaktifan ditolak selama saldo negatif. Pengujian mencakup saldo ledger dan kebijakan pada restore.
- Screenshot diambil dari UI Android berjalan; lihat direktori screenshot beserta keterangannya. Ikon asli proyek dihasilkan secara programatik.
- Validator rilis diuji: konfigurasi signing yang kosong dan pengaktifan iklan produksi sama-sama ditolak sesuai pengaman. Ini bukan bukti AAB bertanda tangan telah dibangun.
- Referensi build GitHub dan artifact dicatat di `build-verification.json`. Hash ZIP artifact GitHub berbeda objek dari hash APK lokal; keduanya tidak dianggap identik.

## B — Belum diverifikasi

- AAB rilis dengan upload keystore milik pemilik; penerimaan dan publikasi Google Play.
- Permintaan Google test/live ads, persetujuan UMP dan pilihan privasi pada perangkat. Default iklan mati/mock; validator menolak produksi beriklan sampai verifikasi tersebut selesai.
- Perangkat fisik berbagai vendor, audit TalkBack menyeluruh, beban data besar, dan migrasi dari versi produksi sebelumnya. Restore membatasi JSON hingga 20 MB.

## C — Tindakan pemilik untuk rilis Play

1. Simpan upload keystore dan isi empat secrets pada environment GitHub `release`, sesuai README; jalankan workflow Signed Android AAB. Jangan kirim kunci melalui chat atau commit.
2. Lengkapi kontak pemilik dan URL kebijakan privasi publik, deklarasi data/iklan, listing, serta persyaratan pengujian akun Play yang berlaku.
3. Bila mengaktifkan iklan, sediakan konfigurasi AdMob dan verifikasi test ads/UMP pada perangkat sebelum mengubah pengaman produksi.

APK debug sudah dapat diuji tanpa langkah rilis Play tersebut. Signature debug lokal dan CI dapat berbeda: ekspor backup sebelum uninstall atau berganti sumber build. Rilis produksi memerlukan identitas signing konsisten.

## D — Rekomendasi berikutnya

Uji perangkat fisik dan volume data realistis; cadangkan data secara berkala. Rencanakan pembaruan Gradle/AGP/Kotlin dengan pengujian ulang karena Flutter memberi peringatan dukungan versi mendatang. Toolchain saat ini berhasil membangun APK; pembaruan itu tidak dipaksakan pada hasil terverifikasi ini.
