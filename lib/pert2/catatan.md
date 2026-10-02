# Catatan Flutter Modul 2: Layout, ListView, dan Navigasi

Modul 2 isinya tiga hal besar:

1. Membuat layout
2. Membuat daftar data
3. Berpindah halaman dan mengirim data

Ketiganya memang dasar dari aplikasi mobile. Tujuan modulnya: bisa memakai `Container`, `Padding`, `Row`, `Column`, `Expanded`, `ListView.builder`, `Card`, `ListTile`, class Dart, serta `Navigator.push` dan `Navigator.pop`.

Alur belajar yang akan saya ikuti di catatan ini:

```
Container
   ↓
Row & Column
   ↓
Model Class
   ↓
List
   ↓
ListView.builder
   ↓
Card & ListTile
   ↓
Navigator
   ↓
Passing Data
   ↓
Aplikasi Daftar Kontak
```

Dengan urutan ini, setiap baris kode ada alasannya, bukan sekadar karena modul menyuruh menulisnya.

---

## Bagian A: Layout Kartu Profil

Target tampilannya, sebuah kartu profil dengan avatar di kiri dan nama serta NIM di kanan:

```
┌────────────────────────────────┐
│                                │
│    (avatar)   Azkiya           │
│               12345678         │
│                                │
└────────────────────────────────┘
```

Untuk membuat kotaknya, Flutter punya `Container`. Widget ini serbaguna: bisa mengatur ukuran, warna, border, radius, padding, dan margin.

### Struktur file

```
lib/
│
├── main.dart
│
└── pertemuan2/
    └── pertemuan2.dart
```

### main.dart

```dart
import 'pertemuan2/pertemuan2.dart';

void main() {
  runApp(const Pertemuan2App());
}
```

### pertemuan2.dart

```dart
import 'package:flutter/material.dart';

class Pertemuan2App extends StatelessWidget {
  const Pertemuan2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 2',
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                child: Icon(
                  Icons.person,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Azkiya Zahrul',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('12345678'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Sebelum di-run, saya bedah dulu supaya bisa membaca kodenya, bukan cuma menyalin.

### Nama class: Pertemuan2App

```dart
class Pertemuan2App extends StatelessWidget {
```

Namanya bukan `MyApp` lagi karena ini aplikasi untuk Pertemuan 2. Membiasakan nama yang menjelaskan fungsi itu kebiasaan yang bagus.

### MaterialApp dan home

```dart
return MaterialApp(
  title: 'Praktikum 2',
  home: const ProfilePage(),
);
```

```
MaterialApp
    │
    └── home
          │
          └── ProfilePage
```

`home: const ProfilePage()` artinya ketika aplikasi dimulai, halaman pertama yang tampil adalah `ProfilePage`.

### Scaffold

```dart
return Scaffold(
  appBar: AppBar(
    title: const Text('Profil'),
  ),
  body: ...
);
```

```
Scaffold
│
├── AppBar
│    └── Text("Profil")
│
└── Body
```

### Padding

```dart
body: Padding(
  padding: const EdgeInsets.all(16),
  child: Container(
```

`Padding` memberi jarak antara tepi layar dan `Container`.

```
┌──────────────────────────────┐
│                              │
│   ┌──────────────────────┐   │
│   │      Container       │   │
│   └──────────────────────┘   │
│                              │
└──────────────────────────────┘
```

`EdgeInsets.all(16)` artinya atas, bawah, kiri, dan kanan sama-sama 16.

### Container sebagai kartu

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(12),
  ),
```

- `decoration` dipakai untuk mengatur tampilan.
- `color: Colors.blue.shade50` memberi warna latar.
- `borderRadius: BorderRadius.circular(12)` membuat sudutnya membulat.

### Row dan Column

| Widget | Arah susunan |
|--------|--------------|
| `Row` | horizontal |
| `Column` | vertikal |

Untuk tampilan avatar di kiri dan teks di kanan, kita pakai `Row`.

### CircleAvatar

```dart
CircleAvatar(
  radius: 32,
  child: Icon(
    Icons.person,
    size: 32,
  ),
)
```

- `radius: 32` mengatur ukuran lingkaran.
- `Icon(Icons.person)` adalah ikon orang di dalamnya.

### SizedBox untuk jarak

```dart
SizedBox(width: 16)
```

Karena berada di dalam `Row`, yang dipakai `width` (jarak kiri-kanan). Kalau di dalam `Column`, yang dipakai `height` (jarak atas-bawah).

```
Row    + SizedBox(width)   -> jarak kiri/kanan
Column + SizedBox(height)  -> jarak atas/bawah
```

### Column di dalam Row

```
Row
│
├── CircleAvatar
│
├── SizedBox
│
└── Expanded
      │
      └── Column
           │
           ├── Text
           └── Text
```

Ternyata `Row` dan `Column` boleh digabung. Ini kemampuan penting untuk menyusun UI di Flutter.

### Expanded

```dart
Expanded(
  child: Column(
```

Bayangkan nama orangnya panjang sekali. Kalau cuma `Row` berisi avatar dan teks, teksnya bisa keluar dari layar. `Expanded` berarti "gunakan ruang yang masih tersisa", jadi bagian kanan menyesuaikan lebar yang tersedia.

Di modul ada saran untuk mencoba menghapus `Expanded` lalu memanjangkan nama, supaya kelihatan bedanya. Ini perlu saya coba sendiri.

### crossAxisAlignment

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
```

Ini yang awalnya membingungkan. Pada `Column`:

- main axis = vertikal (atas ke bawah)
- cross axis = horizontal (kiri ke kanan)

Jadi `CrossAxisAlignment.start` artinya isi `Column` dimulai dari sisi kiri, bukan di tengah.

### Widget tree lengkap

```
Pertemuan2App
      │
      ↓
MaterialApp
      │
      ↓
ProfilePage
      │
      ↓
Scaffold
   ┌──┴───────┐
   ↓          ↓
AppBar       Body
   │          │
 Text       Padding
              │
          Container
              │
             Row
        ┌─────┼─────┐
        ↓     ↓     ↓
     Avatar SizedBox Expanded
                    │
                  Column
                 ┌──┴──┐
                 ↓     ↓
               Text   Text
```

Inilah widget tree. Konsep dari Modul 1 sekarang mulai dipakai untuk membangun aplikasi yang lebih nyata.

---

## Bagian B: Data Kontak dan ListView

Target tampilannya, daftar kontak yang bisa di-scroll:

```
┌────────────────────────────┐
│      Daftar Kontak         │
├────────────────────────────┤
│  A   Andi                  │
│      08123456789           │
│                            │
│  B   Budi                  │
│      08234567890           │
│                            │
│  C   Citra                 │
│      08345678901           │
│  ...                       │
└────────────────────────────┘
```

### 1. Kenapa perlu class Kontak

Satu kontak punya tiga data: nama, telepon, dan email. Kalau ditulis tanpa struktur:

```dart
String nama = 'Andi';
String telepon = '08123456789';
String email = 'andi@email.com';
```

Masalahnya muncul kalau ada 6 kontak. Variabelnya jadi `nama1`, `telepon1`, `email1`, `nama2`, dan seterusnya. Berantakan. Yang dibutuhkan adalah cetakan data kontak:

```
              Kontak
                │
       ┌────────┼────────┐
       ↓        ↓        ↓
      nama   telepon   email
```

### 2. Membuat class Kontak

Ditulis di bagian atas `pertemuan2.dart`, setelah import:

```dart
import 'package:flutter/material.dart';

class Kontak {
  final String nama;
  final String telepon;
  final String email;

  const Kontak(
    this.nama,
    this.telepon,
    this.email,
  );
}
```

Bedah per bagian:

**`class Kontak`** artinya membuat cetakan bernama `Kontak`, seperti formulir:

```
┌──────────────────────┐
│ DATA KONTAK          │
│                      │
│ Nama     : ________  │
│ Telepon  : ________  │
│ Email    : ________  │
└──────────────────────┘
```

**`final String nama;`** artinya setiap objek `Kontak` punya data `nama` bertipe `String` (teks). Begitu juga `telepon` dan `email`.

**Kenapa telepon pakai String, bukan int?** Karena nomor telepon bukan angka yang dihitung. Kita tidak pernah menjumlahkan `08123456789 + 08123456788`. Jadi lebih tepat dianggap teks atau identitas.

**Constructor**:

```dart
const Kontak(
  this.nama,
  this.telepon,
  this.email,
);
```

Untuk sekarang, constructor cukup dipahami sebagai cara membuat objek `Kontak` baru sekaligus mengisi datanya:

```dart
Kontak(
  'Andi',
  '08123456789',
  'andi@email.com',
)
```

### 3. Membuat banyak kontak dalam list

```dart
const daftarKontak = [
  Kontak('Andi', '08123456789', 'andi@email.com'),
  Kontak('Budi', '08234567890', 'budi@email.com'),
  Kontak('Citra', '08345678901', 'citra@email.com'),
  Kontak('Deni', '08456789012', 'deni@email.com'),
  Kontak('Eka', '08567890123', 'eka@email.com'),
  Kontak('Fajar', '08678901234', 'fajar@email.com'),
];
```

Struktur datanya:

```
daftarKontak
│
├── Kontak Andi
│    ├── nama
│    ├── telepon
│    └── email
│
├── Kontak Budi
├── Kontak Citra
├── Kontak Deni
├── Kontak Eka
└── Kontak Fajar
```

### 4. Data bukan tampilan

Ini konsep penting. Sampai sini kita sudah punya data (`daftarKontak`), tapi layar masih kosong. Perlu sesuatu yang mengubah data menjadi widget:

```
Data  ->  Widget  ->  Tampilan
```

Untuk daftar yang bisa di-scroll, kita pakai `ListView.builder`.

### 5. ListView dan .builder

Kalau daftarnya lebih panjang dari layar, harus bisa di-scroll. `ListView` menyediakan itu.

Ada `ListView()` dan ada `ListView.builder()`. Untuk sekarang cukup ingat: `ListView.builder` cocok kalau ada data yang ingin diubah menjadi daftar secara berulang.

### 6. ContactPage versi paling sederhana

```dart
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
      ),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];

          return Text(kontak.nama);
        },
      ),
    );
  }
}
```

Hasilnya cuma deretan nama (Andi, Budi, Citra, dan seterusnya). Sengaja dibuat sederhana dulu, belum pakai `Card` dan `ListTile`.

### 7. Bedah ListView.builder

**`itemCount: daftarKontak.length`** memberi tahu Flutter berapa item yang harus dibuat. Isi list ada 6, jadi dibuat 6 item.

**`index`** ini yang sering bikin pemula bingung. Index dimulai dari 0, bukan 1:

| Index | Data |
|:-----:|------|
| 0 | Andi |
| 1 | Budi |
| 2 | Citra |
| 3 | Deni |
| 4 | Eka |
| 5 | Fajar |

Jadi `daftarKontak[0]` adalah Andi dan `daftarKontak[1]` adalah Budi.

**`itemBuilder: (context, index) { ... }`** artinya: untuk setiap index, tentukan widget apa yang ditampilkan.

```dart
final kontak = daftarKontak[index];
```

Ambil kontak sesuai index yang sedang diproses. Misalnya `index = 0` berarti `daftarKontak[0]`, yaitu Andi.

```dart
return Text(kontak.nama);
```

Tampilkan nama kontak tersebut.

### 8. Mempercantik dengan Card dan ListTile

Supaya mirip aplikasi kontak sungguhan, ganti `return Text(kontak.nama);` menjadi:

```dart
return Card(
  margin: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),
  child: ListTile(
    leading: CircleAvatar(
      child: Text(
        kontak.nama[0],
      ),
    ),
    title: Text(kontak.nama),
    subtitle: Text(kontak.telepon),
    trailing: const Icon(
      Icons.chevron_right,
    ),
  ),
);
```

Hasilnya kira-kira:

```
┌──────────────────────────────┐
│ (A)  Andi                >   │
│      08123456789             │
└──────────────────────────────┘
```

**Card** adalah wadah berbentuk kartu.

**ListTile** berguna untuk membuat satu baris dalam daftar. Strukturnya:

```
ListTile
│
├── leading
├── title
├── subtitle
└── trailing
```

```
┌──────────────────────────────┐
│ leading   title      trailing│
│           subtitle           │
└──────────────────────────────┘
```

- **leading**: bagian kiri. Di sini diisi `CircleAvatar` yang berisi `kontak.nama[0]`, yaitu karakter pertama nama. "Andi" menjadi A, "Budi" menjadi B, "Citra" menjadi C.
- **title**: `Text(kontak.nama)`, menampilkan nama.
- **subtitle**: `Text(kontak.telepon)`, menampilkan nomor di bawah nama.
- **trailing**: bagian kanan. Ikon `chevron_right` (tanda `>`) memberi petunjuk visual bahwa item ini nanti bisa diklik.

---

## Bagian C: Navigasi Antar Halaman

Sekarang aplikasi punya `ContactPage` saja. Yang ingin ditambahkan:

```
ContactPage
     │
     │ tekan kontak
     ▼
DetailPage
     │
     │ tekan tombol kembali
     ▼
ContactPage
```

Halaman detail menampilkan nama, nomor telepon, dan email dari kontak yang ditekan, lengkap dengan tombol kembali.

### 1. Navigator

Anggap aplikasi seperti tumpukan kartu. Awalnya hanya ada `ContactPage`. Saat detail Andi dibuka, `DetailPage` ditaruh di atasnya:

```
┌──────────────────┐
│   DetailPage     │  <- paling atas
└──────────────────┘
┌──────────────────┐
│   ContactPage    │  <- halaman sebelumnya
└──────────────────┘
```

Saat tombol kembali ditekan, `DetailPage` dibuang dari atas dan kita kembali ke `ContactPage`.

Dua operasi utamanya:

| Perintah | Artinya |
|----------|---------|
| `Navigator.push()` | masuk ke halaman baru |
| `Navigator.pop()` | kembali ke halaman sebelumnya |

### 2. Bentuk Navigator.push()

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailPage(),
  ),
);
```

Dipecah:

- **`Navigator.push`** artinya tambahkan halaman baru di atas halaman sekarang.
- **`context`** membantu Flutter mengetahui posisi widget kita di dalam struktur aplikasi. Untuk sekarang tidak perlu terlalu dalam memikirkan `BuildContext`. Cukup tahu bahwa kita memberi tahu Flutter, "pakai konteks widget saya ini untuk melakukan navigasi."
- **`MaterialPageRoute`** menentukan halaman yang akan dibuka.
- **`builder: (context) => DetailPage()`** artinya, "buat halaman baru berupa `DetailPage`."

```
Navigator.push
      │
      ▼
MaterialPageRoute
      │
      ▼
DetailPage
```

### 3. Masalah berikutnya: mengirim data

Kita tidak sekadar ingin membuka `DetailPage`, tapi membuka detail kontak yang diklik. Kalau Andi diklik, `DetailPage` harus tahu nama, telepon, dan emailnya.

Datanya sebenarnya sudah ada dari Bagian B:

```dart
final kontak = daftarKontak[index];
```

Variabel `kontak` ini sudah berisi data kontak yang sedang diproses. Tinggal dikirim ke halaman detail.

### 4. DetailPage menerima objek Kontak

```dart
class DetailPage extends StatelessWidget {
  final Kontak kontak;

  const DetailPage({
    super.key,
    required this.kontak,
  });

  ...
}
```

`final Kontak kontak;` artinya `DetailPage` punya data bernama `kontak` yang tipenya `Kontak`.

Kenapa tipenya `Kontak`? Karena `Kontak` adalah tipe data buatan sendiri dari Bagian B. Dengan begitu satu objek bisa membawa seluruh data sekaligus. Bandingkan:

```dart
// cara yang repot
DetailPage(
  nama: kontak.nama,
  telepon: kontak.telepon,
  email: kontak.email,
)

// cara yang lebih rapi
DetailPage(
  kontak: kontak,
)
```

`required this.kontak` artinya setiap kali membuat `DetailPage`, data kontak wajib diberikan. Kalau cuma menulis `DetailPage()`, Flutter akan menolak.

### 5. Memasang Navigator ke ListTile

`ListTile` punya `onTap`, yaitu aksi ketika ditekan:

```dart
ListTile(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
          kontak: kontak,
        ),
      ),
    );
  },

  leading: CircleAvatar(
    child: Text(
      kontak.nama[0],
    ),
  ),
  title: Text(kontak.nama),
  subtitle: Text(kontak.telepon),
  trailing: const Icon(
    Icons.chevron_right,
  ),
),
```

Cara membacanya dari luar ke dalam:

1. `onTap: () {` : ketika `ListTile` ditekan...
2. `Navigator.push(` : buka halaman baru
3. `context,` : pakai context saat ini
4. `MaterialPageRoute(` : buat perpindahan ke halaman baru
5. `builder: (context) =>` : halaman barunya adalah...
6. `DetailPage(` : halaman `DetailPage`
7. `kontak: kontak,` : kirim kontak yang sedang dipilih

Perhatikan bahwa tidak ada data baru yang dibuat. Kita hanya mengambil `kontak` dari `daftarKontak[index]` lalu mengirimkannya. Alurnya:

```
daftarKontak
     │
     ▼
   index
     │
     ▼
daftarKontak[index]
     │
     ▼
  kontak
     │
     ▼
  ListTile
     │
     │ onTap
     ▼
 Navigator.push
     │
     ▼
 DetailPage
     │
     ▼
kontak
```

Konsep ini penting untuk aplikasi Flutter yang lebih besar nanti.

### 6. Membuat DetailPage

Ditulis di bawah `ContactPage`:

```dart
class DetailPage extends StatelessWidget {
  final Kontak kontak;

  const DetailPage({
    super.key,
    required this.kontak,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kontak'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                kontak.nama[0],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              kontak.nama,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              kontak.telepon,
            ),

            const SizedBox(height: 10),

            Text(
              kontak.email,
            ),
          ],
        ),
      ),
    );
  }
}
```

Data yang diterima bisa langsung dipakai. Kalau yang dibuka Andi:

```
kontak
│
├── nama    -> Andi
├── telepon -> 08123456789
└── email   -> andi@email.com
```

Maka `kontak.nama` menghasilkan `Andi`, `kontak.telepon` menghasilkan `08123456789`, dan `kontak.email` menghasilkan `andi@email.com`. Tidak perlu membuat variabel baru, karena data dari halaman sebelumnya tetap bisa dipakai.

Hasil tampilannya:

```
┌─────────────────────────┐
│ <-    Detail Kontak     │
├─────────────────────────┤
│                         │
│           (A)           │
│                         │
│          Andi           │
│                         │
│      08123456789        │
│      andi@email.com     │
│                         │
└─────────────────────────┘
```

### 7. Navigator.pop() untuk kembali

```dart
Navigator.pop(context);
```

Secara konsep: `push` untuk masuk, `pop` untuk kembali. `DetailPage` dikeluarkan dari tumpukan, lalu kita kembali ke `ContactPage`.

Apakah harus membuat tombol back sendiri? Tidak harus. Karena halaman dibuka dengan `Navigator.push()`, `AppBar` di `DetailPage` biasanya otomatis menampilkan tombol panah kembali. Tapi supaya benar-benar paham `Navigator.pop()`, kita bisa membuat tombol sendiri, misalnya setelah email:

```dart
const SizedBox(height: 20),

ElevatedButton(
  onPressed: () {
    Navigator.pop(context);
  },
  child: const Text('Kembali'),
),
```

Hasilnya:

```
┌─────────────────────────┐
│ <-    Detail Kontak     │
├─────────────────────────┤
│                         │
│           (A)           │
│          Andi           │
│      08123456789        │
│      andi@email.com     │
│                         │
│       ┌──────────┐      │
│       │ Kembali  │      │
│       └──────────┘      │
│                         │
└─────────────────────────┘
```

---

## Ringkasan: Tiga Bagian Aplikasi Kontak

**1. Data** adalah class `Kontak` (nama, telepon, email) dan list `daftarKontak`.

**2. Halaman daftar** adalah `ContactPage`, yang memakai `ListView.builder`, `Card`, dan `ListTile`.

**3. Halaman detail** adalah `DetailPage`, yang menerima satu objek `Kontak`.

Hubungan ketiganya:

```
             daftarKontak
                  │
                  ▼
           ┌─────────────┐
           │ ContactPage │
           └──────┬──────┘
                  │
               onTap
                  │
             Navigator
               .push()
                  │
                  ▼
           ┌─────────────┐
           │ DetailPage  │
           └──────┬──────┘
                  │
             Navigator
               .pop()
                  │
                  ▼
           ┌─────────────┐
           │ ContactPage │
           └─────────────┘
```

## Poin yang Perlu Diingat

| Konsep | Intinya |
|--------|---------|
| `Container` | kotak serbaguna (ukuran, warna, border, radius, padding, margin) |
| `Padding` | jarak antara widget dan sekitarnya |
| `Row` / `Column` | susunan horizontal / vertikal |
| `Expanded` | memakai ruang yang masih tersisa |
| `crossAxisAlignment` | posisi isi pada sumbu silang (pada `Column`: kiri-kanan) |
| `SizedBox` | jarak kosong (`width` di `Row`, `height` di `Column`) |
| class `Kontak` | cetakan data supaya tidak berantakan |
| `ListView.builder` | membuat daftar scroll dari data (`itemCount` dan `itemBuilder`) |
| `index` | dimulai dari 0 |
| `Card` + `ListTile` | baris daftar yang rapi (leading, title, subtitle, trailing) |
| `Navigator.push` | masuk ke halaman baru |
| `Navigator.pop` | kembali ke halaman sebelumnya |
| `required this.kontak` | data wajib dikirim saat membuat `DetailPage` |

## Hal yang Mau Saya Coba Sendiri

- Hapus `Expanded` di kartu profil, lalu panjangkan nama, dan lihat apa yang terjadi.
- Ubah `CrossAxisAlignment.start` menjadi `center` dan `end`.
- Tambah kontak baru ke `daftarKontak` dan lihat apakah list dan detailnya ikut muncul.
- Coba tulis `DetailPage()` tanpa data dan baca pesan error-nya.