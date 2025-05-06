import 'package:flutter/material.dart';
import 'package:sisfo_sarpras/pages/tabs/peminjaman_view.dart';
import 'tabs/barang_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePages extends StatefulWidget {
  final String token;
  const HomePages({Key? key, required this.token}) : super(key: key);

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  int _selectedIndex = 0; // Untuk menyimpan index tab yang dipilih

  // Daftar halaman yang akan ditampilkan sesuai dengan tab yang dipilih
  final List<Widget> _pages = [
    BarangView(token: 'sample_token'), // Ganti dengan widget yang sesuai
    PeminjamanView(token: 'sample_token'), // Ganti dengan widget yang sesuai
    Center(child: Text('Pengembalian (belum dibuat)')),
  ];

  // Fungsi untuk menangani pemilihan item di BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            icon: const Icon(Icons.account_circle, color: Colors.indigo, size: 30),
            onSelected: (value) async {
              if (value == 'logout') {
                // Hapus token dari SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                await prefs.remove('user_id');
                await prefs.remove('user_name');

                // Arahkan ke halaman login
                Navigator.pushReplacementNamed(context, '/login');
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
      body: _pages[_selectedIndex], // Menampilkan halaman sesuai dengan tab yang dipilih
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Menentukan tab yang aktif
        onTap: _onItemTapped, // Fungsi untuk mengubah halaman saat dipilih
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Peminjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Pengembalian',
          ),
        ],
      ),
    );
  }
}
