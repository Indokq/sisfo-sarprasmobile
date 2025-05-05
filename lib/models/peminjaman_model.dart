class Peminjaman {
  final int id;
  final int userId;
  final int barangId;
  final String namaPeminjam;
  final String alasanMeminjam;
  final int jumlah;
  final String tanggalPinjam;
  final String status;


  Peminjaman({
    required this.id,
    required this.userId,
    required this.barangId,
    required this.namaPeminjam,
    required this.alasanMeminjam,
    required this.jumlah,
    required this.tanggalPinjam,
    required this.status,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'],
      userId: json['user_id'],
      barangId: json['barang_id'],
      namaPeminjam: json['nama_peminjam'],
      alasanMeminjam: json['alasan_meminjam'],
      jumlah: json['jumlah'],
      tanggalPinjam: json['tanggal_pinjam'],
      status: json['status'],
    );
  }
}
