import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../constants/app_constants.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  /// Uses responsive_framework breakpoints when available,
  /// falls back to MediaQuery for contexts without ResponsiveBreakpoints ancestor
  static bool isPhone(BuildContext context) {
    try {
      return ResponsiveBreakpoints.of(context).isMobile;
    } catch (_) {
      return MediaQuery.sizeOf(context).width < AppConstants.tabletBreakpoint;
    }
  }

  static bool isTablet(BuildContext context) {
    try {
      return ResponsiveBreakpoints.of(context).isTablet;
    } catch (_) {
      final width = MediaQuery.sizeOf(context).width;
      return width >= AppConstants.tabletBreakpoint &&
          width < AppConstants.desktopBreakpoint;
    }
  }

  static bool isDesktop(BuildContext context) {
    try {
      return ResponsiveBreakpoints.of(context).isDesktop;
    } catch (_) {
      return MediaQuery.sizeOf(context).width >=
          AppConstants.desktopBreakpoint;
    }
  }

  static bool isLargerThanMobile(BuildContext context) {
    try {
      return ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    } catch (_) {
      return MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;
    }
  }

  static EdgeInsets responsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  static int responsiveColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double responsiveValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}
