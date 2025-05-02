class BarangModel {
  final int id;
  final String namaBarang;
  final String deskripsi;
  final int idKategori;
  final String namaKategori;
  final int jumlahTersedia;

  BarangModel({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.idKategori,
    required this.namaKategori,
    required this.jumlahTersedia,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      id: json['id'],
      namaBarang: json['nama_barang'],
      deskripsi: json['deskripsi'],
      idKategori: json['id_kategori'],
      namaKategori: json['kategori']['nama_kategori'],
      jumlahTersedia: json['jumlah_tersedia'],
    );
  }
}
