import 'package:flutter/material.dart';
import 'package:snake_bite_resq/models/hospital_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHospitalsPage extends StatelessWidget {
  const AdminHospitalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hospitals = Hospital.mockHospitals;
    final topPadding = MediaQuery.of(context).padding.top;
    final inStock = hospitals.where((h) => h.hasAntivenom).length;
    final outOfStock = hospitals.length - inStock;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 120),
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.local_hospital_rounded,
                color: Colors.blue.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hospital Network",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                  Text(
                    "${hospitals.length} facilities • $inStock stocked • $outOfStock unstocked",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Stock status summary strip
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStockIndicator(
                "In Stock",
                inStock,
                Colors.green,
                Icons.check_circle_rounded,
              ),
              const SizedBox(width: 20),
              Container(width: 1, height: 36, color: Colors.blueGrey.shade100),
              const SizedBox(width: 20),
              _buildStockIndicator(
                "No Stock",
                outOfStock,
                Colors.red,
                Icons.cancel_rounded,
              ),
              const Spacer(),
              // Percentage ring
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: inStock / hospitals.length,
                      strokeWidth: 5,
                      backgroundColor: Colors.red.shade100,
                      valueColor: AlwaysStoppedAnimation(Colors.green.shade500),
                    ),
                    Text(
                      "${(inStock / hospitals.length * 100).round()}%",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Hospital list
        ...hospitals.asMap().entries.map(
          (entry) => _buildHospitalCard(context, entry.value, entry.key),
        ),
      ],
    );
  }

  Widget _buildStockIndicator(
    String label,
    int count,
    MaterialColor color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: color.shade500, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey.shade900,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHospitalCard(
    BuildContext context,
    Hospital hospital,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showHospitalDetails(context, hospital),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hospital.hasAntivenom
                        ? Colors.blue.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: hospital.hasAntivenom
                          ? Colors.blue.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hospital.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey.shade500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Antivenom status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: hospital.hasAntivenom
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hospital.hasAntivenom
                                      ? Icons.verified_rounded
                                      : Icons.warning_rounded,
                                  size: 12,
                                  color: hospital.hasAntivenom
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hospital.hasAntivenom
                                      ? "IN STOCK"
                                      : "NO STOCK",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: hospital.hasAntivenom
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Phone badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hospital.phone,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Call button
                IconButton(
                  onPressed: () async {
                    final uri = Uri.parse('tel:${hospital.phone}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: Icon(Icons.phone_rounded, color: Colors.blue.shade600),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHospitalDetails(BuildContext context, Hospital hospital) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hospital.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: Colors.blueGrey.shade400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    hospital.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: 16,
                  color: Colors.blueGrey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  hospital.phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  hospital.hasAntivenom
                      ? Icons.verified_rounded
                      : Icons.warning_rounded,
                  size: 16,
                  color: hospital.hasAntivenom
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  hospital.hasAntivenom
                      ? "Antivenom In Stock"
                      : "No Antivenom Stock",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hospital.hasAntivenom
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.my_location_rounded,
                  size: 16,
                  color: Colors.blueGrey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  "Lat: ${hospital.lat.toStringAsFixed(4)}, Lng: ${hospital.lng.toStringAsFixed(4)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('tel:${hospital.phone}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.phone_rounded),
                label: const Text("Call Hospital"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
