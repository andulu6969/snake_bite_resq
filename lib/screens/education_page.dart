import 'package:flutter/material.dart';
import 'package:snake_bite_resq/screens/test_datail_screen.dart';
import 'package:snake_bite_resq/screens/legal_info_screen.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const List<Map<String, dynamic>> _allItems = [
    {
      "title": "20WBCT",
      "subtitle": "Whole Blood Clotting Test",
      "category": "BEDSIDE",
      "color": Colors.red,
      "icon": Icons.water_drop,
    },
    {
      "title": "Neostigmine Test",
      "subtitle": "Neurotoxic reversibility assessment",
      "category": "BEDSIDE",
      "color": Colors.purple,
      "icon": Icons.visibility,
    },
    {
      "title": "Single Breath Count",
      "subtitle": "Respiratory failure monitoring",
      "category": "OBSERVATION",
      "color": Colors.blue,
      "icon": Icons.timer,
    },
    {
      "title": "Antivenom Dosage",
      "subtitle": "Polyvalent vs Monovalent Dosing",
      "category": "MEDICATION",
      "color": Colors.teal,
      "icon": Icons.medication,
    },
    {
      "title": "Anaphylaxis Management",
      "subtitle": "Adrenaline & Corticosteroid Protocol",
      "category": "EMERGENCY",
      "color": Colors.orange,
      "icon": Icons.warning_amber,
    },
    {
      "title": "Terms & Conditions",
      "subtitle": "Disclaimer and Liability",
      "category": "LEGAL",
      "color": Colors.grey,
      "icon": Icons.gavel,
    },
    {
      "title": "Privacy Policy",
      "subtitle": "Data protection info",
      "category": "LEGAL",
      "color": Colors.blueGrey,
      "icon": Icons.security,
    },
    {
      "title": "About",
      "subtitle": "Version 1.0.0",
      "category": "INFO",
      "color": Colors.teal,
      "icon": Icons.info_outline,
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_query.isEmpty) return _allItems;
    final q = _query.toLowerCase();
    return _allItems.where((item) {
      return (item['title'] as String).toLowerCase().contains(q) ||
          (item['subtitle'] as String).toLowerCase().contains(q) ||
          (item['category'] as String).toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    // Group by section when not searching
    final bool isSearching = _query.isNotEmpty;
    final bedsideItems = filtered
        .where((i) => ['BEDSIDE', 'OBSERVATION'].contains(i['category']))
        .toList();
    final treatmentItems = filtered
        .where((i) => ['MEDICATION', 'EMERGENCY'].contains(i['category']))
        .toList();
    final infoItems = filtered
        .where((i) => ['LEGAL', 'INFO'].contains(i['category']))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Resources",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Clinical Protocols",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey.shade900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.blueGrey.shade900),
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: "Search guidelines, tests...",
                        hintStyle: TextStyle(color: Colors.blueGrey.shade400),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue.shade700,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.blueGrey.shade300,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          "No protocols found",
                          style: TextStyle(
                            color: Colors.blueGrey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (isSearching) ...[
                          const SizedBox(height: 16),
                          ...filtered.map(
                            (item) => _buildProtocolCard(context, item),
                          ),
                        ] else ...[
                          if (bedsideItems.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _sectionHeader("Bedside & Lab Tests"),
                            const SizedBox(height: 12),
                            ...bedsideItems.map(
                              (item) => _buildProtocolCard(context, item),
                            ),
                          ],
                          if (treatmentItems.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _sectionHeader("Treatment Guidelines"),
                            const SizedBox(height: 12),
                            ...treatmentItems.map(
                              (item) => _buildProtocolCard(context, item),
                            ),
                          ],
                          if (infoItems.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _sectionHeader("App Info"),
                            const SizedBox(height: 12),
                            ...infoItems.map(
                              (item) => _buildProtocolCard(context, item),
                            ),
                          ],
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey.shade700,
      ),
    );
  }

  Widget _buildProtocolCard(BuildContext context, Map<String, dynamic> item) {
    final Color color = item['color'] as Color;
    final String category = item['category'] as String;
    final String title = item['title'] as String;

    return GestureDetector(
      onTap: () {
        if (category == "LEGAL" || category == "INFO") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LegalInfoScreen(title: title)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TestDetailScreen(testName: title),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item['icon'] as IconData, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.blueGrey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
