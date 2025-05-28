// services/peminjaman_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/peminjaman_model.dart';
import 'auth_service.dart'; // import auth service

class PeminjamanService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Fungsi untuk membuat peminjaman baru
  static Future<Peminjaman> createPeminjaman({
    required String token,
    required String namaPeminjam,
    required String alasanMeminjam,
    required int barangId,
    required int jumlah,
    required String tanggalPinjam,
    required String tanggalKembali,
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
        'tanggal_kembali': tanggalKembali,
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

  // Fungsi untuk mengambil riwayat peminjaman
  static Future<List<Peminjaman>> fetchPeminjaman(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/peminjaman'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Debug: Print response untuk melihat struktur data
      debugPrint('Peminjaman API response: ${response.body}');

      if (jsonData['success'] == true) {
        List data = jsonData['data'];
        return data.map((item) => Peminjaman.fromJson(item)).toList();
      } else {
        throw Exception('Gagal fetch data peminjaman: ${jsonData['message']}');
      }
    } else {
      throw Exception(
          'Gagal fetch data peminjaman. Code: ${response.statusCode}');
    }
  }

  // Fungsi untuk mengambil detail peminjaman berdasarkan ID
  static Future<Peminjaman> fetchPeminjamanById(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/peminjaman/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true) {
        return Peminjaman.fromJson(jsonData['data']);
      } else {
        throw Exception(
            'Gagal fetch detail peminjaman: ${jsonData['message']}');
      }
    } else {
      throw Exception(
          'Gagal fetch detail peminjaman. Code: ${response.statusCode}');
    }
  }
}
