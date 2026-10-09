import 'package:flutter/material.dart';
import '../models/postingan.dart';
import '../models/komentar.dart';
import '../services/api_service.dart';

class DetailPostinganPage extends StatefulWidget {
  final Postingan postingan;
  const DetailPostinganPage({super.key, required this.postingan});

  @override
  State<DetailPostinganPage> createState() => _DetailPostinganPageState();
}

class _DetailPostinganPageState extends State<DetailPostinganPage> {
  late Future<List<Komentar>> _futureKomentar;

  @override
  void initState() {
    super.initState();
    _futureKomentar = ambilKomentar(widget.postingan.id);
  }

  void _muatUlang() {
    setState(() {
      _futureKomentar = ambilKomentar(widget.postingan.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postingan = widget.postingan;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Postingan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(postingan.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(postingan.body),
            const Divider(height: 32),
            const Text('Komentar:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<List<Komentar>>(
              future: _futureKomentar,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (snapshot.hasError) {
                  return Center(child: Column(
                    children: [
                      Text('Gagal memuat komentar: ${snapshot.error}'),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _muatUlang, child: const Text('Coba lagi')),
                    ],
                  ));
                }
                final komentar = snapshot.data!;
                return Column(
                  children: komentar.map((k) => Card(
                    child: ListTile(
                      title: Text(k.name),
                      subtitle: Text(k.body),
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