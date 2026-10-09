import 'package:flutter/material.dart';

class Ukm {
  final String nama_ukm;
  final String tempat_ukm;
  final String ketua_ukm;

  const Ukm(
    this.nama_ukm,
    this.tempat_ukm,
    this.ketua_ukm,
  );
}

const daftar_ukm = [
    Ukm('Badminton', 'Gor Rajawali', 'Radet'),
    Ukm('Futsal', 'Lapangan Esaunggul', 'Ipan'),
    Ukm('Voli', 'Lapangan Esaunggul', 'Bayu'),
    Ukm('Musik', 'Studio Musik EsaUnggul', 'Dito'),
];

class DaftarUKM extends StatelessWidget {
  const DaftarUKM({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar UKM',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade800,
        elevation: 4,
      ),
      // --- BAGIAN BODY MEMULAI DARI SINI ---
      body: ListView.builder(
        // 1. Menentukan berapa banyak item yang akan ditampilkan
        itemCount: daftar_ukm.length,
        // 2. Padding di sekeliling daftar agar tidak menempel di pinggir layar
        padding: const EdgeInsets.all(12),
        // 3. Fungsi pembuat tampilan untuk setiap item
        itemBuilder: (context, index) {
          // Mengambil satu data UKM berdasarkan indeks perulangan
          final ukm = daftar_ukm[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              // Bagian Kiri: Ikon Avatar Bulat dengan Huruf Depan
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: Text(
                  ukm.nama_ukm[0], // Mengambil huruf pertama dari nama UKM
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Bagian Utama: Nama UKM
              title: Text(
                ukm.nama_ukm,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // Bagian Bawah: Informasi Tempat & Ketua
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                style: const TextStyle(fontSize: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(ukm.tempat_ukm),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Ketua: ${ukm.ketua_ukm}'),
                      ],
                    ),
                  ],
                ),
              ),
              // Bagian Kanan: Ikon Panah
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              // Event ketika item diklik (opsional)
              onTap: () {
                // Di sini nanti bisa ditambahkan navigasi ke halaman detail
              },
            ),
          );
        },
      ),
    );
  }
}