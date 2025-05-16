import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/barang_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Ambil daftar barang (dengan kategori & stok)
  static Future<List<BarangModel>> fetchBarangs(String token) async {
    final url = Uri.parse('$baseUrl/barangs');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true) {
        List data = jsonData['data'];
        return data.map((item) => BarangModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal fetch data barang: ${jsonData['message']}');
      }
    } else {
      throw Exception('Gagal fetch data barang. Code: ${response.statusCode}');
    }
  }

  // Cari barang berdasarkan nama
  static Future<List<BarangModel>> searchBarangs(
      String token, String query) async {
    final url = Uri.parse('$baseUrl/barangs/search?q=$query');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true) {
        List data = jsonData['data'];
        return data.map((item) => BarangModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mencari barang: ${jsonData['message']}');
      }
    } else {
      throw Exception('Gagal mencari barang. Code: ${response.statusCode}');
    }
  }

  // Ambil detail barang berdasarkan ID
  static Future<BarangModel> fetchBarangById(String token, int id) async {
    final url = Uri.parse('$baseUrl/barangs/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Debug: Print response untuk melihat struktur data
      debugPrint('Response for barangs/$id: ${response.body}');

      if (jsonData['success'] == true) {
        try {
          return BarangModel.fromJson(jsonData['data']);
        } catch (e) {
          debugPrint('Error parsing barang data: $e');
          // Fallback jika struktur data tidak sesuai
          return BarangModel(
            id: id,
            namaBarang: jsonData['data']['nama_barang'] ?? 'Barang #$id',
            deskripsi: jsonData['data']['deskripsi'] ?? '',
            idKategori: jsonData['data']['id_kategori'] ?? 0,
            namaKategori:
                jsonData['data']['nama_kategori'] ?? 'Tidak diketahui',
            jumlahTersedia: jsonData['data']['jumlah_tersedia'] ?? 0,
          );
        }
      } else {
        throw Exception('Gagal fetch detail barang: ${jsonData['message']}');
      }
    } else {
      throw Exception(
          'Gagal fetch detail barang. Code: ${response.statusCode}');
    }
  }
}
