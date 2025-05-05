import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sisfo_sarpras/models/barang_model.dart';
import 'package:sisfo_sarpras/services/api_service.dart';
import '../../services/peminjaman_service.dart';
import '../../models/peminjaman_model.dart';

class PeminjamanView extends StatefulWidget {
  final String token;
  const PeminjamanView({super.key, required this.token});

  @override
  State<PeminjamanView> createState() => _PeminjamanViewState();
}

class _PeminjamanViewState extends State<PeminjamanView> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController alasanController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  bool isLoading = false;
  bool isFetchingBarang = false;
  List<BarangModel> barangList = [];
  BarangModel? selectedBarang;

  @override
  void initState() {
    super.initState();
    _fetchBarang();
  }

  Future<void> _fetchBarang() async {
  setState(() {
    isFetchingBarang = true;
  });

  try {
    // Provide the token as required by the API
    final List<BarangModel> fetchedBarang = await ApiService.fetchBarangs(widget.token);

    setState(() {
      barangList = fetchedBarang;
      if (barangList.isNotEmpty) {
        selectedBarang = barangList[0]; // Set default selected item
      }
    });
  } catch (e) {
    // Print and show the error in the UI
    print("Error fetching barang: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal mengambil data barang')),
    );
  }

  setState(() {
    isFetchingBarang = false;
  });
}

  Future<void> _submitPeminjaman() async {
  final nama = namaController.text.trim();
  final alasan = alasanController.text.trim();
  final jumlah = int.tryParse(jumlahController.text);
  final tanggal = tanggalController.text.trim();

  if (nama.isEmpty || alasan.isEmpty || selectedBarang == null || jumlah == null || tanggal.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Harap isi semua field')),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    final Peminjaman peminjaman = await PeminjamanService.createPeminjaman(
      token: widget.token,
      namaPeminjam: nama,
      alasanMeminjam: alasan,
      barangId: selectedBarang!.id,  // Use selectedBarang's ID
      jumlah: jumlah,
      tanggalPinjam: tanggal,
      status: 'pending',  // Add status as pending
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Berhasil! ID Peminjaman: ${peminjaman.id}')),
    );

    namaController.clear();
    jumlahController.clear();
    alasanController.clear();
    tanggalController.clear();
    setState(() {
      selectedBarang = null;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal mengirim peminjaman')),
    );
  }

  setState(() => isLoading = false);
}


  void _selectTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Peminjaman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Peminjam',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown for selecting Barang
            isFetchingBarang
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<BarangModel>(
                    value: selectedBarang,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Barang',
                      border: OutlineInputBorder(),
                    ),
                    items: barangList.map((BarangModel barang) {
                      return DropdownMenuItem<BarangModel>(
                        value: barang,
                        child: Text(barang.namaBarang),
                      );
                    }).toList(),
                    onChanged: (BarangModel? newValue) {
                      setState(() {
                        selectedBarang = newValue;
                      });
                    },
                    hint: const Text('Pilih Barang'),
                  ),
            const SizedBox(height: 16),
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alasan Meminjam',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tanggalController,
              readOnly: true,
              onTap: _selectTanggal,
              decoration: const InputDecoration(
                labelText: 'Tanggal Pinjam',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitPeminjaman,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kirim Peminjaman',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
