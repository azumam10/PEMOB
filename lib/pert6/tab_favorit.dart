import 'package:flutter/material.dart';

import 'app_state.dart';
import 'tempat.dart';
import 'tempat_tile.dart';

class FavoritTab extends StatelessWidget {
  const FavoritTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ValueListenableBuilder<Set<String>>(
      valueListenable: favorit,
      builder: (context, daftarFavorit, _) {
        final terpilih =
            daftarTempat.where((t) => daftarFavorit.contains(t.id)).toList();

        if (terpilih.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: tema.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text('Belum ada favorit', style: tema.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Buka detail tempat lalu tekan "Tambah ke favorit".',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: terpilih.length,
          itemBuilder: (context, i) {
            return TempatTile(tempat: terpilih[i], sumber: 'favorit');
          },
        );
      },
    );
  }
}
