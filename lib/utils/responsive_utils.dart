import 'package:flutter/material.dart';

/// Responsive breakpoints (in logical pixels)
/// Based on Material Design 3 adaptive layout guidelines:
/// - Phone:  < 600px
/// - Tablet: >= 600px (small tablet / foldable)
/// - Large:  >= 840px (large tablet / desktop)
class Breakpoints {
  static const double phone = 600.0;
  static const double tablet = 840.0;
}

/// Central utility class for responsive layout decisions.
///
/// Usage:
///   final r = ResponsiveUtils.of(context);
///   if (r.isTablet) { ... }
///   double p = r.hp(0.5);  // 50% of screen height
class ResponsiveUtils {
  final Size _size;
  final double _width;
  final double _height;

  ResponsiveUtils._(BuildContext context)
      : _size = MediaQuery.of(context).size,
        _width = MediaQuery.of(context).size.width,
        _height = MediaQuery.of(context).size.height;

  /// Creates a [ResponsiveUtils] from the given [BuildContext].
  factory ResponsiveUtils.of(BuildContext context) =>
      ResponsiveUtils._(context);

  // ──────────────────────────────────────────────────────────────
  // Device Classification
  // ──────────────────────────────────────────────────────────────

  /// True when screen width < 600dp (phone)
  bool get isPhone => _width < Breakpoints.phone;

  /// True when screen width >= 600dp (tablet or larger)
  bool get isTablet => _width >= Breakpoints.phone;

  /// True when screen width >= 840dp (large tablet / desktop)
  bool get isLargeTablet => _width >= Breakpoints.tablet;

  /// True when device is in landscape orientation
  bool get isLandscape => _width > _height;

  // ──────────────────────────────────────────────────────────────
  // Screen Dimensions
  // ──────────────────────────────────────────────────────────────

  /// Screen width in logical pixels
  double get screenWidth => _width;

  /// Screen height in logical pixels
  double get screenHeight => _height;

  /// Full screen [Size]
  Size get screenSize => _size;

  // ──────────────────────────────────────────────────────────────
  // Proportional Size Helpers
  // ──────────────────────────────────────────────────────────────

  /// Returns a fraction of the screen **width**.
  /// e.g. `r.wp(0.5)` = 50% of screen width
  double wp(double fraction) => _width * fraction;

  /// Returns a fraction of the screen **height**.
  /// e.g. `r.hp(0.3)` = 30% of screen height
  double hp(double fraction) => _height * fraction;

  // ──────────────────────────────────────────────────────────────
  // Adaptive Value Pickers
  // ──────────────────────────────────────────────────────────────

  /// Returns [tabletValue] on tablet, [phoneValue] on phone.
  T adapt<T>({required T phone, required T tablet}) =>
      isTablet ? tablet : phone;

  /// Returns [largeTabletValue] on large tablets, [tabletValue] on small
  /// tablets, and [phoneValue] on phones.
  T adaptAll<T>({
    required T phone,
    required T tablet,
    required T largeTablet,
  }) {
    if (isLargeTablet) return largeTablet;
    if (isTablet) return tablet;
    return phone;
  }

  // ──────────────────────────────────────────────────────────────
  // Common Adaptive Values (ready-to-use)
  // ──────────────────────────────────────────────────────────────

  /// Horizontal page padding (20 phone → 48 tablet → 80 large tablet)
  double get pagePadding => adaptAll(
    phone: 20.0,
    tablet: 48.0,
    largeTablet: 80.0,
  );

  /// Vertical section spacing (16 phone → 24 tablet)
  double get sectionSpacing => adapt(phone: 16.0, tablet: 24.0);

  /// Card border radius (16 phone → 24 tablet)
  double get cardRadius => adapt(phone: 16.0, tablet: 24.0);

  /// Icon size — regular context (20 phone → 26 tablet)
  double get iconSizeMd => adapt(phone: 20.0, tablet: 26.0);

  /// Icon size — large/hero context (28 phone → 36 tablet)
  double get iconSizeLg => adapt(phone: 28.0, tablet: 36.0);

  // ──────────────────────────────────────────────────────────────
  // Adaptive Font Sizes
  // ──────────────────────────────────────────────────────────────

  /// Extra-small label (10 phone → 12 tablet)
  double get fontXs => adapt(phone: 10.0, tablet: 12.0);

  /// Small body text (12 phone → 14 tablet)
  double get fontSm => adapt(phone: 12.0, tablet: 14.0);

  /// Regular body text (14 phone → 16 tablet)
  double get fontMd => adapt(phone: 14.0, tablet: 16.0);

  /// Sub-heading (16 phone → 18 tablet)
  double get fontLg => adapt(phone: 16.0, tablet: 18.0);

  /// Heading (18 phone → 22 tablet)
  double get fontXl => adapt(phone: 18.0, tablet: 22.0);

  /// Display / hero text (24 phone → 32 tablet)
  double get fontDisplay => adapt(phone: 24.0, tablet: 32.0);

  // ──────────────────────────────────────────────────────────────
  // Grid Column Helper
  // ──────────────────────────────────────────────────────────────

  /// Number of columns for a grid / multi-column layout.
  /// [phoneCols] defaults to 2, [tabletCols] to 3, [largeCols] to 4.
  int gridColumns({int phoneCols = 2, int tabletCols = 3, int largeCols = 4}) =>
      adaptAll(
        phone: phoneCols,
        tablet: tabletCols,
        largeTablet: largeCols,
      );

  // ──────────────────────────────────────────────────────────────
  // Max-Width Constraint Helper
  // ──────────────────────────────────────────────────────────────

  /// Centers and constrains content to a max width.
  /// Default: 560 on phone, 720 on tablet, 960 on large tablet.
  Widget constrained(Widget child, {double? maxWidth}) {
    final double mw = maxWidth ??
        adaptAll(phone: 560.0, tablet: 720.0, largeTablet: 960.0);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: mw),
        child: child,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Build-Context Extension for ergonomic usage
// ──────────────────────────────────────────────────────────────

/// Convenience extension so you can call `context.responsive` anywhere.
///
/// Example:
///   final r = context.responsive;
///   padding: EdgeInsets.symmetric(horizontal: r.pagePadding)
extension ResponsiveContext on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils.of(this);
}

// ──────────────────────────────────────────────────────────────
// ResponsiveBuilder Widget
// ──────────────────────────────────────────────────────────────

/// A widget that rebuilds when layout constraints change (e.g. rotation).
/// Preferred over calling [MediaQuery] directly in build methods when you
/// need both the [ResponsiveUtils] and the raw [BoxConstraints].
///
/// Example:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, r) => Padding(
///     padding: EdgeInsets.symmetric(horizontal: r.pagePadding),
///     child: ...,
///   ),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ResponsiveUtils r) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) => builder(context, ResponsiveUtils.of(context)),
    );
  }
}
