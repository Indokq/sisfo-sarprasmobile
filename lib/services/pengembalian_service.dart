// services/pengembalian_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/pengembalian_model.dart';

class PengembalianService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Fungsi untuk membuat pengembalian baru
  static Future<Pengembalian> createPengembalian({
    required String token,
    required int peminjamanId,
    required String tanggalPengembalian,
    required int jumlahDikembalikan,
    required String keterangan,
  }) async {
    final response = await http.post(
  Uri.parse('$baseUrl/pengembalian'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'peminjaman_id': peminjamanId,
        'tanggal_pengembalian': tanggalPengembalian,
        'jumlah_dikembalikan': jumlahDikembalikan,
        'status_pengembalian': 'pending', // Default status
        'keterangan': keterangan,
        'denda': 0, // Default denda
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      
      // Debug: Print response untuk melihat struktur data
      debugPrint('Pengembalian API response: ${response.body}');
      
      if (json['success'] == true) {
        return Pengembalian.fromJson(json['data']);
      } else {
        throw Exception('Gagal membuat pengembalian: ${json['message']}');
      }
    } else {
      throw Exception('Gagal membuat pengembalian: ${response.body}');
    }
  }

  // Fungsi untuk mengambil riwayat pengembalian
  static Future<List<Pengembalian>> fetchPengembalian(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pengembalian'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      
      // Debug: Print response untuk melihat struktur data
      debugPrint('Pengembalian list API response: ${response.body}');

      if (jsonData['success'] == true) {
        List data = jsonData['data'];
        return data.map((item) => Pengembalian.fromJson(item)).toList();
      } else {
        throw Exception('Gagal fetch data pengembalian: ${jsonData['message']}');
      }
    } else {
      throw Exception(
          'Gagal fetch data pengembalian. Code: ${response.statusCode}');
    }
  }

}
