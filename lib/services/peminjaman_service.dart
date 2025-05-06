// services/peminjaman_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/peminjaman_model.dart';
import 'auth_service.dart'; // import auth service

class PeminjamanService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static Future<Peminjaman> createPeminjaman({
    required String token,
    required String namaPeminjam,
    required String alasanMeminjam,
    required int barangId,
    required int jumlah,
    required String tanggalPinjam,
    required String status,
  }) async {
    final int? userId = await AuthService().getUserId();

    if (userId == null) {
      throw Exception('User ID tidak ditemukan. Harap login kembali.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/peminjaman'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'barang_id': barangId,
        'nama_peminjam': namaPeminjam,
        'alasan_meminjam': alasanMeminjam,
        'jumlah': jumlah,
        'tanggal_pinjam': tanggalPinjam,
        'status': status,
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Peminjaman.fromJson(json['data']);
    } else {
      throw Exception('Gagal membuat peminjaman: ${response.body}');
    }
  }
}
