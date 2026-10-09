import 'dart:convert'; // Wajib diimport untuk fungsi jsonDecode
import 'package:http/http.dart' as http; // Wajib diimport untuk panggil API
import 'model.dart'; // Import file model yang baru dibuat di atas

class ApiService {
  // Base URL API (JSONPlaceholder)
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // ----------------------------------------------------
  // FUNGSI 1: Ambil Semua Postingan (/posts)
  // ----------------------------------------------------
  static Future<List<Post>> ambilPosts() async {
    final uri = Uri.parse('$_baseUrl/posts');
    
    // Mengirim HTTP GET request dengan batas waktu (timeout) 10 detik
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    // 1. Cek status kode HTTP (200 = Sukses)
    if (response.statusCode == 200) {
      // jsonDecode mengubah Teks JSON mentah menjadi List
      final List<dynamic> data = jsonDecode(response.body);

      // Ubah setiap item List JSON menjadi objek class Post
      return data
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      // Jika server mengembalikan error (misal 404 atau 500)
      throw Exception('Gagal memuat postingan (Kode: ${response.statusCode})');
    }
  }

  // ----------------------------------------------------
  // FUNGSI 2: Ambil Komentar berdasarkan ID Post (/posts/{id}/comments)
  // ----------------------------------------------------
  static Future<List<Komentar>> ambilKomentar(int postId) async {
    final uri = Uri.parse('$_baseUrl/posts/$postId/comments');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

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