import 'package:flutter/material.dart';
import '../../../models/barang_model.dart';

class BarangCard extends StatelessWidget {
  final BarangModel barang;
  const BarangCard({super.key, required this.barang});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final imageHeight = screenSize.width < 360 ? 100.0 : 120.0;

    // Generate a color based on the barang ID for variety
    final Color cardColor =
        Colors.primaries[barang.id % Colors.primaries.length].shade50;
    final Color iconColor =
        Colors.primaries[barang.id % Colors.primaries.length].shade700;

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // You can add navigation to detail page here
        },
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for preventing overflow
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: barang.foto != null && barang.foto!.isNotEmpty
                  ? Image.network(
                      barang.foto!,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: imageHeight,
                          width: double.infinity,
                          color: cardColor,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: screenSize.width < 360 ? 40 : 50,
                              color: iconColor,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: imageHeight,
                          width: double.infinity,
                          color: cardColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: iconColor,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: imageHeight,
                      width: double.infinity,
                      color: cardColor,
                      child: Center(
                        child: Icon(
                          Icons.inventory,
                          size: screenSize.width < 360 ? 40 : 50,
                          color: iconColor,
                        ),
                      ),
                    ),
            ),

            // Content section
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(screenSize.width < 360 ? 8.0 : 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item name
                    Text(
                      barang.namaBarang,
                      style: TextStyle(
                        fontSize: screenSize.width < 360 ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenSize.width < 360 ? 2 : 4),

                    // Category
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: screenSize.width < 360 ? 12 : 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: screenSize.width < 360 ? 2 : 4),
                        Expanded(
                          child: Text(
                            barang.namaKategori,
                            style: TextStyle(
                              fontSize: screenSize.width < 360 ? 10 : 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenSize.width < 360 ? 4 : 8),

                    // Stock badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width < 360 ? 6 : 8,
                        vertical: screenSize.width < 360 ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Stok: ${barang.jumlahTersedia}',
                        style: TextStyle(
                          fontSize: screenSize.width < 360 ? 10 : 11,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
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
}
