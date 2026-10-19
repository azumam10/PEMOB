import 'package:flutter/material.dart';
import 'pert5/PengaturanPage.dart';
import 'pert5/test_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await jalankanTest();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 5',
      home: const PengaturanPage(),
    );
  }
}