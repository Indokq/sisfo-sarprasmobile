class Pengembalian {
  final int id;
  final int peminjamanId;
  final String tanggalPengembalian;
  final int jumlahDikembalikan;
  final String statusPengembalian;
  final String keterangan;
  final int denda;
  final String? createdAt;
  final String? updatedAt;

  Pengembalian({
    required this.id,
    required this.peminjamanId,
    required this.tanggalPengembalian,
    required this.jumlahDikembalikan,
    required this.statusPengembalian,
    required this.keterangan,
    required this.denda,
    this.createdAt,
    this.updatedAt,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'] ?? 0,
      peminjamanId: json['peminjaman_id'],
      tanggalPengembalian: json['tanggal_pengembalian'],
      jumlahDikembalikan: json['jumlah_dikembalikan'],
      statusPengembalian: json['status_pengembalian'],
      keterangan: json['keterangan'],
      denda: json['denda'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'peminjaman_id': peminjamanId,
      'tanggal_pengembalian': tanggalPengembalian,
      'jumlah_dikembalikan': jumlahDikembalikan,
      'status_pengembalian': statusPengembalian,
      'keterangan': keterangan,
      'denda': denda,
    };
  }
}
