class BarangModel {
  final int id;
  final String namaBarang;
  final String deskripsi;
  final int idKategori;
  final String namaKategori;
  final int jumlahTersedia;
  final String? foto; // URL foto dari API

  BarangModel({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.idKategori,
    required this.namaKategori,
    required this.jumlahTersedia,
    this.foto,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    // Handle different JSON structures
    String? namaKategori;
    if (json.containsKey('kategori') && json['kategori'] != null) {
      if (json['kategori'] is Map) {
        namaKategori = json['kategori']['nama_kategori'];
      } else if (json['nama_kategori'] != null) {
        namaKategori = json['nama_kategori'];
      }
    }

    return BarangModel(
      id: json['id'],
      namaBarang: json['nama_barang'] ?? 'Barang #${json['id']}',
      deskripsi: json['deskripsi'] ?? '',
      idKategori: json['id_kategori'] ?? 0,
      namaKategori: namaKategori ?? 'Tidak diketahui',
      jumlahTersedia: json['jumlah_tersedia'] ?? 0,
      foto: json['foto']?.toString(), // Ambil URL foto dari API
    );
  }
}
