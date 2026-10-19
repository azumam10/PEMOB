import 'package:flutter/material.dart';

import 'tempat.dart';
import 'tempat_tile.dart';

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: daftarTempat.length,
      itemBuilder: (context, i) {
        return TempatTile(tempat: daftarTempat[i], sumber: 'beranda');
      },
    );
  }
}
