import 'Catatan.dart';
import 'DbHelper.dart';

Future<void> jalankanTest() async {
  final testId = await DbHelper.tambah(
    const Catatan(judul: 'Test 1', isi: 'Isi test pertama'),
  );
  print('ID baru: $testId');

  final semua = await DbHelper.semua();
  print('Total catatan: ${semua.length}');
  for (var c in semua) {
    print('${c.id} - ${c.judul} - ${c.isi}');
  }
}