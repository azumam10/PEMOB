import 'tempat.dart';

/// Nama rute dikumpulkan di satu tempat agar tidak salah ketik.
class Rute {
  static const beranda = '/';
  static const detail = '/detail';
}

/// Argumen yang dikirim ke halaman detail.
/// heroTag dikirim juga karena tab Beranda dan Favorit bisa menampilkan
/// tempat yang sama; tag Hero harus unik dalam satu halaman.
class DetailArgs {
  final Tempat tempat;
  final String heroTag;
  const DetailArgs({required this.tempat, required this.heroTag});
}
