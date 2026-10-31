# Warung Ibu Kost Dhiesna

Aplikasi Flutter untuk pemesanan makanan, keranjang, checkout, pembayaran QRIS/tunai, dan tracking pesanan. Frontend memakai data dan pembayaran mock, tanpa backend atau transaksi uang asli.

## Menjalankan aplikasi

```sh
cd /home/bahut/warung_dhiesna
flutter pub get
flutter run -d chrome
```

Untuk Android/iOS, pilih perangkat dengan `flutter devices`, lalu jalankan `flutter run -d <device-id>`. Gunakan build debug untuk mencoba kontrol simulasi pembayaran dan tracking.
