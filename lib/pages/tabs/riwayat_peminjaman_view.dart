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
  List<Peminjaman> _filteredPeminjaman = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final Map<int, BarangModel> _barangCache = {};
  String _selectedStatus = 'Semua'; // Filter status
  final TextEditingController _searchController = TextEditingController();

  // List status yang tersedia untuk filter
  final List<String> _statusOptions = [
    'Semua',
    'pending',
    'approved',
    'rejected',
    'returned',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPeminjaman();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _filteredPeminjaman = peminjaman; // Initialize filtered list
          _isLoading = false;
        });
        _applyFilters(); // Apply current filters
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

  // Fungsi untuk menerapkan filter
  void _applyFilters() {
    setState(() {
      _filteredPeminjaman = _peminjaman.where((peminjaman) {
        // Filter berdasarkan status
        bool statusMatch = _selectedStatus == 'Semua' ||
            peminjaman.status.toLowerCase() == _selectedStatus.toLowerCase();

        // Filter berdasarkan pencarian
        bool searchMatch = _searchController.text.isEmpty ||
            _getBarangName(peminjaman.barangId, peminjaman: peminjaman)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            peminjaman.namaPeminjam
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        return statusMatch && searchMatch;
      }).toList();
    });
  }

  // Fungsi untuk mengubah filter status
  void _onStatusFilterChanged(String? newStatus) {
    if (newStatus != null) {
      setState(() {
        _selectedStatus = newStatus;
      });
      _applyFilters();
    }
  }

  // Fungsi untuk pencarian
  void _onSearchChanged(String query) {
    _applyFilters();
  }

  // Fungsi untuk mendapatkan label status yang lebih friendly
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'semua':
        return 'Semua Status';
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'returned':
        return 'Dikembalikan';
      default:
        return status;
    }
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
                      const SizedBox(height: 16),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText:
                                'Cari berdasarkan nama barang atau peminjam...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.indigo.shade700),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear,
                                        color: Colors.grey.shade600),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter Row
                      Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: Colors.indigo.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filter:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedStatus,
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors.indigo.shade700),
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 14,
                                  ),
                                  items: _statusOptions.map((String status) {
                                    return DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(_getStatusLabel(status)),
                                    );
                                  }).toList(),
                                  onChanged: _onStatusFilterChanged,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                          : _filteredPeminjaman.isEmpty
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
                                        _peminjaman.isEmpty
                                            ? 'Belum ada riwayat peminjaman'
                                            : 'Tidak ada data yang sesuai dengan filter',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchPeminjaman,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Calculate responsive values based on screen width
                                      final screenWidth =
                                          MediaQuery.of(context).size.width;

                                      // Determine number of columns based on screen width
                                      int crossAxisCount =
                                          2; // Default for most phones
                                      if (screenWidth < 360) {
                                        crossAxisCount =
                                            1; // Very small phones - single column
                                      } else if (screenWidth >= 600) {
                                        crossAxisCount =
                                            3; // Tablets - 3 columns
                                      } else if (screenWidth >= 900) {
                                        crossAxisCount =
                                            4; // Large tablets/small desktops - 4 columns
                                      }

                                      // Calculate dynamic aspect ratio based on available width
                                      final itemWidth = (constraints.maxWidth -
                                              (16 * 2) -
                                              ((crossAxisCount - 1) * 10)) /
                                          crossAxisCount;
                                      final aspectRatio = itemWidth /
                                          (itemWidth *
                                              1.3); // Adjust multiplier for desired height

                                      return GridView.builder(
                                        padding: const EdgeInsets.all(16),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          childAspectRatio: aspectRatio,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount: _filteredPeminjaman.length,
                                        itemBuilder: (context, index) {
                                          final pinjam =
                                              _filteredPeminjaman[index];
                                          return _buildPeminjamanCard(pinjam);
                                        },
                                      );
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

  // Widget untuk menampilkan card peminjaman dengan desain yang lebih modern
  Widget _buildPeminjamanCard(Peminjaman pinjam) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status dan tanggal
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(pinjam.status).withOpacity(0.1),
                    _getStatusColor(pinjam.status).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 10,
                      vertical: isSmallScreen ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(pinjam.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(pinjam.status),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 10 : 11,
                      ),
                    ),
                  ),
                  // Tanggal
                  Text(
                    _formatDate(pinjam.tanggalPinjam),
                    style: TextStyle(
                      color: _getStatusColor(pinjam.status),
                      fontSize: isSmallScreen ? 10 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama barang
                    Text(
                      _getBarangName(pinjam.barangId, peminjaman: pinjam),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isSmallScreen ? 8 : 10),

                    // Info rows
                    _buildInfoRow(
                      Icons.inventory_2_outlined,
                      'Jumlah',
                      '${pinjam.jumlah} unit',
                      isSmallScreen,
                    ),

                    SizedBox(height: isSmallScreen ? 4 : 6),

                    _buildInfoRow(
                      Icons.person_outline,
                      'Peminjam',
                      pinjam.namaPeminjam,
                      isSmallScreen,
                    ),

                    if (pinjam.tanggalKembali.isNotEmpty) ...[
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      _buildInfoRow(
                        Icons.event_available_outlined,
                        'Tgl Kembali',
                        _formatDate(pinjam.tanggalKembali),
                        isSmallScreen,
                      ),
                    ],

                    const Spacer(),

                    // Alasan meminjam (jika ada ruang)
                    if (pinjam.alasanMeminjam.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '"${pinjam.alasanMeminjam}"',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk info rows
  Widget _buildInfoRow(
      IconData icon, String label, String value, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 14 : 16,
          color: Colors.indigo.shade600,
        ),
        SizedBox(width: isSmallScreen ? 6 : 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: Colors.grey.shade700,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
