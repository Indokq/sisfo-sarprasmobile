import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/peminjaman_model.dart';
import '../../models/pengembalian_model.dart';
import '../../services/peminjaman_service.dart';
import '../../services/pengembalian_service.dart';

class PengembalianView extends StatefulWidget {
  final String token;
  const PengembalianView({super.key, required this.token});

  @override
  State<PengembalianView> createState() => _PengembalianViewState();
}

class _PengembalianViewState extends State<PengembalianView> {
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  bool isLoading = false;
  bool isFetchingPeminjaman = false;
  List<Peminjaman> peminjamanList = [];
  Peminjaman? selectedPeminjaman;

  @override
  void initState() {
    super.initState();
    _fetchPeminjaman();
    // Set tanggal hari ini sebagai default untuk tanggal pengembalian
    tanggalController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    jumlahController.dispose();
    keteranganController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> _fetchPeminjaman() async {
    setState(() {
      isFetchingPeminjaman = true;
    });

    try {
      // Ambil daftar peminjaman yang belum dikembalikan
      final List<Peminjaman> fetchedPeminjaman =
          await PeminjamanService.fetchPeminjaman(widget.token);

      final activePeminjaman = fetchedPeminjaman.where((p) {
        // Filter berdasarkan status - HANYA APPROVED yang bisa dikembalikan
        if (p.status.toLowerCase() != 'approved') {
          return false;
        }

        try {
          final DateTime pinjamDate = DateTime.parse(p.tanggalPinjam);
          final DateTime kembaliDate = pinjamDate.add(const Duration(days: 1));
          final DateTime today = DateTime.now();

          // Hanya tampilkan jika masih dalam batas waktu
          return today.isBefore(kembaliDate) ||
              today.isAtSameMomentAs(kembaliDate);
        } catch (e) {
          // Jika error parsing tanggal, tetap tampilkan untuk safety
          return true;
        }
      }).toList();

      if (!mounted) return;

      setState(() {
        peminjamanList = activePeminjaman;
        if (peminjamanList.isNotEmpty) {
          selectedPeminjaman = peminjamanList[0]; // Set default selected item
          // Auto-fill jumlah dengan jumlah yang dipinjam untuk item pertama
          jumlahController.text = peminjamanList[0].jumlah.toString();
        } else {
          selectedPeminjaman = null;
          jumlahController.clear();
        }
      });
    } catch (e) {
      if (!mounted) return;

      // Show error in the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data peminjaman: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      isFetchingPeminjaman = false;
    });
  }

  Future<void> _selectTanggal() async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today, // Default ke hari ini
      firstDate: today, // Cuma bisa pilih hari ini atau setelahnya
      lastDate: today, // Maksimal hari ini (jadi cuma bisa pilih hari ini)
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitPengembalian() async {
    final jumlah = int.tryParse(jumlahController.text);
    final keterangan = keteranganController.text.trim();
    final tanggal = tanggalController.text.trim();

    if (selectedPeminjaman == null ||
        jumlah == null ||
        keterangan.isEmpty ||
        tanggal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua field')),
      );
      return;
    }

    // Validasi jumlah harus sama dengan jumlah yang dipinjam
    if (jumlah != selectedPeminjaman!.jumlah) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '❌ Jumlah pengembalian tidak valid!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Jumlah dikembalikan: $jumlah',
              ),
              Text(
                'Jumlah yang dipinjam: ${selectedPeminjaman!.jumlah}',
              ),
              const Text(
                'Jumlah pengembalian harus sama dengan jumlah peminjaman.',
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Validasi tanggal pengembalian harus hari ini
    final String todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (tanggal != todayString) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Tanggal pengembalian harus hari ini!'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final DateTime pinjamDate =
          DateTime.parse(selectedPeminjaman!.tanggalPinjam);
      final DateTime kembaliDate = pinjamDate.add(const Duration(days: 1));
      final DateTime today = DateTime.now();

      if (today.isAfter(kembaliDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('❌ Batas waktu pengembalian telah habis!'),
                Text(
                    'Batas: ${DateFormat('dd MMMM yyyy').format(kembaliDate)}'),
                const Text('Barang tidak dapat dikembalikan setelah 1 hari.'),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Format tanggal peminjaman tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final Pengembalian pengembalian =
          await PengembalianService.createPengembalian(
        token: widget.token,
        peminjamanId: selectedPeminjaman!.id,
        jumlahDikembalikan: jumlah,
        keterangan: keterangan,
        tanggalPengembalian: tanggal,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Berhasil! ID Pengembalian: ${pengembalian.id}')),
      );

      // Reset form dengan tanggal hari ini sebagai default
      jumlahController.clear();
      keteranganController.text = '';
      tanggalController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Refresh peminjaman list
      _fetchPeminjaman();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pengembalian: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      prefixIcon: Icon(icon, color: Colors.indigo.shade700),
      filled: true,
      fillColor: Colors.grey.shade50,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.indigo.shade700, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.indigo.shade700;
    final secondaryColor = Colors.indigo.shade100;

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
                        Icons.assignment_return,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Form Pengembalian Barang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Silakan isi form berikut untuk mengembalikan barang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form fields
                  Text(
                    'Informasi Peminjaman',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown for selecting Peminjaman
                  isFetchingPeminjaman
                      ? Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : peminjamanList.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange.shade800,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tidak ada peminjaman yang dapat dikembalikan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Hanya peminjaman yang sudah disetujui (APPROVED) dan dalam 1 hari setelah tanggal pinjam yang dapat dikembalikan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Peminjaman>(
                                  isExpanded: true,
                                  value: selectedPeminjaman,
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      'Pilih Peminjaman',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  icon: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Icon(Icons.arrow_drop_down,
                                        color: primaryColor),
                                  ),
                                  items: peminjamanList.map((peminjaman) {
                                    return DropdownMenuItem<Peminjaman>(
                                      value: peminjaman,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          '${peminjaman.namaBarang ?? 'Barang #${peminjaman.barangId}'} (${peminjaman.jumlah} unit)',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Peminjaman? newValue) {
                                    setState(() {
                                      selectedPeminjaman = newValue;
                                      // Auto-fill jumlah dengan jumlah yang dipinjam
                                      if (newValue != null) {
                                        jumlahController.text =
                                            newValue.jumlah.toString();
                                      } else {
                                        jumlahController.clear();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                  const SizedBox(height: 24),

                  // Jumlah
                  TextField(
                    controller: jumlahController,
                    keyboardType: TextInputType.number,
                    readOnly: true, // Make it read-only to prevent manipulation
                    enabled: peminjamanList.isNotEmpty,
                    decoration: InputDecoration(
                      labelText: 'Jumlah Dikembalikan',
                      hintText: selectedPeminjaman != null
                          ? 'Otomatis sesuai jumlah pinjam: ${selectedPeminjaman!.jumlah} unit'
                          : 'Pilih peminjaman terlebih dahulu',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
                      prefixIcon:
                          Icon(Icons.numbers, color: Colors.indigo.shade700),
                      suffixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.grey
                          .shade100, // Different color to show it's read-only
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.indigo.shade700, width: 2),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info box tentang jumlah pengembalian
                  if (selectedPeminjaman != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jumlah Pengembalian Otomatis',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Jumlah dikembalikan otomatis sama dengan jumlah yang dipinjam (${selectedPeminjaman!.jumlah} unit) untuk mencegah manipulasi data.',
                                  style: TextStyle(
                                    color: Colors.green.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (selectedPeminjaman != null) const SizedBox(height: 24),
                  if (selectedPeminjaman == null) const SizedBox(height: 24),

                  // Tanggal
                  TextField(
                    controller: tanggalController,
                    readOnly: true,
                    enabled: peminjamanList.isNotEmpty,
                    onTap: peminjamanList.isNotEmpty ? _selectTanggal : null,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Pengembalian',
                      hintText: 'Hanya bisa hari ini',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
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

                  // Info box tentang tanggal pengembalian
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tanggal pengembalian hanya bisa hari ini untuk mencegah manipulasi data',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Keterangan
                  TextField(
                    controller: keteranganController,
                    maxLines: 3,
                    enabled: peminjamanList.isNotEmpty,
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
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
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (isLoading || peminjamanList.isEmpty)
                          ? null
                          : _submitPengembalian,
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'KIRIM PENGEMBALIAN',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
