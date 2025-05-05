// services/peminjaman_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/peminjaman_model.dart';

class PeminjamanService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static Future<Peminjaman  > createPeminjaman({
    required String token,
    required String namaPeminjam,
    required String alasanMeminjam,
    required int barangId,
    required int jumlah,
    required String tanggalPinjam,
    required String status,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/peminjaman'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id' : 2,
        'barang_id': barangId,
        'nama_peminjam': namaPeminjam,
        'alasan_meminjam': alasanMeminjam,
        'jumlah': jumlah,
        'tanggal_pinjam': tanggalPinjam,
        'status': status
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Peminjaman.fromJson(json['data']);
    } else {
      throw Exception('Gagal membuat peminjaman');
    }
  }
}
