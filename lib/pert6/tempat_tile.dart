import 'package:flutter/material.dart';

import 'app_state.dart';
import 'rute.dart';
import 'tempat.dart';

/// Satu baris tempat. Dipakai di tab Beranda dan Favorit.
/// [sumber] membedakan tag Hero antar tab, sebab IndexedStack menjaga
/// kedua tab tetap hidup sehingga tag yang sama akan bentrok.
class TempatTile extends StatelessWidget {
  final Tempat tempat;
  final String sumber;

  const TempatTile({super.key, required this.tempat, required this.sumber});

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    final tag = 'ikon-$sumber-${tempat.id}';

    return ListTile(
      leading: Hero(
        tag: tag,
        child: CircleAvatar(
          backgroundColor: skema.primaryContainer,
          foregroundColor: skema.onPrimaryContainer,
          child: Icon(tempat.ikon),
        ),
      ),
      title: Text(tempat.nama),
      subtitle: Text(tempat.daerah),
      trailing: ValueListenableBuilder<Set<String>>(
        valueListenable: favorit,
        builder: (context, daftarFavorit, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (daftarFavorit.contains(tempat.id))
                Icon(Icons.favorite, size: 18, color: skema.primary),
              const Icon(Icons.chevron_right),
            ],
          );
        },
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          Rute.detail,
          arguments: DetailArgs(tempat: tempat, heroTag: tag),
        );
      },
    );
  }
}
