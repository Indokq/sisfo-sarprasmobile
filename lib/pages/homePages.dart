import 'package:flutter/material.dart';
import 'package:sisfo_sarpras/pages/tabs/peminjaman_view.dart';
import 'package:sisfo_sarpras/pages/tabs/riwayat_peminjaman_view.dart';
import 'tabs/barang_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePages extends StatefulWidget {
  final String token;
  const HomePages({super.key, required this.token});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  int _selectedIndex = 0; // Untuk menyimpan index tab yang dipilih
  late List<Widget> _pages; // Daftar halaman yang akan ditampilkan

  @override
  void initState() {
    super.initState();
    // Inisialisasi halaman dengan token yang benar
    _pages = [
      BarangView(token: widget.token),
      PeminjamanView(token: widget.token),
      RiwayatPeminjamanView(token: widget.token),
    ];
  }

  // Fungsi untuk menangani pemilihan item di BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    // Hapus token dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');

    // Periksa apakah widget masih terpasang sebelum navigasi
    if (!mounted) return;

    // Arahkan ke halaman login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: const Text(
          'SARPRAS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle,
                color: Colors.indigo, size: 30),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: _pages[
          _selectedIndex], // Menampilkan halaman sesuai dengan tab yang dipilih
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.indigo.shade700,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2),
                activeIcon: Icon(Icons.inventory_2, size: 28),
                label: 'Barang',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                activeIcon: Icon(Icons.assignment, size: 28),
                label: 'Peminjaman',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Icon(Icons.history, size: 28),
                label: 'Riwayat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
