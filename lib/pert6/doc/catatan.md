# Catatan Flutter Pertemuan 6: Tema, Routing, Navigasi, dan Animasi

Catatan ini merangkum apa yang dipelajari saat mengerjakan **Tugas Galeri/Katalog Interaktif** (tema: Katalog Wisata Indonesia).

## Tujuan Pembelajaran

Setelah mempelajari catatan ini, Anda diharapkan mampu:

1. Membuat tema terang/gelap dan warna tema yang dapat diganti pengguna.
2. Memakai `Theme.of(context)` sebagai pengganti warna yang ditulis manual.
3. Menerapkan *named routes*, mengirim argumen, dan memakai `onGenerateRoute`.
4. Membuat navigasi tab bawah dengan `NavigationBar` dan `IndexedStack`.
5. Membuat animasi implisit, transisi `Hero`, dan animasi eksplisit.
6. Menyimpan pengaturan agar tetap ada setelah aplikasi ditutup.

## Daftar Isi

1. [Gambaran Tugas dan Struktur Proyek](#1-gambaran-tugas-dan-struktur-proyek)
2. [Tema Terang/Gelap dan Warna Tema](#2-tema-teranggelap-dan-warna-tema)
3. [Named Routes dan Argumen](#3-named-routes-dan-argumen)
4. [Navigasi Tab Bawah](#4-navigasi-tab-bawah)
5. [Hero](#5-hero)
6. [Animasi Implisit dan Eksplisit](#6-animasi-implisit-dan-eksplisit)
7. [Menyimpan Pengaturan](#7-menyimpan-pengaturan)
8. [Troubleshooting](#8-troubleshooting)
9. [Jawaban Pertanyaan Refleksi](#9-jawaban-pertanyaan-refleksi)
10. [Cara Menjalankan](#10-cara-menjalankan)

---

## 1. Gambaran Tugas dan Struktur Proyek

Ketentuan tugas dan cara pemenuhannya:

| Ketentuan | Pemenuhan pada aplikasi |
|---|---|
| Minimal 3 tab dengan `NavigationBar` | Beranda, Favorit, Pengaturan |
| Named routes dengan argumen, detail memakai Hero | Rute `/detail` menerima objek `DetailArgs`; ikon tempat memakai `Hero` |
| Satu animasi implisit dan satu eksplisit | Implisit: `AnimatedContainer`, `AnimatedSwitcher`. Eksplisit: `AnimationController` (ikon hati berdenyut) |
| Tema terang/gelap, minimal 3 warna, tersimpan | 4 pilihan warna dan saklar mode gelap, disimpan dengan `shared_preferences` |
| Warna dan gaya teks dari `Theme.of(context)` | Seluruh warna widget berasal dari `colorScheme` dan `textTheme` |

Struktur berkas pada folder `lib/`:

```text
lib/
├── main.dart            // MaterialApp, tema, routes, onGenerateRoute
├── app_state.dart       // state global (tema, warna, favorit) + penyimpanan
├── tempat.dart          // model Tempat dan data katalog
├── rute.dart            // nama rute dan kelas DetailArgs
├── shell_page.dart      // NavigationBar + IndexedStack
├── tab_beranda.dart
├── tab_favorit.dart
├── tab_pengaturan.dart
├── tempat_tile.dart     // satu baris tempat (dipakai Beranda dan Favorit)
└── detail_page.dart     // halaman detail + animasi
```

Pemisahan ini mengikuti prinsip yang sama seperti Pertemuan 4: **data, logika, dan tampilan dipisahkan** agar mudah dirawat.

---

## 2. Tema Terang/Gelap dan Warna Tema

### Konsep

- `ThemeData` menyimpan seluruh gaya aplikasi (warna, tipografi, gaya komponen).
- Dengan Material 3, cukup menentukan satu **seed color** (`colorSchemeSeed`), dan Flutter menghasilkan seluruh palet warna.
- `MaterialApp` menerima tiga properti:

| Properti | Fungsi |
|---|---|
| `theme` | Tema terang |
| `darkTheme` | Tema gelap |
| `themeMode` | Pilihan mode: `system`, `light`, atau `dark` |

### Cara Kerja pada Aplikasi

Pilihan tema disimpan dalam dua `ValueNotifier`. Widget `ListenableBuilder` membangun ulang `MaterialApp` setiap kali salah satunya berubah.

```dart
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final indeksWarna = ValueNotifier<int>(0);

ListenableBuilder(
  listenable: Listenable.merge([themeMode, indeksWarna]),
  builder: (context, _) {
    return MaterialApp(
      theme: buatTema(seedColor, Brightness.light),
      darkTheme: buatTema(seedColor, Brightness.dark),
      themeMode: themeMode.value,
      // ...
    );
  },
);
```

**Penjelasan:**

- `ValueNotifier` adalah "kotak" berisi nilai yang dapat dipantau. Saat `.value` diubah, para pendengar diberi tahu.
- `Listenable.merge([...])` menggabungkan beberapa notifier sehingga satu `ListenableBuilder` dapat memantau keduanya.
- Nilai harus diubah melalui `.value = ...`. Jika memakai variabel biasa, tampilan tidak akan berubah.

### Memakai Nilai dari Tema

Widget **tidak boleh** menulis warna secara manual. Ambil nilainya dari tema:

```dart
final tema = Theme.of(context);
final skema = tema.colorScheme;

CircleAvatar(
  backgroundColor: skema.primaryContainer,
  foregroundColor: skema.onPrimaryContainer,
  child: Icon(tempat.ikon),
);

Text('Judul', style: tema.textTheme.headlineMedium);
```

Beberapa peran warna yang sering dipakai:

| Peran | Kegunaan |
|---|---|
| `primary` / `onPrimary` | Warna utama dan warna di atasnya (teks atau ikon) |
| `primaryContainer` / `onPrimaryContainer` | Latar lembut berwarna tema dan isinya |
| `surface` / `onSurface` | Latar halaman dan teks utama |
| `onSurfaceVariant` | Teks pendukung (lebih redup) |
| `surfaceContainerHighest` | Latar netral untuk kartu atau *chip* |

**Keuntungan** memakai tema: warna otomatis menyesuaikan saat pindah ke mode gelap, kontras teks tetap terjaga, dan seluruh aplikasi konsisten.

> **Pengecualian wajar:** lingkaran pilihan warna di tab Pengaturan memang memakai warna tetap, karena itulah data yang ditawarkan kepada pengguna.

---

## 3. Named Routes dan Argumen

### Konsep

Halaman diberi nama sehingga navigasi lebih rapi dan terpusat.

| Method | Fungsi |
|---|---|
| `pushNamed(ctx, '/detail', arguments: x)` | Membuka halaman bernama sambil membawa argumen |
| `pop(ctx)` | Menutup halaman saat ini |
| `pushReplacementNamed(...)` | Mengganti halaman saat ini (tidak dapat kembali), misalnya dari login ke beranda |
| `pushNamedAndRemoveUntil(...)` | Membuka halaman baru sambil menghapus riwayat sebelumnya |

### Penerapan

**1. Nama rute dikumpulkan di satu tempat** agar tidak salah ketik:

```dart
class Rute {
  static const beranda = '/';
  static const detail = '/detail';
}
```

**2. Argumen dibungkus dalam kelas sendiri** agar tipenya jelas:

```dart
class DetailArgs {
  final Tempat tempat;
  final String heroTag;
  const DetailArgs({required this.tempat, required this.heroTag});
}
```

**3. Rute tanpa argumen** didaftarkan di `routes`. **Rute dengan argumen** ditangani `onGenerateRoute`:

```dart
routes: {
  Rute.beranda: (_) => const ShellPage(),
},
onGenerateRoute: (settings) {
  if (settings.name == Rute.detail) {
    final args = settings.arguments;
    if (args is DetailArgs) {
      return PageRouteBuilder<void>(
        settings: settings,
        pageBuilder: (_, __, ___) => DetailPage(args: args),
        transitionsBuilder: (_, animasi, __, child) =>
            FadeTransition(opacity: animasi, child: child),
      );
    }
  }
  return null; // rute tidak dikenali → onUnknownRoute
},
onUnknownRoute: (settings) => MaterialPageRoute(
  builder: (_) => HalamanTidakDitemukan(nama: settings.name),
),
```

**4. Membuka halaman dari daftar:**

```dart
Navigator.pushNamed(
  context,
  Rute.detail,
  arguments: DetailArgs(tempat: tempat, heroTag: tag),
);
```

**Hal yang dipelajari:**

- `args is DetailArgs` memeriksa tipe argumen **di satu tempat**, sehingga lebih aman daripada `as` yang langsung error bila tipenya keliru.
- `PageRouteBuilder` memungkinkan transisi halaman kustom (di sini `FadeTransition`).
- `onUnknownRoute` menjadi "jaring pengaman" untuk rute yang tidak terdaftar.
- Untuk aplikasi besar dengan *deep link* dan web, biasanya dipakai paket `go_router`; prinsip named routes ini menjadi dasarnya.

---

## 4. Navigasi Tab Bawah

`ShellPage` menampung tiga tab. `NavigationBar` menampilkan menu di bawah, sedangkan `IndexedStack` menampilkan tab sesuai indeks:

```dart
Scaffold(
  appBar: AppBar(title: Text(_judul[_index])),
  body: IndexedStack(index: _index, children: _halaman),
  bottomNavigationBar: NavigationBar(
    selectedIndex: _index,
    onDestinationSelected: (i) => setState(() => _index = i),
    destinations: const [ /* NavigationDestination ... */ ],
  ),
);
```

**Mengapa `IndexedStack`?** Semua tab tetap hidup di memori, sehingga posisi *scroll* dan state tiap tab tidak hilang saat berpindah.

**Perbedaan dengan `Navigator`:**

| | `IndexedStack` (tab) | `Navigator` (halaman) |
|---|---|---|
| Sifat | Berpindah antar bagian yang setara | Menumpuk halaman baru di atas yang lama |
| Tombol kembali | Tidak ada riwayat | Ada, halaman teratas dilepas |
| State halaman lain | Tetap hidup | Halaman di bawah tetap ada, tetapi tertutup |

---

## 5. Hero

`Hero` membuat sebuah elemen tampak "terbang" mulus dari satu halaman ke halaman lain.

```dart
// Halaman daftar
Hero(tag: tag, child: CircleAvatar(...));

// Halaman detail
Hero(tag: widget.args.heroTag, child: CircleAvatar(radius: 64, ...));
```

**Aturan penting:**

1. **Tag harus sama** di kedua halaman agar Flutter mengenali pasangannya.
2. **Tag harus unik** dalam satu halaman. Bila ada dua `Hero` dengan tag yang sama di halaman yang sama, Flutter menampilkan error.

**Masalah yang perlu diantisipasi:** tab Beranda dan Favorit dapat menampilkan tempat yang sama, dan `IndexedStack` menjaga keduanya tetap hidup. Jika tag hanya memakai id tempat, tag berpotensi bentrok. Solusinya, tag diberi **awalan sumber tab**:

```dart
final tag = 'ikon-$sumber-${tempat.id}'; // contoh: ikon-beranda-bromo
```

Tag ini kemudian dikirim ke halaman detail melalui `DetailArgs`, sehingga detail selalu memakai tag yang tepat sesuai asal tab.

---

## 6. Animasi Implisit dan Eksplisit

### Perbandingan

| Jenis | Widget/kelas | Kapan dipakai |
|---|---|---|
| Implisit | `AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher` | Cukup ubah nilai lewat `setState` (atau rebuild); Flutter yang menganimasikan |
| Transisi Hero | `Hero` | Elemen berpindah mulus antar dua halaman |
| Eksplisit | `AnimationController` + `ScaleTransition`, `RotationTransition`, dll. | Butuh kontrol penuh: ulang, berhenti, urutan, sinkronisasi |

### Animasi Implisit pada Aplikasi

**`AnimatedContainer`** pada label status favorit. Saat nilai `fav` berubah, warna dan sudut berubah dengan halus:

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  decoration: BoxDecoration(
    color: fav ? skema.primaryContainer : skema.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(fav ? 24 : 8),
  ),
  child: Text(fav ? 'Ada di Favorit' : 'Belum difavoritkan'),
);
```

**`AnimatedSwitcher`** pada ikon hati. Ikon lama mengecil dan ikon baru membesar:

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 250),
  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
  child: Icon(
    fav ? Icons.favorite : Icons.favorite_border,
    key: ValueKey(fav), // key harus berbeda tiap perubahan
  ),
);
```

> `AnimatedSwitcher` mengenali bahwa anaknya "berganti" melalui **key**. Tanpa key yang berbeda, Flutter menganggap widget-nya sama sehingga tidak ada animasi.

### Animasi Eksplisit pada Aplikasi

Ikon hati "berdenyut" setiap kali tombol ditekan. Animasi dikendalikan sendiri lewat `AnimationController`:

```dart
class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _denyut;
  late final Animation<double> _skala;

  @override
  void initState() {
    super.initState();
    _denyut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _skala = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
    ]).animate(_denyut);
  }

  @override
  void dispose() {
    _denyut.dispose();
    super.dispose();
  }
}
```

Animasi dijalankan dengan `_denyut.forward(from: 0)` dan ditampilkan lewat `ScaleTransition(scale: _skala, ...)`.

**Hal yang dipelajari:**

- `vsync: this` memerlukan `SingleTickerProviderStateMixin` pada state class. Bila tidak ada, muncul error *vsync / TickerProvider*.
- `TweenSequence` merangkai beberapa tahap animasi (membesar lalu mengecil) dalam satu controller.
- `AnimationController` **wajib di-`dispose()`**, kalau tidak, ia terus berjalan dan memboroskan memori.

---

## 7. Menyimpan Pengaturan

Paket `shared_preferences` menyimpan data kecil (bool, int, String, daftar String) di perangkat.

```bash
flutter pub add shared_preferences
```

Alur yang dipakai:

1. `main()` dibuat `async` dan memanggil `WidgetsFlutterBinding.ensureInitialized()` karena plugin dipakai **sebelum** `runApp()`.
2. `muatPengaturan()` membaca nilai tersimpan lalu mengisi notifier.
3. Setiap perubahan (mode gelap, warna, favorit) langsung ditulis kembali.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await muatPengaturan();
  runApp(const MyApp());
}

Future<void> ubahModeGelap(bool gelap) async {
  themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light; // UI langsung berubah
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('mode_gelap', gelap);                   // lalu disimpan
}
```

**Catatan penting:**

- Warna disimpan sebagai **indeks** dalam daftar pilihan (`0`, `1`, ...), bukan sebagai objek `Color`. Lebih sederhana dan aman.
- Saat memuat, indeks diperiksa agar tetap berada dalam rentang yang valid. Hal ini mencegah crash bila data tersimpan rusak atau daftar warna berubah.
- Daftar favorit memakai `Set<String>` (kumpulan id). Saat mengubahnya, **buat Set baru** (`Set.of(...)`) agar `ValueNotifier` mendeteksi perubahan. Mengubah isi Set yang sama tidak memicu pembaruan tampilan.

---

## 8. Troubleshooting

| Masalah | Solusi |
|---|---|
| `Could not find a generator for route` | Nama rute salah ketik atau belum ditangani di `routes` / `onGenerateRoute` |
| Hero tidak beranimasi | Pastikan tag sama di kedua halaman |
| Error "multiple heroes share the same tag" | Tag bentrok di halaman yang sama; beri awalan unik (misalnya nama tab) |
| Tema tidak berubah saat saklar digeser | Pastikan `MaterialApp` dibungkus `ListenableBuilder` dan nilai diubah lewat `.value` |
| Sebagian warna tidak ikut mode gelap | Warna ditulis manual; ganti dengan `Theme.of(context).colorScheme` |
| `AnimatedContainer` tidak beranimasi | Nilai harus benar-benar berubah, dan kedua nilai bertipe sama |
| `AnimatedSwitcher` tidak beranimasi | Anak harus punya `key` yang berbeda tiap perubahan (misalnya `ValueKey`) |
| Error vsync / TickerProvider | Tambahkan `with SingleTickerProviderStateMixin` pada state class |
| Pengaturan tidak tersimpan / plugin error | Pastikan `WidgetsFlutterBinding.ensureInitialized()` ada di `main()`, lalu jalankan ulang aplikasi sepenuhnya (bukan hot reload) setelah menambah paket |
| Favorit tidak ter-update | Set diubah di tempat; buat Set baru sebelum mengisi ke `ValueNotifier` |

---

## 9. Jawaban Pertanyaan Refleksi

**1. Apa perbedaan animasi implisit dan eksplisit? Kapan memilih masing-masing?**
Pada animasi implisit, kita hanya mengubah nilai tujuan (misalnya lebar atau warna), dan Flutter mengurus perpindahannya. Pada animasi eksplisit, kita membuat dan mengendalikan `AnimationController` sendiri. Pilih implisit untuk perubahan sederhana dari satu keadaan ke keadaan lain. Pilih eksplisit bila perlu mengulang, menghentikan, menyusun urutan, atau menyinkronkan beberapa animasi.

**2. Mengapa dua Hero harus memiliki tag yang sama, dan apa yang terjadi bila tag muncul dua kali di halaman yang sama?**
Tag adalah cara Flutter memasangkan elemen di halaman asal dengan elemen di halaman tujuan. Jika tag muncul dua kali di satu halaman, Flutter tidak dapat menentukan pasangan yang tepat sehingga menampilkan error.

**3. Apa keuntungan memakai `Theme.of(context)` dibanding menulis warna langsung?**
Warna dan gaya terpusat di satu tempat. Saat tema atau mode berubah, seluruh widget menyesuaikan otomatis, kontras teks tetap terjaga, dan tampilan konsisten.

**4. Apa perbedaan berpindah tab dengan `IndexedStack` dan membuka halaman dengan `Navigator`?**
`IndexedStack` berpindah antar bagian yang setara dan menjaga state semua tab tetap hidup, tanpa riwayat kembali. `Navigator` menumpuk halaman baru di atas halaman sebelumnya, dan tombol kembali melepas halaman paling atas.

**5. Mengapa `AnimationController` wajib di-`dispose`?**
Controller memakai *ticker* yang terus berjalan mengikuti frame layar. Jika tidak dibuang saat widget dihapus, ticker tetap aktif sehingga memboroskan sumber daya dan dapat menimbulkan error.

---

## 10. Cara Menjalankan

```bash
flutter create praktikum_6
cd praktikum_6
flutter pub add shared_preferences
```

Kemudian ganti seluruh isi folder `lib/` dengan berkas dari proyek ini, lalu jalankan:

```bash
flutter run
```

Untuk pengumpulan tugas, siapkan tangkapan layar **mode terang**, **mode gelap**, dan **halaman detail**, beserta berkas kode (atau tautan repositori).