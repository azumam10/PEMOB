# Catatan Flutter: Mengambil Data dari REST API

## Tujuan Pembelajaran

Setelah mempelajari catatan ini, Anda diharapkan mampu membuat aplikasi Flutter yang:

1. Mengambil data dari REST API melalui internet.
2. Menampilkan data tersebut dengan tata letak yang rapi.
3. Menangani kondisi *loading* (saat data sedang diambil).
4. Menangani kondisi *error* (misalnya koneksi internet terputus atau URL salah).
5. Menyediakan tombol "Coba lagi" apabila pengambilan data gagal.
6. Berpindah dari halaman daftar ke halaman detail.
7. Memisahkan kode ke dalam *model*, *service*, dan UI secara terstruktur.

---

## Daftar Isi

1. [Konsep Dasar: Asinkron, Future, async/await](#1-konsep-dasar)
2. [REST API dan JSON](#2-rest-api-dan-json)
3. [Model Class](#3-model-class)
4. [API Service](#4-api-service)
5. [FutureBuilder](#5-futurebuilder)
6. [Navigasi dan Pengiriman Data Antarhalaman](#6-navigasi)

---

## 1. Konsep Dasar

### Apa Itu Flutter?

Flutter adalah *framework* untuk membuat aplikasi mobile (Android dan iOS), web, serta desktop dengan satu bahasa pemrograman, yaitu **Dart**. Kode cukup ditulis sekali, lalu dapat dijalankan di berbagai platform.

Di dalam Flutter, semua yang terlihat di layar, seperti teks, gambar, dan tombol, disebut **widget**.

> **Kapan Flutter sebaiknya digunakan?**
> Ketika Anda menginginkan tampilan aplikasi yang konsisten di Android dan iOS tanpa harus menulis kode dua kali.

### Apa Itu Pemrograman Asinkron?

Sebagai gambaran, bayangkan Anda sedang memasak air. Setelah kompor dinyalakan, Anda tidak perlu menunggu air mendidih. Anda dapat memotong bawang dan menyiapkan bumbu terlebih dahulu. Ketika air mendidih, Anda akan mengetahuinya.

Pemrograman **asinkron** bekerja dengan prinsip yang sama: program dapat mengerjakan hal lain sambil menunggu proses yang memakan waktu. Tanpa konsep ini, aplikasi akan *freeze* (tidak merespons) selama menunggu data dari internet.

### Future: Janji yang Akan Dipenuhi

**Future** adalah objek yang berisi janji bahwa hasil akan diberikan di kemudian waktu.

Analogi: Anda memesan kopi di kafe dan menerima struk. Struk tersebut bukan kopinya, melainkan bukti bahwa kopi akan diantar.

Sebuah Future memiliki tiga status:

| Status | Arti | Tampilan yang Sesuai |
|---|---|---|
| Waiting | Masih diproses | Indikator loading |
| Data | Berhasil, hasil tersedia | Data ditampilkan |
| Error | Gagal | Pesan kesalahan |

### async dan await

- **`async`** menandakan bahwa sebuah fungsi boleh menggunakan `await` dan akan selalu mengembalikan `Future`.
- **`await`** berarti "tunggu di sini sampai hasilnya siap". Kata kunci ini hanya dapat digunakan di dalam fungsi `async`.

```dart
Future<String> ambilSalam() async {
  await Future.delayed(const Duration(seconds: 2)); // menunggu 2 detik
  return 'Halo dari masa depan!';
}
```

Keduanya harus digunakan bersamaan karena `await` memerlukan `async`. Jika `await` ditulis di fungsi non-async, kompiler akan menampilkan pesan kesalahan.

### Mengapa Future Dibuat di `initState()`, Bukan di `build()`?

**Alasan 1.** Method `build()` dapat dipanggil berkali-kali, misalnya saat keyboard muncul, layar diputar, atau ada animasi. Jika Future dibuat di dalamnya, permintaan ke API akan terulang terus-menerus. Akibatnya kuota dan baterai terbuang, serta tampilan berkedip (loading muncul kembali padahal data sudah ada).

**Alasan 2.** Method `initState()` hanya dipanggil **satu kali** selama widget hidup, sehingga permintaan ke API pun hanya berjalan sekali. Apabila data perlu diperbarui, panggil ulang secara manual, misalnya melalui tombol.

---

## 2. REST API dan JSON

### Apa Itu REST API?

REST API adalah cara aplikasi berkomunikasi dengan server. Aplikasi mengirim **HTTP request** (misalnya `GET`) ke sebuah URL, lalu server membalas dengan data.

Kode status HTTP yang perlu diketahui:

| Kode | Arti |
|---|---|
| 200 | Berhasil, data tersedia |
| 404 | Tidak ditemukan (biasanya URL salah) |
| 500 | Kesalahan pada server |

### Apa Itu JSON?

JSON adalah format data yang berbentuk seperti kamus (*Map*) atau daftar (*List*). Contoh:

```json
{
  "id": 1,
  "name": "Budi",
  "email": "budi@mail.com"
}
```

Di dalam Dart, data ini menjadi `Map<String, dynamic>`: *key*-nya bertipe `String`, sedangkan *value*-nya dapat bertipe apa saja.

### Paket `http`

Untuk mengirim permintaan HTTP, diperlukan paket `http`. Cara menambahkannya:

```bash
flutter pub add http
```

**Penting untuk Android:** tambahkan izin internet pada berkas `android/app/src/main/AndroidManifest.xml`, di dalam tag `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Tanpa izin ini, aplikasi tidak dapat mengakses internet di perangkat Android. Pada emulator izin ini biasanya sudah aktif otomatis, tetapi tetap sebaiknya dituliskan.

---

## 3. Model Class

### Apa Itu Model Class?

Model class adalah **cetakan data**. Analoginya seperti formulir data pengguna yang memiliki kolom `id`, `name`, `email`, dan seterusnya.

### Mengapa Perlu Model Class?

Jika kita memakai `Map` secara langsung (misalnya `data['nama']`), beberapa masalah dapat muncul:

1. **Tidak aman.** Salah ketik seperti `data['namae']` baru ketahuan saat aplikasi dijalankan.
2. **Tidak jelas.** Editor tidak mengetahui tipe datanya, apakah `data['id']` berupa `int` atau `String`.
3. **Tidak rapi.** Kode menjadi sulit dibaca dan dirawat.

Dengan model class:

- **Type-safe.** Editor mengetahui bahwa `pengguna.name` bertipe `String`. Jika salah ketik, kesalahan langsung terdeteksi sebelum aplikasi berjalan.
- **Rapi.** Struktur data menjadi jelas.
- **Sesuai standar industri.** Ini adalah praktik yang umum digunakan.

### Contoh Model Class

```dart
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
```

**Penjelasan:**

- `final int id;` adalah properti class. Kata `final` berarti nilainya tidak dapat diubah setelah objek dibuat.
- `const Post({...})` adalah konstruktor. Kata `required` berarti parameter tersebut wajib diisi.
- `factory Post.fromJson(...)` berfungsi sebagai "penerjemah". Data dari internet berbentuk `Map`, dan fungsi ini mengubahnya menjadi objek `Post`.
- `json['id'] as int` mengambil nilai dari *key* `'id'` dan memastikan tipenya `int`. Jika tipenya tidak cocok, Dart akan menampilkan error.

### Aturan Penamaan dan Penulisan

| Elemen | Aturan | Contoh |
|---|---|---|
| Nama file | huruf kecil dengan garis bawah | `model.dart`, `halaman_detail.dart` |
| Nama class | UpperCamelCase | `Post`, `HalamanPostingan` |
| Nama variabel/fungsi | lowerCamelCase | `ambilPostingan`, `postId` |

Selain itu, **model class tidak boleh mengimpor Flutter**. Model hanya berfungsi sebagai wadah data sehingga tidak membutuhkan widget.

---

## 4. API Service

### Apa Itu API Service?

API Service adalah berkas yang berisi seluruh logika pengambilan data dari API. Semua pemanggilan `http.get`, `jsonDecode`, dan `fromJson` berada di sini. **UI tidak perlu mengetahui detail tersebut.**

### Mengapa Dipisahkan dari UI?

1. **Perubahan lebih mudah.** Jika URL API berubah, Anda hanya perlu mengubah satu berkas, tanpa menyentuh kode UI.
2. **Kode UI lebih bersih.** UI cukup berfokus pada tampilan, bukan pada urusan permintaan HTTP.
3. **Dapat dipakai ulang.** Jika `ambilPostingan()` digunakan di tiga halaman, fungsi tersebut tidak perlu ditulis tiga kali.

### Contoh API Service

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration _timeout = Duration(seconds: 10);

  static Future<List<Post>> ambilPostingan() async {
    final uri = Uri.parse('$_baseUrl/posts');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat postingan (Kode: ${response.statusCode})');
    }
  }

  static Future<List<Komentar>> ambilKomentar(int postId) async {
    final uri = Uri.parse('$_baseUrl/posts/$postId/comments');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Komentar.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat komentar (Kode: ${response.statusCode})');
    }
  }
}
```

**Penjelasan bagian penting:**

- `static const String _baseUrl = '...';` adalah konstanta privat (ditandai `_` di depan nama). Jika URL berubah, cukup ubah di satu tempat.
- `static const Duration _timeout = Duration(seconds: 10);` adalah batas waktu yang ditetapkan sebagai konstanta agar konsisten.
- `http.get(uri).timeout(_timeout)` mengirim permintaan dengan batas waktu 10 detik. Jika melebihi batas, permintaan dianggap gagal.
- `'$_baseUrl/posts/$postId/comments'` menggunakan *string interpolation*. Nilai `$postId` akan digantikan oleh isi variabelnya. Misalnya, jika `postId = 1`, URL menjadi `.../posts/1/comments`.
- `jsonDecode(response.body)` mengubah teks JSON menjadi struktur Dart (`List` atau `Map`).
- `.map((item) => Post.fromJson(item))` mengubah setiap item dalam `List` menjadi objek `Post`.
- `.toList()` mengubah hasil `Iterable` menjadi `List`.

### Alur Lengkap Pengambilan Data

```text
URL (String)
  ↓ Uri.parse()
Objek Uri
  ↓ http.get()
Response (statusCode + body)
  ↓ periksa statusCode == 200
  ↓ jsonDecode(response.body)
List<dynamic> (berisi Map/List)
  ↓ .map((item) => Post.fromJson(item))
List<Post> (objek siap digunakan)
```

---

## 5. FutureBuilder

### Apa Itu FutureBuilder?

FutureBuilder adalah widget yang memantau status sebuah Future. Setiap kali statusnya berubah, widget ini akan membangun ulang (*rebuild*) tampilan secara otomatis.

### Tiga State yang Wajib Ditangani

| State | Kondisi yang Diperiksa | Tampilan |
|---|---|---|
| Loading | `snapshot.connectionState == ConnectionState.waiting` | Indikator loading (`CircularProgressIndicator`) |
| Error | `snapshot.hasError` | Ikon error, pesan, dan tombol "Coba lagi" |
| Data | Jika bukan keduanya | Data dari `snapshot.data` |

### Contoh FutureBuilder

```dart
FutureBuilder<List<Post>>(
  future: _future,
  builder: (context, snapshot) {
    // State 1: Loading
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // State 2: Error
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Terjadi kesalahan:\n${snapshot.error}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _muatUlang,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    // State 3: Data
    final data = snapshot.data!;
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, i) {
        final post = data[i];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        );
      },
    );
  },
)
```

**Penjelasan:**

- `FutureBuilder<List<Post>>`: tipe *generic* harus sama dengan tipe `_future`. Jika `_future` bertipe `Future<List<Post>>`, maka FutureBuilder-nya `FutureBuilder<List<Post>>`.
- `snapshot` berisi informasi tentang status Future, yaitu `connectionState`, `data`, `error`, dan `hasError`.
- `snapshot.data!`: tanda `!` berarti "saya yakin nilai ini tidak null". Karena dua pemeriksaan sebelumnya sudah dilewati, data seharusnya sudah tersedia.
- `maxLines` dan `overflow: TextOverflow.ellipsis` membuat teks yang terlalu panjang dipotong dan diakhiri dengan `...`.

### Aturan Penting

1. Future dibuat di `initState()`, **bukan** di `build()`.
2. Untuk memuat ulang data, gunakan `setState()` yang berisi pembuatan Future baru. FutureBuilder akan otomatis mengikuti Future yang baru.
3. **Ketiga state wajib ditangani.** Jika hanya loading dan data yang ditangani, aplikasi dapat berhenti merespons atau crash ketika terjadi error.

---

## 6. Navigasi

### Apa Itu Navigator?

Navigator adalah pengelola **tumpukan halaman**. Setiap halaman baru diletakkan di atas halaman sebelumnya. Ketika tombol kembali ditekan, halaman paling atas dilepas dari tumpukan.

### Kapan Digunakan?

Setiap kali pengguna menyentuh suatu elemen yang harus membuka halaman baru. Contoh: menyentuh sebuah postingan untuk membuka halaman detailnya.

### Contoh Kode

Membuka halaman baru sambil mengirim data:

```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HalamanDetailPostingan(post: post),
    ),
  );
},
```

Kembali ke halaman sebelumnya:

```dart
Navigator.pop(context);
```