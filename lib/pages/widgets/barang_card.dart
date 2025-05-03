import 'package:flutter/material.dart';
import '../../../models/barang_model.dart';


class BarangCard extends StatelessWidget {
  final BarangModel barang;
  const BarangCard({Key? key, required this.barang}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              barang.namaBarang,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Kategori: ${barang.namaKategori}'),
            Text('Stok tersedia: ${barang.jumlahTersedia}'),
          ],
        ),
      ),
    );
  }
}
