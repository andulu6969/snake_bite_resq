import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // #5: Shimmer loading
import 'package:provider/provider.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';
import 'package:snake_bite_resq/widgets/glass_card.dart';

class CaseHistoryScreen extends StatefulWidget {
  const CaseHistoryScreen({super.key});

  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce; // #5: debounce timer

  List<Map<String, dynamic>> _records = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalRecords = 0;
  String _activeSearch = '';
  String _activeSeverity = '';
  String? _unitId;

  static const int _pageSize = 15;

  static const List<Map<String, dynamic>> _severityFilters = [
    {'label': 'All', 'value': '', 'color': Colors.blueGrey},
    {'label': 'CRITICAL', 'value': 'CRITICAL', 'color': Colors.red},
    {'label': 'HIGH', 'value': 'HIGH', 'color': Colors.orange},
    {'label': 'MODERATE', 'value': 'MODERATE', 'color': Colors.amber},
    {'label': 'LOW', 'value': 'LOW', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _unitId = Provider.of<AuthService>(context, listen: false).unitId;
    _loadRecords(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) _loadRecords();
    }
  }

  Future<void> _loadRecords({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      setState(() {
        _records = [];
        _currentPage = 1;
        _hasMore = true;
      });
    }

    setState(() => _isLoading = true);

    final result = await ApiService.getCaseHistory(
      unitId: _unitId,
      page: _currentPage,
      limit: _pageSize,
      search: _activeSearch,
      severity: _activeSeverity,
    );

    if (!mounted) return;

    final newRecords = List<Map<String, dynamic>>.from(result['records'] ?? []);
    final totalPages = result['pages'] ?? 1;

    setState(() {
      _records.addAll(newRecords);
      _totalRecords = result['total'] ?? 0;
      _hasMore = _currentPage < totalPages;
      _currentPage++;
      _isLoading = false;
    });
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value == _activeSearch) return;
      _activeSearch = value;
      _loadRecords(reset: true);
    });
  }

  void _onSeverityFilter(String value) {
    if (value == _activeSeverity) return;
    _activeSeverity = value;
    _loadRecords(reset: true);
  }

  Color _severityColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MODERATE':
        return Colors.amber;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.blueGrey.shade300;
    }
  }

  IconData _dispositionIcon(String? disposition) {
    if (disposition == null) return Icons.help_outline;
    final d = disposition.toLowerCase();
    if (d.contains('icu')) return Icons.monitor_heart;
    if (d.contains('ward')) return Icons.bed;
    if (d.contains('observation')) return Icons.visibility;
    if (d.contains('discharge')) return Icons.exit_to_app;
    return Icons.local_hospital;
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blueGrey.shade900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Case History',
                style: TextStyle(
                  color: Colors.blueGrey.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '$_totalRecords record${_totalRecords == 1 ? '' : 's'} · ${_unitId ?? ''}',
                style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 11),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                borderRadius: BorderRadius.circular(14),
                opacity: 0.7,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.blueGrey.shade900),
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search by patient ID or species...',
                    hintStyle: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    suffixIcon: _activeSearch.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.blueGrey.shade400,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            // --- SEVERITY FILTER CHIPS ---
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _severityFilters.map((f) {
                  final isActive = _activeSeverity == f['value'];
                  final color = f['color'] as Color;
                  return GestureDetector(
                    onTap: () => _onSeverityFilter(f['value']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? color.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? color : Colors.grey.shade300,
                          width: isActive ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        f['label'],
                        style: TextStyle(
                          color: isActive ? color : Colors.blueGrey.shade600,
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // --- RECORDS LIST ---
            Expanded(
              child: _records.isEmpty && !_isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: _records.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _records.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child:
                                _buildShimmerCard(), // #5: Shimmer placeholder
                          );
                        }
                        return _buildRecordCard(_records[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // #5: Shimmer placeholder card
  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 80, height: 14, color: Colors.white),
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(width: 150, height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 12, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: Colors.blueGrey.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              _activeSearch.isNotEmpty || _activeSeverity.isNotEmpty
                  ? 'No records match your filter'
                  : 'No cases recorded yet',
              style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final severity = record['severity'] as String?;
    final disposition = record['disposition'] as String?;
    final species = record['species'] as String? ?? 'Unknown Species';
    final patientId = record['patient_id'] as String? ?? '—';
    final recordedAt = record['recorded_at'] as String? ?? '';
    final color = _severityColor(severity);

    // Format date nicely
    String formattedDate = recordedAt;
    try {
      final dt = DateTime.parse(recordedAt);
      formattedDate =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return GestureDetector(
      onTap: () => _showDetailSheet(record),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Severity indicator bar
            Container(
              width: 4,
              height: 64,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        patientId,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.withValues(
                              alpha: 0.5,
                            ), // More visible border
                          ),
                          boxShadow: [
                            // #4: Context-Aware Glowing border
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Text(
                          severity ?? 'UNKNOWN',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    species,
                    style: TextStyle(
                      color: Colors.blueGrey.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _dispositionIcon(disposition),
                        color: Colors.blueGrey.shade400,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        disposition ?? '—',
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        color: Colors.blueGrey.shade400,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.blueGrey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ), // closes Row (GlassCard child)
      ), // closes GlassCard (GestureDetector child)
    ); // closes GestureDetector return
  }

  // #7: detail bottom sheet shown on card tap
  void _showDetailSheet(Map<String, dynamic> record) {
    final severity = record['severity'] as String?;
    final disposition = record['disposition'] as String?;
    final species = record['species'] as String? ?? 'Unknown';
    final patientId = record['patient_id'] as String? ?? '—';
    final recordedAt = record['recorded_at'] as String? ?? '';
    final color = _severityColor(severity);

    String formattedDate = recordedAt;
    try {
      final dt = DateTime.parse(recordedAt);
      formattedDate =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  patientId,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    severity ?? 'UNKNOWN',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.pest_control, 'Species', species),
            const SizedBox(height: 10),
            _detailRow(
              _dispositionIcon(disposition),
              'Disposition',
              disposition ?? '—',
            ),
            const SizedBox(height: 10),
            _detailRow(Icons.access_time, 'Recorded', formattedDate),
            const SizedBox(height: 10),
            _detailRow(Icons.badge_outlined, 'Unit', _unitId ?? '—'),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade400),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.blueGrey.shade500,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
