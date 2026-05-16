import 'package:flutter/material.dart';

/// Animated banner shown at the top of screens when the app is offline.
/// Displays cached data age and a manual sync/retry button.
class OfflineBanner extends StatefulWidget {
  final String cacheAgeLabel;
  final int pendingUploads;
  final VoidCallback? onRetry;
  final bool isStale;

  const OfflineBanner({
    super.key,
    required this.cacheAgeLabel,
    this.pendingUploads = 0,
    this.onRetry,
    this.isStale = false,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isStale ? Colors.red.shade700 : Colors.orange.shade700;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end:   Offset.zero,
      ).animate(_slide),
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color:  Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Offline Mode',
                    style: TextStyle(
                      color:      Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize:   13,
                    ),
                  ),
                  Text(
                    widget.cacheAgeLabel.isNotEmpty
                        ? 'Showing cached data · ${widget.cacheAgeLabel}'
                        : 'Showing cached data',
                    style: const TextStyle(
                      color:    Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  if (widget.pendingUploads > 0)
                    Text(
                      '${widget.pendingUploads} record${widget.pendingUploads > 1 ? "s" : ""} pending upload',
                      style: const TextStyle(
                        color:    Colors.white70,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.onRetry != null)
              TextButton.icon(
                onPressed: widget.onRetry,
                icon:  const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding:         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact inline indicator (for cards/list headers).
class OfflineChip extends StatelessWidget {
  final String label;
  const OfflineChip({super.key, this.label = 'Cached'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 10, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize:   10,
              color:      Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
