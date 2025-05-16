import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/peminjaman_model.dart';
import '../../services/peminjaman_service.dart';
import '../../services/api_service.dart';
import '../../models/barang_model.dart';

class RiwayatPeminjamanView extends StatefulWidget {
  final String token;

  const RiwayatPeminjamanView({super.key, required this.token});

  @override
  State<RiwayatPeminjamanView> createState() => _RiwayatPeminjamanViewState();
}

class _RiwayatPeminjamanViewState extends State<RiwayatPeminjamanView> {
  List<Peminjaman> _peminjaman = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<int, BarangModel> _barangCache = {};

  @override
  void initState() {
    super.initState();
    _fetchPeminjaman();
  }

  // Fungsi untuk mengambil data peminjaman
  Future<void> _fetchPeminjaman() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final peminjaman = await PeminjamanService.fetchPeminjaman(widget.token);

      // Ambil data barang untuk setiap peminjaman
      for (var pinjam in peminjaman) {
        if (!_barangCache.containsKey(pinjam.barangId)) {
          try {
            // Coba ambil data barang dari API
            final barang =
                await ApiService.fetchBarangById(widget.token, pinjam.barangId);

            // Debug: Print data barang yang diterima
            debugPrint(
                'Barang data for ID ${pinjam.barangId}: ${barang.namaBarang}');

            if (mounted) {
              _barangCache[pinjam.barangId] = barang;
            }
          } catch (e) {
            // Jika gagal mengambil data barang, buat objek barang dummy
            debugPrint('Gagal mengambil data barang ID ${pinjam.barangId}: $e');
            if (mounted) {
              // Buat objek barang dummy untuk ditampilkan
              // Gunakan nama barang dari peminjaman jika tersedia
              _barangCache[pinjam.barangId] = BarangModel(
                id: pinjam.barangId,
                namaBarang: pinjam.namaBarang ?? 'Barang #${pinjam.barangId}',
                deskripsi: 'Data tidak tersedia',
                idKategori: 0,
                namaKategori: 'Tidak diketahui',
                jumlahTersedia: 0,
              );
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _peminjaman = peminjaman;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mengambil data peminjaman: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi untuk memformat tanggal
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString; // Kembalikan string asli jika format tidak valid
    }
  }

  // Fungsi untuk mendapatkan warna berdasarkan status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'returned':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Fungsi untuk mendapatkan nama barang
  String _getBarangName(int barangId, {Peminjaman? peminjaman}) {
    // Prioritaskan nama barang dari cache
    if (_barangCache.containsKey(barangId)) {
      return _barangCache[barangId]!.namaBarang;
    }

    // Jika tidak ada di cache, coba ambil dari objek peminjaman
    if (peminjaman != null && peminjaman.namaBarang != null) {
      return peminjaman.namaBarang!;
    }

    // Fallback ke ID barang jika tidak ada informasi nama
    return 'Barang #$barangId';
  }

  @override
  Widget build(BuildContext context) {
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

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.indigo.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Riwayat Peminjaman',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Daftar peminjaman yang telah Anda lakukan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Divider(color: Colors.grey.shade300, height: 1),

                // Content - List of peminjaman
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade300,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage,
                                    style:
                                        TextStyle(color: Colors.red.shade700),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _fetchPeminjaman,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Coba Lagi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _peminjaman.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        color: Colors.grey.shade400,
                                        size: 64,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Belum ada riwayat peminjaman',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchPeminjaman,
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, // 2 cards per row
                                      childAspectRatio:
                                          0.85, // Adjust for card height
                                      crossAxisSpacing:
                                          10, // Horizontal spacing
                                      mainAxisSpacing: 10, // Vertical spacing
                                    ),
                                    itemCount: _peminjaman.length,
                                    itemBuilder: (context, index) {
                                      final pinjam = _peminjaman[index];
                                      return _buildPeminjamanCard(pinjam);
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan card peminjaman
  Widget _buildPeminjamanCard(Peminjaman pinjam) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(pinjam.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(pinjam.status),
                  width: 1,
                ),
              ),
              child: Text(
                pinjam.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(pinjam.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Nama barang
            Text(
              _getBarangName(pinjam.barangId, peminjaman: pinjam),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Tanggal
            Text(
              _formatDate(pinjam.tanggalPinjam),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            // Jumlah
            Row(
              children: [
                Icon(
                  Icons.numbers,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Jumlah: ${pinjam.jumlah}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Peminjam
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Peminjam: ${pinjam.namaPeminjam}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
