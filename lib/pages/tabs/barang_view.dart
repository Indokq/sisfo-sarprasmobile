import 'package:flutter/material.dart';
import '../../../models/barang_model.dart';
import '../../services/api_service.dart';
import '..//widgets/barang_card.dart';

class BarangView extends StatefulWidget {
  final String token;
  const BarangView({super.key, required this.token});

  @override
  State<BarangView> createState() => _BarangViewState();
}

class _BarangViewState extends State<BarangView> {
  late Future<List<BarangModel>> _barangListFuture;
  List<BarangModel> _allBarang = [];
  List<BarangModel> _filteredBarang = [];
  List<Map<String, dynamic>> _kategoriList = [];
  Map<String, dynamic>? _selectedKategori;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil data barang
      _barangListFuture = ApiService.fetchBarangs(widget.token);
      _allBarang = await _barangListFuture;
      _filteredBarang = List.from(_allBarang);

      // Ekstrak kategori unik dari data barang
      final Set<int> uniqueKategoriIds = {};
      _kategoriList = [];

      // Tambahkan opsi "Semua Kategori" di awal list
      _kategoriList.add({'id': 0, 'nama_kategori': 'Semua Kategori'});

      // Tambahkan kategori unik dari barang
      for (var barang in _allBarang) {
        if (!uniqueKategoriIds.contains(barang.idKategori)) {
          uniqueKategoriIds.add(barang.idKategori);
          _kategoriList.add(
              {'id': barang.idKategori, 'nama_kategori': barang.namaKategori});
        }
      }

      _selectedKategori = _kategoriList.first;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterBarang() {
    setState(() {
      // Filter berdasarkan kategori
      if (_selectedKategori != null && _selectedKategori!['id'] != 0) {
        _filteredBarang = _allBarang
            .where((barang) => barang.idKategori == _selectedKategori!['id'])
            .toList();
      } else {
        _filteredBarang = List.from(_allBarang);
      }

      // Filter berdasarkan pencarian
      if (_searchQuery.isNotEmpty) {
        _filteredBarang = _filteredBarang
            .where((barang) => barang.namaBarang
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterBarang();
    });
  }

  void _onKategoriChanged(Map<String, dynamic>? kategori) {
    setState(() {
      _selectedKategori = kategori;
      _filterBarang();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari barang...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
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
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Kategori dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    value: _selectedKategori,
                    items: _kategoriList.map((kategori) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: kategori,
                        child: Text(
                          kategori['nama_kategori'],
                          style: TextStyle(
                            color: kategori['id'] == 0
                                ? Colors.grey.shade700
                                : Colors.black,
                            fontWeight: kategori['id'] == 0
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _onKategoriChanged,
                    hint: const Text('Pilih Kategori'),
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menampilkan ${_filteredBarang.length} barang',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Refresh data',
              ),
            ],
          ),
        ),

        // Barang list
        Expanded(
          child: _filteredBarang.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada barang yang ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty ||
                          _selectedKategori!['id'] != 0)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedKategori = _kategoriList.first;
                              _filterBarang();
                            });
                          },
                          child: const Text('Reset Filter'),
                        ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate responsive values based on screen width
                    final screenWidth = MediaQuery.of(context).size.width;

                    // Determine number of columns based on screen width
                    int crossAxisCount = 2; // Default for most phones
                    if (screenWidth < 360) {
                      crossAxisCount = 1; // Very small phones - single column
                    } else if (screenWidth >= 600) {
                      crossAxisCount = 3; // Tablets - 3 columns
                    } else if (screenWidth >= 900) {
                      crossAxisCount =
                          4; // Large tablets/small desktops - 4 columns
                    }

                    // Calculate dynamic aspect ratio based on available width
                    // This ensures cards have proper proportions on all devices
                    final itemWidth = (constraints.maxWidth -
                            (16 * 2) -
                            ((crossAxisCount - 1) * 10)) /
                        crossAxisCount;
                    final aspectRatio = itemWidth /
                        (itemWidth *
                            1.4); // Adjust multiplier for desired height

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _filteredBarang.length,
                      itemBuilder: (context, index) {
                        return BarangCard(barang: _filteredBarang[index]);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
