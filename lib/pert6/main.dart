import 'package:flutter/material.dart';

import 'app_state.dart';
import 'detail_page.dart';
import 'rute.dart';
import 'shell_page.dart';

Future<void> main() async {
  // Wajib dipanggil sebelum memakai plugin (shared_preferences) di main().
  WidgetsFlutterBinding.ensureInitialized();
  await muatPengaturan();
  runApp(const MyApp());
}

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp dibangun ulang setiap mode atau warna berubah.
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, indeksWarna]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Katalog Wisata',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor, Brightness.light),
          darkTheme: buatTema(seedColor, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: Rute.beranda,
          routes: {
            Rute.beranda: (_) => const ShellPage(),
          },
          onGenerateRoute: _buatRute,
          onUnknownRoute: (settings) {
            return MaterialPageRoute<void>(
              builder: (_) => HalamanTidakDitemukan(nama: settings.name),
            );
          },
        );
      },
    );
  }
}

/// Menangani rute yang membawa argumen.
/// Mengembalikan null bila rute/argumen tidak dikenali → masuk onUnknownRoute.
Route<dynamic>? _buatRute(RouteSettings settings) {
  if (settings.name == Rute.detail) {
    final args = settings.arguments;
    if (args is DetailArgs) {
      return PageRouteBuilder<void>(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => DetailPage(args: args),
        transitionsBuilder: (_, animasi, __, child) {
          return FadeTransition(opacity: animasi, child: child);
        },
      );
    }
  }
  return null;
}

class HalamanTidakDitemukan extends StatelessWidget {
  final String? nama;
  const HalamanTidakDitemukan({super.key, this.nama});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: tema.colorScheme.error),
            const SizedBox(height: 12),
            Text('Halaman tidak ditemukan', style: tema.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Rute: ${nama ?? '-'}', style: tema.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
