import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) phoneBuilder;
  final Widget Function(BuildContext context)? tabletBuilder;

  const AdaptiveLayout({
    super.key,
    required this.phoneBuilder,
    this.tabletBuilder,
  });

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppConstants.desktopBreakpoint;
  }

  /// Returns 1 for phone, 2 for tablet, 3 for desktop.
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppConstants.desktopBreakpoint) return 3;
    if (width >= AppConstants.tabletBreakpoint) return 2;
    return 1;
  }

  /// Returns responsive horizontal padding: 16 phone, 24 tablet, 32 desktop.
  static double responsivePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppConstants.desktopBreakpoint) return 32.0;
    if (width >= AppConstants.tabletBreakpoint) return 24.0;
    return 16.0;
  }

  /// Max content width to prevent over-stretching on wide screens.
  static const double maxContentWidth = 1400.0;

  /// Wraps [child] in Center > ConstrainedBox to limit max width on desktop.
  /// Use [maxWidth] to override the default (e.g. 900 for narrow lists/forms).
  static Widget constrainedContent({required Widget child, double maxWidth = maxContentWidth}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isTablet(context) && tabletBuilder != null) {
      return tabletBuilder!(context);
    }
    return phoneBuilder(context);
  }
}
