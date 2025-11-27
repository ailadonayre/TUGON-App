import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
///
/// Usage:
/// ```dart
/// // Initialize in build method
/// final responsive = Responsive(context);
///
/// // Use responsive sizes
/// fontSize: responsive.sp(16),
/// width: responsive.wp(50), // 50% of screen width
/// height: responsive.hp(20), // 20% of screen height
/// padding: EdgeInsets.all(responsive.spacing(2)),
/// ```
class Responsive {
  final BuildContext context;

  late final MediaQueryData _mediaQuery;
  late final double _screenWidth;
  late final double _screenHeight;
  late final double _blockSizeHorizontal;
  late final double _blockSizeVertical;
  late final double _textScaleFactor;

  Responsive(this.context) {
    _mediaQuery = MediaQuery.of(context);
    _screenWidth = _mediaQuery.size.width;
    _screenHeight = _mediaQuery.size.height;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;
    _textScaleFactor = _mediaQuery.textScaleFactor;
  }

  // Screen dimensions
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;

  // Device type detection
  bool get isMobile => _screenWidth < 600;
  bool get isTablet => _screenWidth >= 600 && _screenWidth < 900;
  bool get isDesktop => _screenWidth >= 900;

  // Orientation
  bool get isPortrait => _mediaQuery.orientation == Orientation.portrait;
  bool get isLandscape => _mediaQuery.orientation == Orientation.landscape;

  /// Width percentage (0-100)
  /// Example: wp(50) returns 50% of screen width
  double wp(double percentage) => _blockSizeHorizontal * percentage;

  /// Height percentage (0-100)
  /// Example: hp(20) returns 20% of screen height
  double hp(double percentage) => _blockSizeVertical * percentage;

  /// Responsive spacing based on screen size
  /// Multiplier: mobile=1x, tablet=1.2x, desktop=1.5x
  double spacing(double size) {
    if (isDesktop) return size * 1.5;
    if (isTablet) return size * 1.2;
    return size;
  }

  /// Responsive font size that scales with screen width
  /// Base reference: 375px width (iPhone X)
  double sp(double fontSize) {
    final scaledSize = fontSize * (_screenWidth / 375);
    // Clamp to prevent extreme sizes
    return scaledSize.clamp(fontSize * 0.8, fontSize * 1.3);
  }

  /// Responsive font size with text scale factor
  double fontSize(double size) {
    return sp(size) * _textScaleFactor.clamp(0.8, 1.2);
  }

  /// Responsive icon size
  double iconSize(double size) {
    if (isDesktop) return size * 1.3;
    if (isTablet) return size * 1.15;
    return size;
  }

  /// Responsive border radius
  double radius(double size) {
    if (isDesktop) return size * 1.2;
    if (isTablet) return size * 1.1;
    return size;
  }

  /// Get responsive padding/margin
  EdgeInsets get pagePadding {
    if (isDesktop) return const EdgeInsets.all(32);
    if (isTablet) return const EdgeInsets.all(24);
    return const EdgeInsets.all(16);
  }

  EdgeInsets get cardPadding {
    if (isDesktop) return const EdgeInsets.all(24);
    if (isTablet) return const EdgeInsets.all(20);
    return const EdgeInsets.all(16);
  }

  /// Maximum content width for desktop/tablet
  double get maxContentWidth {
    if (isDesktop) return 1200;
    if (isTablet) return 800;
    return _screenWidth;
  }

  /// Responsive grid columns
  int get gridColumns {
    if (isDesktop) return 4;
    if (isTablet) return 2;
    return 1;
  }

  /// Safe area insets
  EdgeInsets get safeAreaPadding => _mediaQuery.padding;

  /// Keyboard visibility
  bool get isKeyboardVisible => _mediaQuery.viewInsets.bottom > 0;

  /// Get value based on screen size
  T valueBasedOnSize<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

/// Extension on BuildContext for easier access
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Responsive responsive) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, Responsive(context));
  }
}

/// Responsive layout widget for different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    if (responsive.isDesktop && desktop != null) {
      return desktop!;
    }

    if (responsive.isTablet && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}

/// Responsive container that centers content on larger screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      color: color,
      child: Center(
        child: Container(
          width: responsive.maxContentWidth,
          padding: padding ?? responsive.pagePadding,
          child: child,
        ),
      ),
    );
  }
}
