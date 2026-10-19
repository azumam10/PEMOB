class Catatan {
  final int? id;
  final String judul;
  final String isi;

  const Catatan({this.id, required this.judul, required this.isi});

  Map<String, Object?> toMap() => {'id': id, 'judul': judul, 'isi': isi};

  factory Catatan.fromMap(Map<String, Object?> m) => Catatan(
        id: m['id'] as int?,
        judul: m['judul'] as String,
        isi: m['isi'] as String,
      );
}