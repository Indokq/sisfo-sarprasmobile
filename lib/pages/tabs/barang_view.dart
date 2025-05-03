import 'package:flutter/material.dart';
import '../../../models/barang_model.dart';
import '../../services/api_service.dart';
import '..//widgets/barang_card.dart';

class BarangView extends StatefulWidget {
  final String token;
  const BarangView({Key? key, required this.token}) : super(key: key);

  @override
  State<BarangView> createState() => _BarangViewState();
}

class _BarangViewState extends State<BarangView> {
  late Future<List<BarangModel>> _barangList;

  @override
  void initState() {
    super.initState();
    _barangList = ApiService.fetchBarangs(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BarangModel>>(
      future: _barangList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada data barang.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return BarangCard(barang: snapshot.data![index]);
          },
        );
      },
    );
  }
}
