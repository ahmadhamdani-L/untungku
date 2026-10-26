# Perbaikan iklan 1.0.1 (kode versi 3)

Banner dimuat otomatis setelah layar utama tampil, di atas navigasi. Tombol pilihan privasi hanya ada di Pengaturan saat diwajibkan UMP. Consent form tetap ditampilkan jika diwajibkan Google; tombol privasi bukan pemicu iklan. Tidak ada pemaksaan wilayah debug pada profil owner.

SDK dan alur consent dibagi untuk satu sesi aplikasi. Bila pembaruan consent gagal, izin valid sesi sebelumnya tetap diperiksa melalui `canRequestAds()`. SDK tidak dimulai bila izin tersebut belum tersedia. Banner gagal dimuat dicoba ulang setelah 30, 60, lalu maksimum 120 detik; kembali ke aplikasi juga mencoba ulang. Banner lama dibuang sebelum pengguna mengubah consent. Banner baru dimuat sesudah formulir ditutup. Timer dibatalkan ketika widget dibuang atau aplikasi masuk latar belakang.

`No fill` (kode 3) berarti permintaan iklan tidak mendapat inventaris dari Google. Perbaikan kode tidak menjamin unit produksi selalu terisi. Jangan mengganti unit produksi dengan test ID untuk memperoleh pendapatan.

## Pengujian dan build

```sh
flutter analyze
flutter test
flutter test test/ads_consent_test.dart --dart-define=ADMOB_ENABLED=true --dart-define=ADMOB_USE_MOCK=false
```

Workflow **Android debug APK** kini menerima `ad_profile=google-test` untuk membuat APK dengan unit contoh Google tanpa upload key. Artifact ini untuk pengujian; signature debug berbeda dari aplikasi Play. Workflow push tetap menggunakan profil offline.

## Rilis melalui GitHub dari Mac atau Windows

Pemeriksaan 26 Oktober 2026: repository secrets kosong dan environment `release` belum ditemukan. Upload key sebelumnya berada di Mac pemilik dan tidak tersedia di workspace Windows. Tidak membuat upload key baru.

Masukkan secrets berikut melalui GitHub Settings → Environments → release (atau repository Actions secrets):

- `ANDROID_KEYSTORE_BASE64`: base64 dari upload keystore yang sama dengan rilis sebelumnya.
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: isi JSON service account yang memiliki izin rilis aplikasi `id.untungku.untungku_pro` di Play Console.

Jangan commit file keystore atau JSON kredensial. Gunakan nilai asli dari Mac; tidak perlu memindahkannya ke chat. Pastikan kode versi 3 lebih tinggi dari semua bundle yang sudah diunggah sebelum rilis; naikkan lagi jika diperlukan.

Jalankan **Signed Android AAB** dengan `confirm_signed_build=true`, `ad_profile=owner`, `confirm_owner_ads=true`. Untuk publikasi aktifkan `publish_to_play=true` dan pilih `play_track=internal` atau `production`. Build menjalankan tes, membuat bundle bertanda tangan dan menyimpan artifact sebelum upload Play. Tanpa signing atau kredensial Play, validasi gagal sebelum build. Proses review dan ketersediaan pengguna tetap ditentukan Google Play.

Referensi: [Google UMP Flutter](https://developers.google.com/admob/flutter/privacy), [upload-google-play action](https://github.com/r0adkll/upload-google-play).

## Hasil verifikasi 26 Oktober 2026

Source aplikasi `73cb7b32b1b705575f8f456e20f1ceab00eebdff`: format dan analisis bersih; 35 tes aplikasi, 3 tes adapter consent/retry dengan respons platform simulasi, serta 4 tes pengaman rilis lulus. [CI GitHub](https://github.com/ahmadhamdani-L/untungku/actions/runs/40345091172) juga berhasil.

[Build APK Google test](https://github.com/ahmadhamdani-L/untungku/actions/runs/40345140977) berhasil. Artifact `untungku-android-debug-apk-google-test`, ID `12661053435`, ZIP 92660787 byte, tersedia selama 14 hari. Ini debug APK dengan test IDs, bukan AAB produksi atau bukti live serving unit pemilik. Pengujian banner produksi pada perangkat dan upload versi ini ke Play belum selesai.

Sesi Chrome Windows berhasil mengakses akun developer dan menemukan aplikasi `id.untungku.untungku_pro` pada daftar produksi. Akses Console tidak menyediakan private upload key yang tersimpan di Mac. Jika key lama tidak dapat diakses, Google menyediakan reset upload key melalui pengaturan Play App Signing; sesudah reset berlaku, key lama tidak dapat digunakan untuk upload berikutnya. [Prosedur resmi Google](https://support.google.com/googleplay/android-developer/answer/9842756?hl=en). Belum mengajukan reset atau mengubah secrets signing.
