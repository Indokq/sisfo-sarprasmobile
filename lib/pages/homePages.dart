import 'package:flutter/material.dart';
import 'package:sisfo_sarpras/pages/tabs/peminjaman_view.dart';
import 'tabs/barang_view.dart';


class HomePages extends StatelessWidget {
  final String token;
  const HomePages({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory App'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Barang'),
              Tab(text: 'Peminjaman'),
              Tab(text: 'Pengembalian'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BarangView(token: token),
            PeminjamanView(token: token)
          ],
        ),
      ),
    );
  }
}
