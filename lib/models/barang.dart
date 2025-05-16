class Barang {
  final int id;
  final String namaBarang;
  final String deskripsi;
  final int idKategori;
  final String? foto;

  Barang({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.idKategori,
    this.foto,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'],
      deskripsi: json['deskripsi'] ?? '',
      idKategori: json['id_kategori'],
      foto: json['foto'],
    );
  }
}
