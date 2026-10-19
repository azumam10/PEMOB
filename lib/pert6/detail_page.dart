import 'package:flutter/material.dart';

import 'app_state.dart';
import 'rute.dart';

class DetailPage extends StatefulWidget {
  final DetailArgs args;
  const DetailPage({super.key, required this.args});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  // Animasi EKSPLISIT: kita yang mengendalikan kapan animasi berjalan.
  late final AnimationController _denyut;
  late final Animation<double> _skala;

  @override
  void initState() {
    super.initState();
    _denyut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _skala = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.5).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.5, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_denyut);
  }

  @override
  void dispose() {
    _denyut.dispose(); // wajib, agar tidak terjadi kebocoran memori
    super.dispose();
  }

  void _ubahFavorit() {
    toggleFavorit(widget.args.tempat.id);
    _denyut.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final skema = tema.colorScheme;
    final tempat = widget.args.tempat;

    return Scaffold(
      appBar: AppBar(title: Text(tempat.nama)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Hero(
              tag: widget.args.heroTag,
              child: CircleAvatar(
                radius: 64,
                backgroundColor: skema.primaryContainer,
                foregroundColor: skema.onPrimaryContainer,
                child: Icon(tempat.ikon, size: 64),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            tempat.nama,
            style: tema.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            tempat.daerah,
            style: tema.textTheme.titleMedium?.copyWith(
              color: skema.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<Set<String>>(
            valueListenable: favorit,
            builder: (context, daftarFavorit, _) {
              final fav = daftarFavorit.contains(tempat.id);
              return Column(
                children: [
                  // Animasi IMPLISIT: cukup ubah nilai, Flutter yang menganimasikan.
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: fav
                            ? skema.primaryContainer
                            : skema.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(fav ? 24 : 8),
                      ),
                      child: Text(
                        fav ? 'Ada di Favorit' : 'Belum difavoritkan',
                        style: tema.textTheme.labelLarge?.copyWith(
                          color: fav
                              ? skema.onPrimaryContainer
                              : skema.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tempat.deskripsi,
                      style: tema.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _ubahFavorit,
                    icon: ScaleTransition(
                      scale: _skala,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          fav ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(fav), // key berbeda → AnimatedSwitcher beranimasi
                        ),
                      ),
                    ),
                    label: Text(
                      fav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
