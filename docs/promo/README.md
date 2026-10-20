# Video promosi UntungKu Pro

Dua MP4 30 detik telah dibuat dan disalin ke ~/Downloads/UntungKu-Pro-Video-Promosi. Ukuran landscape 1920×1080 dan vertikal 1080×1920, H.264/AAC, 30fps. Metadata/checksum ada di verification.json.

Enam adegan: identitas usaha; produk/stok; penjualan/pengeluaran; simulasi laba; offline/backup; penutup. Penutup menggunakan “Segera hadir di Google Play” karena listing masih dalam peninjauan saat dibuat. Jangan mengubahnya menjadi klaim sudah tersedia sebelum publikasi terkonfirmasi.

Visual menggunakan screenshot aplikasi asli dengan vector titles, transisi fade dan gerakan halus. Audio instrumental disintesis dari nada/chord oleh script, tanpa rekaman stok atau musik pihak ketiga; tidak ada voice-over. Kesesuaian tampilan enam adegan diperiksa lewat contact sheet, kedua file lolos decode penuh FFmpeg. Ini bukan hasil pemutaran manusia di seluruh jenis perangkat.

Render ulang pada macOS:

```sh
python3 tool/generate_promo.py
```

Memerlukan ffmpeg/libx264 dan sips bawaan macOS. SVG, frame antara, audio WAV asli dan MP4 berada di build/promo (tidak dilacak Git). File SRT menyediakan teks judul; judul dan keterangan utama juga sudah tertanam di video. Script tidak mengubah data bisnis, tidak meminta iklan, dan tidak menerbitkan video ke layanan eksternal.
