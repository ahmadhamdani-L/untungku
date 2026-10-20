# Panduan seluruh penyiapan Play Console — UntungKu Pro

Diperiksa 20 Oktober 2026. Akun pemilik Organisasi terverifikasi. Dokumen ini memandu pengisian; tidak berarti deklarasi sudah dikirim atau aplikasi disetujui Google.

## Urutan dasbor

Mulai dari Menyiapkan aplikasi → Memberi tahu kami konten aplikasi Anda. Maksimal 100 penguji internal adalah kapasitas, bukan jumlah wajib. Pengujian internal, tertutup, terbuka dan prapendaftaran bukan empat tahapan yang semuanya harus dijalankan. Aturan 12 penguji/14 hari khusus akun pribadi baru tidak berlaku untuk jenis akun Organisasi terverifikasi ini. Tetap lakukan pengujian yang memadai dan penuhi tugas yang ditampilkan akun.

1. Kebijakan privasi: https://ddd-dream-develop-digital.vercel.app/untungku-pro/privacy/.
2. Detail login/Akses aplikasi: semua fungsi tersedia tanpa pembatasan akses. Tidak ada login, OTP atau membership untuk peninjau.
3. Iklan: Ya, aplikasi berisi iklan. AAB owner memakai banner AdMob.
4. Rating konten: email hmdhmdndani@gmail.com, kategori aplikasi umum/lainnya jika tersedia. Aplikasi tidak memiliki chat/UGC publik, perjudian, kekerasan, konten seksual atau penjualan barang digital. Jawab kuesioner yang sebenarnya; rating akhir ditentukan IARC, bukan disetel sepihak. Iklan juga harus sesuai rating.
5. Audiens target: rekomendasi 18+ untuk pemilik/pengelola usaha, jika memang itu audiens yang dipilih pemilik. Rentang target berbeda dari hasil rating konten. Jangan menyertakan kelompok anak hanya untuk memperluas jangkauan.
6. Keamanan Data: gunakan pembahasan di bawah, sesuai profil AAB beriklan.
7. Aplikasi pemerintah: Tidak; pengelola PT DDD DREAM DEVELOP DIGITAL, bukan instansi pemerintah.
8. Fitur keuangan: jangan centang pinjaman, bank, transfer, dompet digital, saham, asuransi atau kripto. Aplikasi mencatat metode pembayaran secara manual, tidak memproses pembayaran. Karena pembukuan, pengeluaran dan laba berkaitan dengan pengelolaan uang, rekomendasi interpretasi untuk formulir ini adalah dukungan layanan → Lainnya jika tersedia. Jelaskan: “Pencatatan keuangan usaha offline: penjualan, pengeluaran, stok dan estimasi laba. Tidak menyediakan pinjaman, pembayaran/transfer uang, investasi, asuransi atau saran keuangan personal.” Ini interpretasi fungsi aplikasi terhadap kategori Other Google, bukan klasifikasi akuntansi eksplisit dari Google; cocokkan dengan pilihan dan penjelasan form aktual.
9. Kesehatan: aplikasi tidak menawarkan fitur kesehatan, layanan medis, riset kesehatan atau akses data kesehatan.
10. Kategori dan kontak: Aplikasi → Bisnis; email publik hmdhmdndani@gmail.com; situs https://ddd-dream-develop-digital.vercel.app/. Pilih tag yang benar-benar tersedia dan relevan dengan pembukuan/inventaris/usaha. Nomor telepon opsional tidak perlu diulang dari kontak privat Google.
11. Listing: gunakan berkas teks di store-listing dan gambar yang ditunjuk di bawah.

## Keamanan Data — profil owner AdMob

Basis implementasi: google_mobile_ads 9.1.0 memakai Android Google Mobile Ads 25.4.0 dan UMP 4.0.0. Dokumentasi Google yang saat ini dipublikasikan menguraikan SDK terbaru 25.5.0; tabel berikut adalah panduan deklarasi berdasarkan kategori umum SDK dan implementasi, bukan audit traffic lengkap SDK 25.4.0 atau sertifikasi formulir.

- Pertanyaan mengumpulkan/membagikan jenis data yang diwajibkan: **Ya**, karena SDK iklan. Pembukuan lokal tidak membenarkan jawaban “Tidak” untuk keseluruhan aplikasi.
- Jenis yang perlu dicocokkan di form: lokasi perkiraan (dari IP), interaksi aplikasi, diagnostik, serta ID perangkat/lainnya (misalnya app set ID). SDK mendokumentasikan pengumpulan dan pembagian untuk iklan, analisis, dan pencegahan penipuan/keamanan. Jangan centang lokasi presisi/GPS, kontak, SMS, foto atau audio tanpa penggunaan aktual.
- Untuk jenis otomatis SDK tersebut: dikumpulkan dan dibagikan; jangan mengklaim hanya diproses sementara. Perlakukan pengumpulan sebagai wajib pada profil saat ini karena aplikasi tidak menyediakan opt-out menyeluruh untuk semua pengguna/wilayah; UMP regional bukan opt-out universal. Tujuan sesuai dokumentasi SDK: iklan/pemasaran, analisis, pencegahan penipuan/keamanan/kepatuhan.
- Enkripsi saat transmisi: Google menyatakan transport SDK menggunakan TLS. Ini berbeda dari enkripsi file backup lokal yang tidak disediakan aplikasi. Konfirmasi jika ada SDK/layanan tambahan di luar build ini.
- Pembuatan akun: aplikasi tidak mengizinkan pembuatan akun. Jangan memilih login Google/email hanya karena pemilik masuk Play Console dengan Google.
- Penghapusan: pengguna dapat menghapus data lokal lewat Hapus data/uninstall dan menghapus ekspor terpisah. Itu tidak membuktikan penghapusan data pada server SDK. Jangan menjanjikan fitur permintaan penghapusan semua data iklan; apabila form meminta mekanisme/URL penghapusan data server, cocokkan teks pertanyaannya dengan kemampuan aktual dan pengaturan Google sebelum menjawab.
- Nama usaha dan data transaksi yang hanya diproses lokal tidak dideklarasikan sebagai dikumpulkan ke server aplikasi. Pemilihan penyimpanan/berbagi backup oleh pengguna perlu dipertimbangkan sesuai pengecualian tindakan pengguna dalam panduan Google. Jangan centang informasi finansial terkirim hanya karena ada angka Rupiah di UI.
- AD_ID sengaja dihapus dari manifest; itu bukan berarti SDK bebas dari semua pengenal. Jika muncul deklarasi Advertising ID, gunakan manifest AAB final dan pertanyaan aktual; tidak sama dengan pertanyaan “aplikasi berisi iklan”.

## Bahan listing siap salin

- Nama: UntungKu Pro.
- Bahasa: Indonesia.
- Deskripsi singkat: store-listing/id-short-description.txt.
- Deskripsi lengkap: store-listing/id-full-description.txt.
- Catatan rilis: store-listing/id-release-notes.txt.
- Ikon 512×512: ../assets/branding/untungku-icon-512.png.
- Feature graphic 1024×500: ../assets/branding/feature-graphic-1024x500.png.
- Screenshot ponsel: store-screenshots/01-dashboard.png hingga 05-calculator-results.png, serta 07-dashboard-dark.png. Screenshot 06-settings.png mendahului perubahan teks/tautan kebijakan terbaru, sehingga jangan gunakan untuk listing final tanpa capture ulang. Gambar bukan jaminan persetujuan Play.

## Upload dan rilis

AAB lokal final: ~/Downloads/UntungKu-Pro-1.0.0-v2-release-dea7489.aab. Versi 1.0.0, kode 2; package id.untungku.untungku_pro. Jangan unggah file JKS/password. Backup signing berada di ~/Downloads/UntungKu-Pro-upload-key-backup dan harus disimpan privat.

Untuk mencoba di Play, buka Pengujian internal → buat daftar email penguji → buat rilis → ikuti Play App Signing → unggah AAB → tempel catatan rilis → tinjau error/peringatan → simpan dan konfirmasi peluncuran pengujian sesuai pilihan pemilik. Bagikan opt-in link kepada email yang didaftarkan. Ini tidak memublikasikan track produksi.

Untuk produksi: selesaikan konten/listing, pilih negara/wilayah sesuai pasar (rekomendasi awal Indonesia bila itu keputusan pemilik), tentukan harga (gratis bila sesuai rencana), buat rilis produksi dengan AAB yang tersedia pada library atau unggahan yang diterima Console, dan baca ringkasan perubahan sebelum kirim untuk ditinjau. Jangan memaksa unggah ulang kode versi yang sudah dipakai. Publishing overview menunjukkan perubahan yang siap dikirim; persetujuan dan publikasi adalah tahap berbeda. Track tertutup/terbuka dan prapendaftaran bersifat pilihan sesuai kebutuhan akun, bukan kewajiban menuntaskan semua kartu dasbor.

Sebelum distribusi beriklan luas, periksa Privacy & messaging akun AdMob serta pengujian consent wilayah yang ditarget. Tes Google test banner sudah lulus; live serving unit pemilik dan consent EEA belum diverifikasi. Memilih 18+ tidak menggantikan persetujuan privasi iklan.

## Referensi resmi

- Pengujian internal: https://support.google.com/googleplay/android-developer/answer/9845334
- Persyaratan akun pribadi baru: https://support.google.com/googleplay/android-developer/answer/14151465
- Konten/deklarasi: https://support.google.com/googleplay/android-developer/answer/9859455
- Rating: https://support.google.com/googleplay/android-developer/answer/9859655
- Fitur keuangan: https://support.google.com/googleplay/android-developer/answer/13849271
- Keamanan Data: https://support.google.com/googleplay/android-developer/answer/10787469
- SDK iklan: https://developers.google.com/admob/android/privacy/play-data-disclosure
- Listing: https://support.google.com/googleplay/android-developer/answer/9859152
