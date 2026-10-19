import 'package:flutter/material.dart';

import 'app_state.dart';

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final skema = tema.colorScheme;

    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, indeksWarna]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: ubahModeGelap,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Warna tema', style: tema.textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                children: [
                  for (var i = 0; i < pilihanWarna.length; i++)
                    Tooltip(
                      message: pilihanWarna[i].nama,
                      child: GestureDetector(
                        onTap: () => ubahWarna(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pilihanWarna[i].warna,
                            border: Border.all(
                              color: indeksWarna.value == i
                                  ? skema.onSurface
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pilihan tema tersimpan otomatis dan tetap berlaku '
                'setelah aplikasi ditutup.',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: skema.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
