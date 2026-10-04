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

const daftarKontak = [
  Kontak(
    'Umam',
    '08123456789',
    'umam@email.com',
  ),

  Kontak(
    'Goro',
    '08234567890',
    'goro@email.com',
  ),

  Kontak(
    'Amin',
    '08345678901',
    'amin@email.com',
  ),

  Kontak(
    'Ipan',
    '08456789012',
    'deni@email.com',
  ),

  Kontak(
    'Josjis',
    '08567890123',
    'josjis@email.com',
  ),

  Kontak(
    'Raisa',
    '08678901234',
    'raisa@email.com',
  ),
];

class Pertemuan2App extends StatelessWidget {
  const Pertemuan2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 2',
      home: const ContactPage(),
    );
  }
}

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

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            child: ListTile(
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

              title: Text(
                kontak.nama,
              ),

              subtitle: Text(
                kontak.telepon,
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          );
        },
      ),
    );
  }
}

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

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

