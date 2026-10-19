import 'package:flutter/widgets.dart' show IconData;
import 'package:flutter/material.dart' show Icons;

/// Cetakan data satu tempat wisata.
class Tempat {
  final String id;
  final String nama;
  final String daerah;
  final String deskripsi;
  final IconData ikon;

  const Tempat({
    required this.id,
    required this.nama,
    required this.daerah,
    required this.deskripsi,
    required this.ikon,
  });
}

const daftarTempat = [
  Tempat(
    id: 'borobudur',
    nama: 'Candi Borobudur',
    daerah: 'Magelang, Jawa Tengah',
    deskripsi:
        'Candi Buddha terbesar di dunia yang dibangun pada abad ke-9. '
        'Waktu terbaik berkunjung adalah saat matahari terbit.',
    ikon: Icons.account_balance,
  ),
  Tempat(
    id: 'bromo',
    nama: 'Gunung Bromo',
    daerah: 'Jawa Timur',
    deskripsi:
        'Gunung berapi aktif dengan lautan pasir yang luas. '
        'Pemandangan matahari terbit dari Penanjakan sangat terkenal.',
    ikon: Icons.terrain,
  ),
  Tempat(
    id: 'kuta',
    nama: 'Pantai Kuta',
    daerah: 'Bali',
    deskripsi:
        'Pantai berpasir luas yang ramai dikunjungi wisatawan, '
        'cocok untuk berselancar dan menikmati matahari terbenam.',
    ikon: Icons.beach_access,
  ),
  Tempat(
    id: 'rajaampat',
    nama: 'Raja Ampat',
    daerah: 'Papua Barat Daya',
    deskripsi:
        'Gugusan pulau dengan keanekaragaman hayati laut yang sangat kaya, '
        'populer untuk menyelam dan snorkeling.',
    ikon: Icons.waves,
  ),
  Tempat(
    id: 'toba',
    nama: 'Danau Toba',
    daerah: 'Sumatera Utara',
    deskripsi:
        'Danau vulkanik terbesar di Asia Tenggara dengan Pulau Samosir '
        'di tengahnya dan budaya Batak yang kental.',
    ikon: Icons.water,
  ),
  Tempat(
    id: 'labuanbajo',
    nama: 'Labuan Bajo',
    daerah: 'Nusa Tenggara Timur',
    deskripsi:
        'Gerbang menuju Taman Nasional Komodo, dengan pelayaran '
        'antarpulau dan pemandangan perbukitan savana.',
    ikon: Icons.sailing,
  ),
];
