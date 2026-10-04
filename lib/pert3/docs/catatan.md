# Catatan Flutter: State Management dengan Provider dan Form Input

Catatan ini dari kode aplikasi Daftar Belanja. Isinya tiga bagian besar:

1. Menyimpan data belanja di satu tempat yang bisa diakses banyak halaman (Provider)
2. Menampilkan daftar belanja dengan checkbox dan tombol hapus
3. Membuat form input lengkap (teks, angka, dropdown, checkbox) dengan validasi

Alur yang akan saya ikuti:

```
Model Class (Barang)
   ↓
ChangeNotifier (BelanjaModel)
   ↓
Provider (membungkus aplikasi)
   ↓
context.watch / context.read
   ↓
Halaman Daftar (ListView.builder)
   ↓
Halaman Form (Form, TextFormField, Dropdown, Checkbox)
   ↓
Simpan data lalu kembali ke daftar
```

Target aplikasinya:

```
┌─────────────────────────────────┐
│  Daftar Belanja (2 Sisa)        │
├─────────────────────────────────┤
│ [ ] Telur (12 pcs)          [x] │
│     Kategori: Makanan           │
│ [v] Sabun (2 pcs)           [x] │
│     Kategori: Kebutuhan Rumah   │
│                                 │
│                          ( + )  │
└─────────────────────────────────┘
```

Baris yang dicentang akan tercoret, dan angka "Sisa" di AppBar menghitung barang yang belum dibeli.

---

## Persiapan: Menambah Package Provider

`provider` bukan bawaan Flutter, jadi harus ditambahkan dulu. Di terminal, dalam folder proyek:

```bash
flutter pub add provider
```

Setelah itu di bagian atas file kode:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
```

---

## Bagian 1: Model Data Barang

```dart
class Barang {
  final String nama;
  final int jumlah;
  final String kategori;
  bool sudahDibeli;

  Barang({
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.sudahDibeli = false,
  });
}
```

Sama seperti class `Kontak` di modul sebelumnya, ini cetakan data. Satu `Barang` punya empat data.

```
Barang
│
├── nama          (String)
├── jumlah        (int)
├── kategori      (String)
└── sudahDibeli   (bool)
```

Hal baru yang saya perhatikan:

- **`final` vs tidak `final`.** `nama`, `jumlah`, dan `kategori` pakai `final` karena sekali dibuat tidak berubah. `sudahDibeli` tidak pakai `final` karena nilainya memang akan berubah-ubah saat checkbox dicentang.
- **Constructor pakai kurung kurawal `{ }`.** Ini disebut named parameter, jadi saat membuat objek harus menulis nama parameternya: `Barang(nama: 'Telur', jumlah: 12, kategori: 'Makanan')`. Di class `Kontak` sebelumnya, constructor-nya posisional (tanpa nama).
- **`this.sudahDibeli = false`** adalah nilai bawaan. Kalau tidak diisi, barang dianggap belum dibeli. Karena punya nilai bawaan, parameter ini tidak diberi `required`.
- **`int` untuk jumlah.** Beda dengan nomor telepon yang dipakai sebagai String, jumlah barang memang angka yang bisa dihitung, jadi tipenya `int`.

---

## Bagian 2: State Management dengan ChangeNotifier

### Kenapa tidak cukup pakai setState?

Kalau pakai `setState`, data hanya hidup di dalam satu widget atau halaman. Padahal di aplikasi ini ada dua halaman yang sama-sama butuh data belanja:

- halaman daftar untuk menampilkan
- halaman tambah untuk menyimpan barang baru

Dengan `ChangeNotifier` dan `Provider`, data disimpan di satu tempat pusat dan bisa dibaca atau diubah dari halaman mana pun.

```
        ┌──────────────┐
        │ BelanjaModel │   <- data disimpan di sini
        └──────┬───────┘
               │
       ┌───────┴────────┐
       ▼                ▼
┌──────────────┐  ┌──────────────────┐
│DaftarBelanja │  │ TambahBelanja    │
│Page (baca)   │  │ Page (ubah)      │
└──────────────┘  └──────────────────┘
```

### Kode BelanjaModel

```dart
class BelanjaModel extends ChangeNotifier {
  final List<Barang> _items = [];

  List<Barang> get items => List.unmodifiable(_items);

  int get jumlahBelumDibeli => _items.where((b) => !b.sudahDibeli).length;

  void tambahBarang(String nama, int jumlah, String kategori) {
    _items.add(Barang(nama: nama, jumlah: jumlah, kategori: kategori));
    notifyListeners();
  }

  void toggleStatus(int index) {
    _items[index].sudahDibeli = !_items[index].sudahDibeli;
    notifyListeners();
  }

  void hapusBarang(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}
```

### Bedah per bagian

**`extends ChangeNotifier`** membuat class ini bisa "memberi kabar" ke widget yang mendengarkannya kalau datanya berubah.

**`final List<Barang> _items = [];`** adalah list kosong untuk menyimpan semua barang. Tanda garis bawah `_` di depan nama berarti private: hanya bisa diakses dari dalam class ini. Jadi halaman lain tidak bisa mengubah `_items` secara langsung, harus lewat method yang kita sediakan.

**Getter `items`:**

```dart
List<Barang> get items => List.unmodifiable(_items);
```

Getter adalah cara membaca data private dari luar. `List.unmodifiable` mengembalikan salinan yang tidak bisa diubah, jadi kalau halaman lain mencoba `items.add(...)`, akan error. Ini menjaga supaya perubahan data hanya lewat method yang punya `notifyListeners()`.

**Getter `jumlahBelumDibeli`:**

```dart
int get jumlahBelumDibeli => _items.where((b) => !b.sudahDibeli).length;
```

Dibaca dari kiri ke kanan:

1. `_items.where(...)` : saring item yang memenuhi syarat
2. `(b) => !b.sudahDibeli` : syaratnya, barang `b` yang `sudahDibeli`-nya bukan true (tanda `!` artinya "bukan")
3. `.length` : hitung ada berapa

Contoh: kalau ada 3 barang dan 1 sudah dibeli, hasilnya 2. Angka inilah yang tampil di AppBar.

**`notifyListeners()`** ini yang paling penting. Setiap kali data berubah (tambah, ubah status, hapus), kita panggil `notifyListeners()` supaya widget yang mendengarkan tahu dan menggambar ulang tampilannya. Kalau lupa memanggilnya, data berubah tapi layar tidak ikut berubah.

**Tiga method pengubah data:**

| Method | Fungsi |
|--------|--------|
| `tambahBarang` | membuat objek `Barang` baru lalu memasukkannya ke `_items` |
| `toggleStatus` | membalik nilai `sudahDibeli` (true jadi false, false jadi true) pada index tertentu |
| `hapusBarang` | menghapus item pada index tertentu |

---

## Bagian 3: Main App dan Pemasangan Provider

Di file kode yang diberikan, bagian ini hanya berisi judul komentar dan class `MyApp`. Untuk bisa dijalankan, `BelanjaModel` harus disediakan di atas `MyApp`. Ini yang biasanya ditulis di `main()`:

```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BelanjaModel(),
      child: const MyApp(),
    ),
  );
}
```

Artinya, `BelanjaModel` dibuat satu kali, lalu dibungkus di atas seluruh aplikasi.

```
ChangeNotifierProvider  (menyediakan BelanjaModel)
        │
        ▼
      MyApp
        │
        ▼
  MaterialApp
        │
        ▼
 DaftarBelanjaPage ──── bisa akses BelanjaModel
        │
        ▼ (Navigator.push)
 TambahBelanjaPage ──── juga bisa akses BelanjaModel
```

Karena Provider berada di atas `MaterialApp`, semua halaman yang dibuka lewat `Navigator` bisa mengakses model yang sama.

**MyApp:**

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Daftar Belanja',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const DaftarBelanjaPage(),
    );
  }
}
```

Bagian baru di sini adalah `theme`. `colorSchemeSeed: Colors.blue` membuat Flutter menyusun seluruh skema warna aplikasi dari satu warna dasar (biru), dan `useMaterial3: true` memakai gaya desain Material 3. Halaman awalnya `DaftarBelanjaPage`.

---

## Bagian 4: Halaman Daftar Belanja

### watch dan read

```dart
final belanja = context.watch<BelanjaModel>();
```

Ada dua cara mengambil data dari Provider, dan ini yang sempat membuat saya bingung:

| Perintah | Artinya | Dipakai di mana |
|----------|---------|-----------------|
| `context.watch<T>()` | baca data dan **rebuild** widget kalau data berubah | di dalam `build`, untuk menampilkan data |
| `context.read<T>()` | baca data **tanpa** rebuild | di dalam callback (`onPressed`, `onChanged`), untuk memanggil method |

Cara mengingatnya: `watch` itu "mengawasi" supaya tampilan selalu mengikuti data. `read` itu "sekadar ambil" untuk menjalankan aksi.

Itu sebabnya di `build` kita pakai `watch`, tetapi saat menekan checkbox atau tombol hapus kita pakai `read`.

### AppBar dengan angka sisa

```dart
appBar: AppBar(
  title: Text('Daftar Belanja (${belanja.jumlahBelumDibeli} Sisa)'),
),
```

`${...}` di dalam string dipakai untuk menyisipkan nilai variabel atau ekspresi ke dalam teks. Karena `belanja` memakai `watch`, angka ini otomatis berubah setiap kali ada barang yang dicentang, ditambah, atau dihapus.

### Body dengan kondisi

```dart
body: belanja.items.isEmpty
    ? const Center(child: Text('Belum ada daftar belanjaan'))
    : ListView.builder(
        ...
      ),
```

Ini ternary operator, bentuk singkat dari if-else:

```
kondisi ? hasil_kalau_benar : hasil_kalau_salah
```

Jadi: kalau list kosong, tampilkan teks di tengah layar. Kalau tidak, tampilkan `ListView.builder`.

### ListView.builder

```dart
ListView.builder(
  itemCount: belanja.items.length,
  itemBuilder: (context, index) {
    final item = belanja.items[index];
    return ListTile(
      ...
    );
  },
)
```

Sama seperti di modul sebelumnya: `itemCount` untuk jumlah item, `itemBuilder` untuk membuat widget tiap item berdasarkan `index`.

### ListTile berisi checkbox dan tombol hapus

```dart
return ListTile(
  leading: Checkbox(
    value: item.sudahDibeli,
    onChanged: (_) => context.read<BelanjaModel>().toggleStatus(index),
  ),
  title: Text(
    '${item.nama} (${item.jumlah} pcs)',
    style: TextStyle(
      decoration: item.sudahDibeli ? TextDecoration.lineThrough : null,
    ),
  ),
  subtitle: Text('Kategori: ${item.kategori}'),
  trailing: IconButton(
    icon: const Icon(Icons.delete, color: Colors.red),
    onPressed: () => context.read<BelanjaModel>().hapusBarang(index),
  ),
);
```

```
┌─────────────────────────────────────┐
│ leading     title            trailing│
│ Checkbox    Sabun (2 pcs)    Delete  │
│             subtitle                 │
└─────────────────────────────────────┘
```

- **leading: Checkbox.** `value` diambil dari `item.sudahDibeli`, jadi centangnya mengikuti data. Saat ditekan, `onChanged` memanggil `toggleStatus(index)`. Tanda `(_)` artinya parameter yang diterima (nilai true/false baru) tidak dipakai, karena `toggleStatus` sudah membalik nilainya sendiri.
- **title.** Menampilkan nama dan jumlah. Gaya `lineThrough` (coret) hanya dipasang kalau `sudahDibeli` bernilai true, kalau tidak nilainya `null` (tanpa dekorasi).
- **trailing: IconButton.** Tombol ikon tempat sampah warna merah. Saat ditekan memanggil `hapusBarang(index)`.
- **Bentuk `=>`** pada `onChanged` dan `onPressed` adalah penulisan singkat untuk fungsi yang isinya satu baris.

Alur ketika checkbox ditekan:

```
Checkbox ditekan
      │
      ▼
context.read<BelanjaModel>().toggleStatus(index)
      │
      ▼
sudahDibeli dibalik + notifyListeners()
      │
      ▼
context.watch di build mendeteksi perubahan
      │
      ▼
tampilan digambar ulang (coret + angka sisa berubah)
```

### FloatingActionButton untuk menambah barang

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahBelanjaPage()),
    );
  },
  child: const Icon(Icons.add),
),
```

Tombol bulat melayang di pojok kanan bawah (properti milik `Scaffold`). Saat ditekan, `Navigator.push` membuka `TambahBelanjaPage`. Ini sama dengan konsep push di modul navigasi, tapi kali ini tidak ada data yang dikirim, karena data akan disimpan lewat Provider.

---

## Bagian 5: Halaman Form Input

### Kenapa StatefulWidget?

```dart
class TambahBelanjaPage extends StatefulWidget {
  const TambahBelanjaPage({super.key});

  @override
  State<TambahBelanjaPage> createState() => _TambahBelanjaPageState();
}
```

Berbeda dari halaman sebelumnya yang `StatelessWidget`, halaman ini punya data yang berubah saat dipakai (kategori yang dipilih dan status checkbox), jadi butuh `StatefulWidget`. Strukturnya terbagi dua class: class widget dan class `State` (`_TambahBelanjaPageState`) tempat data dan `build` berada.

Ringkasannya:

| Jenis | Tampilan | Contoh di aplikasi ini |
|-------|----------|------------------------|
| `StatelessWidget` | tetap | `MyApp`, `DaftarBelanjaPage` |
| `StatefulWidget` | bisa berubah dari dalam | `TambahBelanjaPage` |

Catatan: `DaftarBelanjaPage` tetap stateless walaupun tampilannya berubah, karena datanya tidak disimpan di dalam widget itu, melainkan di Provider.

### Variabel yang disiapkan

```dart
final _formKey = GlobalKey<FormState>();
final _namaController = TextEditingController();
final _jumlahController = TextEditingController();

String? _kategoriPilihan;
bool _setuju = false;

final List<String> _kategoriList = ['Makanan', 'Minuman', 'Kebutuhan Rumah', 'Lainnya'];
```

| Variabel | Fungsi |
|----------|--------|
| `_formKey` | kunci untuk mengakses `Form`, terutama untuk menjalankan validasi |
| `_namaController` | mengambil teks yang diketik pada kolom nama |
| `_jumlahController` | mengambil teks yang diketik pada kolom jumlah |
| `_kategoriPilihan` | kategori yang sedang dipilih di dropdown |
| `_setuju` | status checkbox persetujuan |
| `_kategoriList` | daftar pilihan untuk dropdown |

Tanda `?` pada `String?` berarti nilainya boleh `null`. Awalnya belum ada kategori yang dipilih, jadi nilainya `null`.

### dispose

```dart
@override
void dispose() {
  _namaController.dispose();
  _jumlahController.dispose();
  super.dispose();
}
```

`TextEditingController` memakai memori selama halaman aktif. Saat halaman ditutup, `dispose()` dipanggil untuk melepaskannya supaya tidak terjadi kebocoran memori. Ini kebiasaan yang perlu dilakukan setiap kali membuat controller.

### Form dan ListView

```dart
body: Form(
  key: _formKey,
  child: ListView(
    padding: const EdgeInsets.all(16),
    children: [
      ...
    ],
  ),
),
```

`Form` membungkus semua input supaya bisa divalidasi sekaligus lewat `_formKey`. Isinya memakai `ListView` biasa (bukan `.builder`) karena jumlah itemnya tetap, dan sekaligus agar layar bisa di-scroll saat keyboard muncul.

### Input 1: Nama barang

```dart
TextFormField(
  controller: _namaController,
  decoration: const InputDecoration(
    labelText: 'Nama Barang',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama barang wajib diisi';
    }
    return null;
  },
),
```

- `controller` menghubungkan kolom dengan `_namaController`.
- `decoration` mengatur label dan border kolom.
- `validator` adalah fungsi pemeriksa. Aturannya: kalau fungsi mengembalikan teks, teks itu tampil sebagai pesan error. Kalau mengembalikan `null`, artinya input valid.
- `value.trim().isEmpty` memastikan input yang hanya berisi spasi juga dianggap kosong.

### Input 2: Jumlah barang

```dart
TextFormField(
  controller: _jumlahController,
  keyboardType: TextInputType.number,
  ...
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah wajib diisi';
    }
    final jumlah = int.tryParse(value);
    if (jumlah == null || jumlah <= 0) {
      return 'Masukkan angka positif yang valid';
    }
    return null;
  },
),
```

- `keyboardType: TextInputType.number` memunculkan keyboard angka.
- Validasinya dua lapis: pertama cek kosong, kedua cek apakah benar angka positif.
- **`int.tryParse(value)`** mencoba mengubah teks menjadi angka. Kalau gagal (misalnya diisi "abc"), hasilnya `null` dan tidak error. Bedanya dengan `int.parse`, yang akan melempar error kalau teksnya bukan angka.

### Input 3: Dropdown kategori

```dart
DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Kategori',
    border: OutlineInputBorder(),
  ),
  value: _kategoriPilihan,
  items: _kategoriList.map((String kategori) {
    return DropdownMenuItem<String>(
      value: kategori,
      child: Text(kategori),
    );
  }).toList(),
  onChanged: (newValue) {
    setState(() {
      _kategoriPilihan = newValue;
    });
  },
  validator: (value) => value == null ? 'Pilih kategori barang' : null,
),
```

- `<String>` menunjukkan tipe nilai pilihannya adalah teks.
- **`items`** berisi daftar pilihan. `_kategoriList.map(...)` mengubah setiap teks di list menjadi widget `DropdownMenuItem`, lalu `.toList()` mengembalikannya menjadi list. Pola ini mirip `ListView.builder`: data diubah menjadi widget.
- **`onChanged`** dipanggil saat pengguna memilih sesuatu. Di dalamnya ada `setState`, supaya Flutter menggambar ulang dengan nilai baru. Ini bagian yang pas dikerjakan `setState`, karena datanya hanya dipakai di halaman form ini.
- **`validator`** memastikan kategori sudah dipilih: kalau masih `null`, tampilkan pesan error.

### Input 4: Checkbox persetujuan

```dart
CheckboxListTile(
  title: const Text('Data yang saya masukkan sudah benar'),
  value: _setuju,
  controlAffinity: ListTileControlAffinity.leading,
  onChanged: (bool? value) {
    setState(() {
      _setuju = value ?? false;
    });
  },
),
```

- `CheckboxListTile` adalah checkbox sekaligus teksnya dalam satu baris (gabungan `Checkbox` dan `ListTile`).
- `controlAffinity: ListTileControlAffinity.leading` memindahkan checkbox ke sisi kiri.
- `value ?? false` artinya: kalau `value` bernilai `null`, pakai `false`. Perlu ditulis karena tipe `bool?` boleh `null`.

### Tombol simpan yang bisa nonaktif

```dart
ElevatedButton(
  onPressed: _setuju ? _simpanData : null,
  child: const Text('Simpan Ke Daftar'),
),
```

Kalau `onPressed` diisi `null`, tombol otomatis nonaktif (abu-abu dan tidak bisa ditekan). Jadi tombolnya hanya aktif kalau checkbox sudah dicentang:

```
_setuju = false  ->  onPressed = null          ->  tombol mati
_setuju = true   ->  onPressed = _simpanData   ->  tombol aktif
```

Perhatikan bahwa ditulis `_simpanData` tanpa kurung. Artinya kita memberikan fungsinya, bukan menjalankannya langsung.

### Method _simpanData

```dart
void _simpanData() {
  if (_formKey.currentState!.validate()) {
    context.read<BelanjaModel>().tambahBarang(
          _namaController.text.trim(),
          int.parse(_jumlahController.text.trim()),
          _kategoriPilihan!,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barang berhasil ditambahkan!')),
    );

    Navigator.pop(context);
  }
}
```

Urutan kerjanya:

```
Tekan "Simpan Ke Daftar"
        │
        ▼
validate() menjalankan semua validator
        │
   ┌────┴─────┐
 gagal       lolos
   │           │
 pesan error   ├── tambahBarang() lewat Provider
 tampil        ├── tampilkan SnackBar
               └── Navigator.pop() kembali ke daftar
```

- **`_formKey.currentState!.validate()`** menjalankan semua `validator`. Hasilnya `true` kalau semua lolos. Tanda `!` artinya saya yakin nilainya tidak `null`.
- **`context.read<BelanjaModel>()`** dipakai (bukan `watch`) karena ini di dalam fungsi aksi, bukan di `build`.
- **`int.parse(...)`** aman dipakai di sini karena validator sudah memastikan isinya angka valid.
- **`_kategoriPilihan!`** juga aman karena validator dropdown sudah memastikan tidak `null`.
- **`SnackBar`** adalah pesan singkat di bawah layar. Ditampilkan lewat `ScaffoldMessenger`.
- **`Navigator.pop(context)`** kembali ke halaman daftar. Karena data sudah masuk ke Provider, daftar otomatis menampilkan barang baru tanpa perlu mengirim data balik.

Ini perbedaan dibandingkan modul kontak sebelumnya. Di sana data dikirim lewat parameter ke halaman berikutnya. Di sini data tidak perlu dikirim ke mana-mana, karena kedua halaman membaca model yang sama.

---

## Ringkasan Alur Aplikasi

```
Aplikasi dibuka
      │
      ▼
ChangeNotifierProvider membuat BelanjaModel
      │
      ▼
DaftarBelanjaPage (watch) ── daftar kosong ── teks "Belum ada daftar belanjaan"
      │
      │ tekan tombol +
      ▼
TambahBelanjaPage (form)
      │
      │ isi form, centang persetujuan, tekan simpan
      ▼
validate -> tambahBarang -> notifyListeners -> pop
      │
      ▼
DaftarBelanjaPage otomatis menampilkan barang baru
```

## Poin yang Perlu Diingat

| Konsep | Intinya |
|--------|---------|
| `ChangeNotifier` | class data yang bisa memberi kabar saat berubah |
| `notifyListeners()` | wajib dipanggil setiap data berubah, kalau tidak layar tidak ikut berubah |
| `ChangeNotifierProvider` | menyediakan model ke seluruh widget di bawahnya |
| `context.watch` | baca data dan rebuild saat berubah (dipakai di `build`) |
| `context.read` | baca tanpa rebuild (dipakai di callback aksi) |
| `_` di depan nama | private, hanya bisa diakses dari dalam class |
| `List.unmodifiable` | mengembalikan list yang tidak bisa diubah dari luar |
| `where(...)` | menyaring item sesuai syarat |
| ternary `a ? b : c` | if-else versi singkat |
| `StatefulWidget` | widget yang punya data berubah dari dalam |
| `setState` | memberi tahu Flutter untuk menggambar ulang widget stateful |
| `Form` + `GlobalKey` | membungkus input agar bisa divalidasi sekaligus |
| `validator` | mengembalikan pesan error kalau tidak valid, `null` kalau valid |
| `TextEditingController` | mengambil isi kolom teks, harus di-`dispose` |
| `int.tryParse` | mengubah teks jadi angka tanpa error, hasilnya `null` kalau gagal |
| `onPressed: null` | membuat tombol nonaktif |
| `Navigator.pop` | kembali ke halaman sebelumnya |

## Hal yang Mau Saya Coba Sendiri

- Hapus `notifyListeners()` di `toggleStatus`, lalu lihat apa yang terjadi saat checkbox ditekan.
- Ganti `context.watch` di `DaftarBelanjaPage` dengan `context.read`, dan amati apakah daftar masih ikut berubah.
- Isi kolom jumlah dengan "abc", dengan 0, dan dengan angka negatif, lalu lihat pesan validasinya.
- Tambahkan satu kategori baru ke `_kategoriList`.
- Coba tulis `items.add(...)` dari luar `BelanjaModel` untuk melihat error dari `List.unmodifiable`.