import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/bootstrap.dart';
import 'router_keys.dart';
import 'routes/app_routes.dart';
import 'routes/admin_routes.dart';
import 'routes/auth_routes.dart';
import 'routes/search_routes.dart';
import 'navigation/scaffold_with_nav.dart';

export 'navigation/scaffold_with_nav.dart' show ScaffoldWithNav;

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Bootstrap.prefs.getString('last_route') ?? '/',
  redirect: (context, state) {
    final path = state.uri.path;
    // Persist current route for cold-start restoration (skip login)
    if (path != '/login' && path != '/profile') {
      Bootstrap.prefs.setString('last_route', path);
    }
    // Guard admin routes — redirect non-admins to home
    if (path.startsWith('/admin')) {
      final isAdmin = Bootstrap.prefs.getBool('is_admin') ?? false;
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      if (!isLoggedIn || !isAdmin) return '/';
    }
    // Guard deep link paths that require a numeric :id parameter.
    // If the ID is not a valid integer, redirect to home to prevent
    // int.parse exceptions from malformed deep links.
    final speciesMatch = RegExp(r'^/species/(\d+)$|^/species/([^/]+)$').firstMatch(path);
    if (speciesMatch != null) {
      final id = speciesMatch.group(1) ?? speciesMatch.group(2);
      if (id != null && int.tryParse(id) == null) {
        return '/';
      }
    }
    return null;
  },
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        ...appRoutes(),
        ...adminRoutes(),
      ],
    ),
    ...authRoutes(),
    ...searchRoutes(),
  ],
);
