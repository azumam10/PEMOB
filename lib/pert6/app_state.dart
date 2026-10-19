import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Satu pilihan warna tema (nama untuk tooltip, warna sebagai seed).
class PilihanWarna {
  final String nama;
  final Color warna;
  const PilihanWarna(this.nama, this.warna);
}

const pilihanWarna = [
  PilihanWarna('Indigo', Colors.indigo),
  PilihanWarna('Teal', Colors.teal),
  PilihanWarna('Oranye', Colors.deepOrange),
  PilihanWarna('Pink', Colors.pink),
];

// Kunci penyimpanan lokal.
const _kModeGelap = 'mode_gelap';
const _kIndeksWarna = 'indeks_warna';
const _kFavorit = 'favorit';

// State global sederhana. ValueNotifier memberi tahu widget saat nilainya berubah.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final indeksWarna = ValueNotifier<int>(0);
final favorit = ValueNotifier<Set<String>>(<String>{});

/// Warna seed yang sedang aktif.
Color get seedColor => pilihanWarna[indeksWarna.value].warna;

/// Dipanggil sekali di main() sebelum runApp().
Future<void> muatPengaturan() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final gelap = prefs.getBool(_kModeGelap) ?? false;
    themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;

    final tersimpan = prefs.getInt(_kIndeksWarna) ?? 0;
    indeksWarna.value =
        (tersimpan >= 0 && tersimpan < pilihanWarna.length) ? tersimpan : 0;

    favorit.value = (prefs.getStringList(_kFavorit) ?? <String>[]).toSet();
  } catch (e) {
    // Jika penyimpanan gagal dibaca, aplikasi tetap jalan dengan nilai awal.
    debugPrint('Gagal memuat pengaturan: $e');
  }
}

Future<void> ubahModeGelap(bool gelap) async {
  themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kModeGelap, gelap);
}

Future<void> ubahWarna(int indeks) async {
  indeksWarna.value = indeks;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_kIndeksWarna, indeks);
}

Future<void> toggleFavorit(String id) async {
  // Buat Set baru agar ValueNotifier mendeteksi perubahan.
  final baru = Set<String>.of(favorit.value);
  if (!baru.remove(id)) {
    baru.add(id);
  }
  favorit.value = baru;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_kFavorit, baru.toList());
}
