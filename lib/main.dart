import 'package:flutter/material.dart';
import 'package:praktikum/pert3/Pertemuan3.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BelanjaModel(),
      child: const MyApp(),
    ),
  );
}
