import 'package:flutter/material.dart';
import 'api_service.dart';
import 'model.dart';

class HalamanDetailPostingan extends StatefulWidget {
  final Post post;  // data yang dilempar dari halaman daftar

  const HalamanDetailPostingan({super.key, required this.post});

  @override
  State<HalamanDetailPostingan> createState() => _HalamanDetailPostinganState();
}

class _HalamanDetailPostinganState extends State<HalamanDetailPostingan> {
  late Future<List<Komentar>> _futureKomentar;

  @override
  void initState() {
    super.initState();
    _futureKomentar = ApiService.ambilKomentar(widget.post.id);
  }

  void _muatUlang() {
    setState(() {
      _futureKomentar = ApiService.ambilKomentar(widget.post.id);
    });
  }

  @override
Widget build(BuildContext context) {
  final post = widget.post;  // ambil post biar gampang dipanggil

  return Scaffold(
    appBar: AppBar(title: const Text('Detail Postingan')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== BAGIAN 1: POSTINGAN =====
          Text(
            post.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'User ID: ${post.userId}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(post.body, style: const TextStyle(fontSize: 16)),
          
          const Divider(height: 32),
          
          // ===== BAGIAN 2: KOMENTAR =====
          const Text(
            'Komentar:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Komentar>>(
            future: _futureKomentar,
            builder: (context, snapshot) {
              // STATE 1: LOADING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // STATE 2: ERROR
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Gagal memuat komentar:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _muatUlang,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // STATE 3: DATA
              final komentar = snapshot.data!;
              if (komentar.isEmpty) {
                return const Text('Belum ada komentar.');
              }
              return Column(
                children: komentar.map((k) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(k.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(k.email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(k.body),
                      ],
                    ),
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    ),
  );
}
}