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
      final List<BarangModel> fetchedBarang =
          await ApiService.fetchBarangs(widget.token);

      if (!mounted) return;

      setState(() {
        barangList = fetchedBarang;
        if (barangList.isNotEmpty) {
          selectedBarang = barangList[0]; // Set default selected item
        }
      });
    } catch (e) {
      if (!mounted) return;

      // Show error in the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data barang')),
      );
    }

    if (!mounted) return;

    setState(() {
      isFetchingBarang = false;
    });
  }

  Future<void> _submitPeminjaman() async {
    final nama = namaController.text.trim();
    final alasan = alasanController.text.trim();
    final jumlah = int.tryParse(jumlahController.text);
    final tanggal = tanggalController.text.trim();

    if (nama.isEmpty ||
        alasan.isEmpty ||
        selectedBarang == null ||
        jumlah == null ||
        tanggal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua field')),
      );
      return;
    }

    // Hitung tanggal kembali otomatis (7 hari setelah tanggal pinjam)
    String tanggalKembali;
    try {
      final DateTime pinjamDate = DateTime.parse(tanggal);
      final DateTime kembaliDate = pinjamDate.add(const Duration(days: 7));
      tanggalKembali = DateFormat('yyyy-MM-dd').format(kembaliDate);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format tanggal tidak valid')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final Peminjaman peminjaman = await PeminjamanService.createPeminjaman(
        token: widget.token,
        namaPeminjam: nama,
        alasanMeminjam: alasan,
        barangId: selectedBarang!.id, // Use selectedBarang's ID
        jumlah: jumlah,
        tanggalPinjam: tanggal,
        tanggalKembali:
            tanggalKembali, // Otomatis 7 hari setelah tanggal pinjam
        status: 'pending', // Add status as pending
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Peminjaman berhasil diajukan!'),
              Text('ID: ${peminjaman.id}'),
              Text('Batas kembali: ${_getReturnDate()}'),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      namaController.clear();
      jumlahController.clear();
      alasanController.clear();
      tanggalController.clear();
      setState(() {
        selectedBarang = barangList.isNotEmpty ? barangList[0] : null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim peminjaman')),
      );
    }

    if (!mounted) return;

    setState(() => isLoading = false);
  }

  void _selectTanggal() async {
    if (!mounted) return;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {}); // Refresh UI to show return date
    }
  }

  // Helper method untuk mendapatkan tanggal kembali yang dihitung otomatis
  String _getReturnDate() {
    if (tanggalController.text.isEmpty) return '-';

    try {
      final DateTime pinjamDate = DateTime.parse(tanggalController.text);
      final DateTime kembaliDate = pinjamDate.add(const Duration(days: 7));
      return DateFormat('dd MMMM yyyy', 'id_ID').format(kembaliDate);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.indigo.shade700;
    final secondaryColor = Colors.indigo.shade100;

    // Custom input decoration
    InputDecoration buildInputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.indigo.shade50,
                  Colors.white,
                ],
              ),
            ),
          ),

          // Form content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Form Peminjaman Barang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Silakan isi form berikut untuk meminjam barang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form fields
                  Text(
                    'Informasi Peminjam',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama Peminjam
                  TextField(
                    controller: namaController,
                    decoration:
                        buildInputDecoration('Nama Peminjam', Icons.person),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Informasi Barang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown for selecting Barang
                  isFetchingBarang
                      ? Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonFormField<BarangModel>(
                            value: selectedBarang,
                            decoration: InputDecoration(
                              labelText: 'Pilih Barang',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              prefixIcon:
                                  Icon(Icons.inventory, color: primaryColor),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            items: barangList.map((BarangModel barang) {
                              return DropdownMenuItem<BarangModel>(
                                value: barang,
                                child: Text(
                                  barang.namaBarang,
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (BarangModel? newValue) {
                              setState(() {
                                selectedBarang = newValue;
                              });
                            },
                            icon: Icon(Icons.arrow_drop_down,
                                color: primaryColor),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            hint: const Text('Pilih Barang'),
                          ),
                        ),
                  const SizedBox(height: 16),

                  // Jumlah
                  TextField(
                    controller: jumlahController,
                    keyboardType: TextInputType.number,
                    decoration: buildInputDecoration('Jumlah', Icons.numbers),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Detail Peminjaman',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alasan
                  TextField(
                    controller: alasanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Alasan Meminjam',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 64),
                        child: Icon(Icons.description, color: primaryColor),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal
                  TextField(
                    controller: tanggalController,
                    readOnly: true,
                    onTap: _selectTanggal,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Pinjam',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      prefixIcon: Icon(Icons.event, color: primaryColor),
                      suffixIcon:
                          Icon(Icons.calendar_today, color: primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info tanggal kembali otomatis
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal Kembali Otomatis',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Barang harus dikembalikan dalam 7 hari setelah tanggal pinjam. Setelah itu, barang tidak dapat dikembalikan.',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              if (tanggalController.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Tanggal kembali: ${_getReturnDate()}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitPeminjaman,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.send, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'KIRIM PEMINJAMAN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
