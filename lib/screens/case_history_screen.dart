import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:snake_bite_resq/services/offline_cache_service.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';
import 'package:snake_bite_resq/widgets/glass_card.dart';
import 'package:snake_bite_resq/widgets/offline_banner.dart';

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
  String? _hospitalName;
  bool _isOffline = false;

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
    final auth = Provider.of<AuthService>(context, listen: false);
    _unitId      = auth.unitId;
    _hospitalName = auth.hospitalName;
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
      hospitalName: _unitId == 'ALL' ? null : _hospitalName,
      unitId: _unitId == 'ALL' ? 'ALL' : null,
      page: _currentPage,
      limit: _pageSize,
      search: _activeSearch,
      severity: _activeSeverity,
    );

    if (!mounted) return;

    final newRecords  = List<Map<String, dynamic>>.from(result['records'] ?? []);
    final totalPages  = result['pages'] ?? 1;
    final fromCache   = result['status'] == 'offline';

    setState(() {
      _records.addAll(newRecords);
      _totalRecords = result['total'] ?? 0;
      _hasMore      = _currentPage < totalPages;
      _currentPage++;
      _isLoading    = false;
      _isOffline    = fromCache;
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
              Row(
                children: [
                  Text(
                    'Case History',
                    style: TextStyle(
                      color: Colors.blueGrey.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (_isOffline) ...
                    [
                      const SizedBox(width: 8),
                      const OfflineChip(),
                    ],
                ],
              ),
              Text(
                '$_totalRecords record${_totalRecords == 1 ? '' : 's'} · ${_hospitalName ?? _unitId ?? ''}',
                style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 11),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Offline banner — slides in when serving cached records
            if (_isOffline)
              OfflineBanner(
                cacheAgeLabel:  OfflineCacheService.ageLabel(
                  null, // age shown via cache timestamp if available
                ),
                pendingUploads: OfflineCacheService.pendingCount,
                onRetry: () => _loadRecords(reset: true),
              ),
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
    // Offline AND no cached records at all
    if (_isOffline && _activeSearch.isEmpty && _activeSeverity.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.shade200, width: 1.5),
                ),
                child: Icon(Icons.cloud_off_rounded,
                    size: 48, color: Colors.orange.shade500),
              ),
              const SizedBox(height: 20),
              Text(
                'No Cached Records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You're offline and no case history\nhas been cached on this device yet.\n\nConnect to the hospital server to\nload and cache records.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey.shade400,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _loadRecords(reset: true),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry Connection'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade700,
                  side: BorderSide(color: Colors.orange.shade400),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Normal empty states (online or filtered)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _activeSearch.isNotEmpty || _activeSeverity.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.folder_open_outlined,
              size: 64,
              color: Colors.blueGrey.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              _activeSearch.isNotEmpty || _activeSeverity.isNotEmpty
                  ? 'No records match your filter'
                  : 'No cases recorded yet',
              style: TextStyle(
                  color: Colors.blueGrey.shade500, fontSize: 16),
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
            if ((record['ic_passport'] as String? ?? '').isNotEmpty) ...
              [
                const SizedBox(height: 10),
                _detailRow(Icons.badge_outlined, 'IC / Passport', record['ic_passport'] as String),
              ],
            if ((record['diagnosed_by'] as String? ?? '').isNotEmpty) ...
              [
                const SizedBox(height: 10),
                _detailRow(Icons.person_outlined, 'Diagnosed by', record['diagnosed_by'] as String),
              ],
            const SizedBox(height: 10),
            _detailRow(
              Icons.local_hospital_outlined,
              'Hospital',
              (record['hospital_name'] as String? ?? _hospitalName) ?? '—',
            ),
            const SizedBox(height: 10),
            // MOH Validated badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_outlined, color: Colors.indigo.shade400, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Validated by Ministry of Health Malaysia',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.indigo.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
