class Peminjaman {
  final int id;
  final int userId;
  final int barangId;
  final String namaPeminjam;
  final String alasanMeminjam;
  final int jumlah;
  final String tanggalPinjam;
  final String tanggalKembali; // Tambahkan field tanggal kembali
  final String status;
  final String? namaBarang; // Tambahkan field untuk nama barang

  Peminjaman({
    required this.id,
    required this.userId,
    required this.barangId,
    required this.namaPeminjam,
    required this.alasanMeminjam,
    required this.jumlah,
    required this.tanggalPinjam,
    required this.tanggalKembali, // Required field untuk tanggal kembali
    required this.status,
    this.namaBarang, // Opsional, mungkin tidak selalu tersedia dari API
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    // Coba ambil nama barang jika tersedia di response API
    String? namaBarang;
    if (json.containsKey('barang') && json['barang'] != null) {
      // Jika ada objek barang di response
      if (json['barang'] is Map) {
        namaBarang = json['barang']['nama_barang'];
      }
    } else if (json.containsKey('nama_barang')) {
      // Jika nama barang langsung di level atas
      namaBarang = json['nama_barang'];
    }

    return Peminjaman(
      id: json['id'],
      userId: json['user_id'],
      barangId: json['barang_id'],
      namaPeminjam: json['nama_peminjam'],
      alasanMeminjam: json['alasan_meminjam'],
      jumlah: json['jumlah'],
      tanggalPinjam: json['tanggal_pinjam'],
      tanggalKembali:
          json['tanggal_kembali'] ?? '', // Tambahkan field tanggal kembali
      status: json['status'],
      namaBarang: namaBarang,
    );
  }
}
