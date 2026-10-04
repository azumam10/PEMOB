import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Data 
class Barang {
  final String nama;
  final int jumlah;
  final String kategori;
  bool sudahDibeli;

  Barang({
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.sudahDibeli = false,
  });
}


// management state
class BelanjaModel extends ChangeNotifier {
  final List<Barang> _items = [];

  List<Barang> get items => List.unmodifiable(_items);

  // Menghitung barang yang belum dibeli untuk ditampilkan di AppBar
  int get jumlahBelumDibeli => _items.where((b) => !b.sudahDibeli).length;

  void tambahBarang(String nama, int jumlah, String kategori) {
    _items.add(Barang(nama: nama, jumlah: jumlah, kategori: kategori));
    notifyListeners(); // Memperbarui UI yang mendengar (watch)
  }

  void toggleStatus(int index) {
    _items[index].sudahDibeli = !_items[index].sudahDibeli;
    notifyListeners();
  }

  void hapusBarang(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Daftar Belanja',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const DaftarBelanjaPage(),
    );
  }
}

// halaman daftar belanja
class DaftarBelanjaPage extends StatelessWidget {
  const DaftarBelanjaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch() digunakan untuk membaca data DAN rebuild saat data berubah
    final belanja = context.watch<BelanjaModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Belanja (${belanja.jumlahBelumDibeli} Sisa)'),
      ),
      body: belanja.items.isEmpty
          ? const Center(child: Text('Belum ada daftar belanjaan'))
          : ListView.builder(
              itemCount: belanja.items.length,
              itemBuilder: (context, index) {
                final item = belanja.items[index];
                return ListTile(
                  leading: Checkbox(
                    value: item.sudahDibeli,
                    // context.read() digunakan dalam callback (onPressed/onChanged)
                    onChanged: (_) => context.read<BelanjaModel>().toggleStatus(index),
                  ),
                  title: Text(
                    '${item.nama} (${item.jumlah} pcs)',
                    style: TextStyle(
                      decoration: item.sudahDibeli ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('Kategori: ${item.kategori}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => context.read<BelanjaModel>().hapusBarang(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahBelanjaPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// form input drop down, cekbox
class TambahBelanjaPage extends StatefulWidget {
  const TambahBelanjaPage({super.key});

  @override
  State<TambahBelanjaPage> createState() => _TambahBelanjaPageState();
}

class _TambahBelanjaPageState extends State<TambahBelanjaPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();

  String? _kategoriPilihan;
  bool _setuju = false;

  final List<String> _kategoriList = ['Makanan', 'Minuman', 'Kebutuhan Rumah', 'Lainnya'];

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpanData() {
    if (_formKey.currentState!.validate()) {
      // Panggil method di Provider tanpa merebuild widget ini (menggunakan context.read)
      context.read<BelanjaModel>().tambahBarang(
            _namaController.text.trim(),
            int.parse(_jumlahController.text.trim()),
            _kategoriPilihan!,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil ditambahkan!')),
      );

      Navigator.pop(context); // Kembali ke halaman utama
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Belanjaan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Input Nama Barang
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama barang wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // 2. Input Jumlah Barang
            TextFormField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }
                final jumlah = int.tryParse(value);
                if (jumlah == null || jumlah <= 0) {
                  return 'Masukkan angka positif yang valid';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // 3. Dropdown Kategori
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              value: _kategoriPilihan,
              items: _kategoriList.map((String kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _kategoriPilihan = newValue;
                });
              },
              validator: (value) => value == null ? 'Pilih kategori barang' : null,
            ),

            const SizedBox(height: 12),

            // 4. Checkbox Persetujuan
            CheckboxListTile(
              title: const Text('Data yang saya masukkan sudah benar'),
              value: _setuju,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? value) {
                setState(() {
                  _setuju = value ?? false;
                });
              },
            ),

            const SizedBox(height: 16),

            // Tombol Simpan (Hanya aktif jika Checkbox dicentang)
            ElevatedButton(
              onPressed: _setuju ? _simpanData : null,
              child: const Text('Simpan Ke Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}