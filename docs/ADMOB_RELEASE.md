# Konfigurasi AdMob dan AAB

Profil `config/admob-release.json` memuat ID publik pemilik:

| Jenis | ID | Penempatan saat ini |
| --- | --- | --- |
| Aplikasi Android | `ca-app-pub-6953774620667597~7700178927` | Metadata manifest saat build profil owner |
| Banner | `ca-app-pub-6953774620667597/7589954559` | Akhir Pengaturan, setelah UMP mengizinkan |
| Interstisial | `ca-app-pub-6953774620667597/9420454707` | Adapter tersedia, belum ada pemicu UI |
| Rewarded | `ca-app-pub-6953774620667597/3650709544` | Adapter tersedia, belum ada pemicu/reward produk |
| Native | `ca-app-pub-6953774620667597/8813950043` | Dicatat; belum diimplementasikan |
| Pembukaan aplikasi | `ca-app-pub-6953774620667597/3753195059` | Dicatat; belum diimplementasikan |

ID `3650709544` ditetapkan rewarded dari jenis “Iklan Reward” yang dikirim pemilik, meskipun nama unit tertulis “Native advanced”. Jenis unit di AdMob harus benar-benar rewarded. Unit native tidak dapat dipakai sebagai rewarded.

Memberikan ID tidak otomatis mengaktifkan seluruh format iklan. Tidak ada iklan layar penuh saat menyimpan transaksi, ekspor, restore, atau membuka aplikasi. Banner gagal/UMP menolak tidak memblokir fitur usaha. Pilihan privasi ditampilkan jika diwajibkan UMP, terlepas dari keberhasilan banner. Perubahan pilihan membuang banner lama.

Default pengembangan/debug CI tetap offline/mock. Profil owner secara eksplisit mengaktifkan Google SDK dengan unit pemilik; ini bukan klaim live serving, pendapatan, atau persetujuan Play. Tinjau pesan Privacy & messaging AdMob, status aplikasi/unit, persetujuan wilayah, kebijakan privasi, dan Data safety sebelum publikasi. Menghapus AD_ID dari manifest tidak berarti SDK tidak memproses data lainnya.

## Build lokal bertanda tangan

Upload key dibuat atas persetujuan pemilik untuk aplikasi yang belum pernah diunggah. Material signing berada di luar Git; salinan privat di `~/Downloads/UntungKu-Pro-upload-key-backup`. Simpan salinan aman untuk pembaruan. Jangan membuat ulang key untuk setiap build.

```sh
python3 tool/build_signed_aab.py \
  --credentials "$HOME/.local/share/untungku-pro/signing/credentials.json" \
  --owner-ads
```

Tanpa `--owner-ads`, build memakai profil offline. Script menyuplai app ID ke Gradle dan unit ID ke Dart dari profil yang sama. `.env.example` tetap hanya dokumentasi. AAB bukan APK yang dapat dipasang langsung.

## Build GitHub

Environment `release` membutuhkan `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. GitHub App yang digunakan saat ini mendapat **403** untuk API Actions Secrets. Owner dapat memberi GitHub App permission **Secrets: Read and write**, menyetujui permission baru pada installation, atau mengisi secrets sendiri di Settings → Environments → release. Jangan tempel password/key ke chat.

Workflow Signed Android AAB: centang `confirm_signed_build`; pilih `ad_profile=owner`; centang `confirm_owner_ads`. Profil offline dan Google test juga tersedia. Workflow memvalidasi profil/signing, membangun AAB, mengunggah artifact, dan tidak mempublikasikan ke Play.

## Pemeriksaan perangkat dengan Google test IDs

```sh
ADMOB_ANDROID_APP_ID='ca-app-pub-3940256099942544~3347511713' \
flutter test integration_test/google_ads_test.dart -d emulator-5554 \
  --dart-define-from-file=config/google-test.json
```

Tes meminta banner Google contoh sesudah UMP; tidak memakai ID produksi pemilik. Tidak mengeklik iklan. Catat hasil sebenarnya di laporan AAB; kegagalan jaringan/konfigurasi consent tidak boleh dilaporkan sebagai lulus.

Referensi diperiksa 20 Oktober 2026: [Google UMP](https://developers.google.com/admob/flutter/privacy), [Google test ads](https://developers.google.com/admob/flutter/test-ads), [Flutter Android signing](https://docs.flutter.dev/deployment/android).

## Hasil build lokal terverifikasi — 20 Oktober 2026

Source `6c87a28`: Flutter `build appbundle --release` selesai dengan exit code 0; AAB release ditandatangani upload key baru, cocok dengan sertifikat key tersebut, dan lolos `jarsigner verify` serta `bundletool 1.18.3 validate`. Package dan App ID AdMob pemilik diperiksa di manifest; banner ID pemilik diperiksa pada kode ARM64. Delapan library native 64-bit memiliki ELF LOAD alignment minimal 16 KB.

Salinan: `~/Downloads/UntungKu-Pro-1.0.0-release-6c87a28.aab`. Hash, ukuran dan fingerprint publik ada di [aab-verification.json](aab-verification.json). Tidak ada kunci privat/password di repository.

33 unit/widget test, empat tes pengaman release, dan satu tes perangkat Google test banner/UMP lulus. Live serving unit pemilik, formulir consent wilayah EEA, dan penerimaan Play belum diverifikasi. AAB ini dibuat lokal; tidak diklaim sebagai artifact AAB GitHub. CI main dan build APK debug GitHub source yang sama sudah berhasil.

Dua hambatan lokal diselesaikan: menjalankan pub saat build untuk membersihkan registrasi plugin integration test dari release, serta memasang Android command-line tools resmi yang dibutuhkan Flutter untuk memeriksa debug symbols. APK debug arsip tidak digunakan sebagai AAB release.

Kebijakan privasi kini tersedia di https://ddd-dream-develop-digital.vercel.app/untungku-pro/privacy/ setelah persetujuan publikasi pemilik; HTTP 200 dan konten HTML publik diperiksa. Pengelola PT DDD DREAM DEVELOP DIGITAL, pengembang Lelouch D, email publik hmdhmdndani@gmail.com. Source website commit `6b30138` pada repo `ddd-dream-develop-digital`. Kontak khusus Google tidak dimasukkan. Nama paket saat setup Play adalah **`id.untungku.untungku_pro`**. AAB kode versi 2 menyertakan kebijakan yang sama dalam aplikasi untuk akses offline. Hasil build berikutnya dicatat di `aab-verification.json`.
