import 'dart:convert';
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

}
