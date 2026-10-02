# Catatan Flutter — Pertemuan 1

## Daftar Isi
1. [Menjalankan Flutter](#1-menjalankan-flutter)
2. [Membuat Proyek Baru](#2-membuat-proyek-baru)
3. [Membedah Kode](#3-membedah-kode)

---

## 1. Menjalankan Flutter

Ada dua cara untuk menjalankan aplikasi Flutter: melalui Linux (desktop) atau melalui perangkat HP.

### 1.1 Menjalankan melalui Linux

1. Jalankan perintah berikut di terminal Ubuntu:
   ```bash
   flutter run
   ```
2. Pilih target **linux**.
3. Tampilan dari kode yang dijalankan akan muncul.

### 1.2 Menjalankan melalui Perangkat HP

**Persiapan di HP dan laptop**

1. Aktifkan **mode developer** pada HP.
2. Aktifkan **USB debugging** pada pengaturan HP.
3. Colokkan kabel USB dari laptop ke HP.
4. Pastikan HP dalam mode **Transfer data**.
   - Cara cek: buka File Manager. Jika HP sudah muncul, berarti sudah terhubung dengan benar.

**Menghubungkan HP ke WSL**

5. Buka **PowerShell** dengan **Run as administrator**.
6. Cek perangkat yang terhubung ke laptop:
   ```powershell
   usbipd list
   ```
   Contoh output:
   ```text
   Connected:
   BUSID  VID:PID    DEVICE                                                        STATE
   2-2    04e8:6860  S10+ milik azkiya, SAMSUNG Mobile USB Modem, SAMSUNG Mobi...  Shared
   2-6    1bcf:28cc  Integrated Webcam                                             Not shared
   2-10   8087:0026  Intel(R) Wireless Bluetooth(R)                                Not shared
   ```
7. Sambungkan perangkat ke WSL:
   ```powershell
   usbipd attach --wsl --busid 2-2
   ```
   > **Catatan:** ambil angka `BUSID` dari hasil `usbipd list` (contoh: `2-2`). Nilainya bisa berubah-ubah.
8. Buka terminal Ubuntu, lalu cek apakah HP sudah terhubung:
   ```bash
   adb devices
   ```
9. Jalankan proyek Flutter:
   ```bash
   flutter run
   ```
   HP akan otomatis mengunduh dan membuka aplikasi yang dibuat.

### 1.3 Tombol Kontrol di Terminal (Saat Running)

| Tombol | Fungsi | Kapan Digunakan |
|:------:|--------|-----------------|
| `r` | Hot Reload | Perubahan kode UI/tampilan biasa (paling sering dipakai). |
| `R` (kapital) | Hot Restart | Jika mengubah logika berat, `initState()`, atau variabel global (aplikasi diulang dari awal). |
| `h` | Help | Menampilkan daftar lengkap bantuan perintah terminal. |
| `q` | Quit | Menghentikan/keluar dari proses running aplikasi. |

---

## 2. Membuat Proyek Baru

1. Buka terminal Ubuntu.
2. Buat proyek baru:
   ```bash
   flutter create praktikum
   ```
3. Buka VS Code.
4. Mulai menulis kode di folder `lib`.

---

## 3. Membedah Kode

### 3.1 Import Library

```dart
import 'package:flutter/material.dart';
```

Memanggil library agar bisa memakai komponen Flutter, seperti:
`MaterialApp`, `Scaffold`, `AppBar`, `Text`, dan `Center`.

### 3.2 Class `MyApp`

```dart
class MyApp extends StatelessWidget {
```

| Bagian | Arti |
|--------|------|
| `class` | Membuat sebuah class |
| `MyApp` | Nama class |
| `extends` | Mewarisi |
| `StatelessWidget` | Jenis widget; tampilannya **tidak berubah / tetap** |

### 3.3 Method `build`

```dart
Widget build(BuildContext context) {
```

Method ini berfungsi **membuat tampilan layar**.

Contoh menampilkan teks:

```dart
return Text('Halo');
```

Contoh menampilkan teks di tengah layar:

```dart
return Center(
  child: Text('Halo'),
);
```

### 3.4 `return`

```dart
return MaterialApp(
```

Artinya fungsi `build()` mengembalikan widget `MaterialApp`. Di dalamnya:

```dart
home: Scaffold(
```

Artinya halaman utama aplikasi menggunakan `Scaffold`.

### 3.5 `Scaffold`

`Scaffold` adalah **kerangka halaman**.

```text
┌───────────────────────────┐
│          APP BAR          │
├───────────────────────────┤
│                           │
│                           │
│           BODY            │
│                           │
│                           │
└───────────────────────────┘
```

Struktur dasar yang disediakan `Scaffold`:

```text
Scaffold
│
├── appBar
├── body
├── floatingActionButton
├── drawer
└── ...
```

Pola penggunaan yang sangat umum di Flutter:

```dart
Scaffold(
  appBar: ...,
  body: ...,
)
```

### 3.6 `AppBar`

```dart
appBar: AppBar(
  title: const Text('Hello Flutter'),
),
```

Hasilnya kira-kira:

```text
┌─────────────────────────┐
│ Hello Flutter           │
├─────────────────────────┤
│                         │
│                         │
└─────────────────────────┘
```

### 3.7 `child`

```dart
Center(
  child: Text('Halo'),
)
```

Hubungan antar widget:

```text
Center
  │
  └── child
       │
       └── Text
```

`child` berarti **widget anak yang berada di dalam widget tersebut**.