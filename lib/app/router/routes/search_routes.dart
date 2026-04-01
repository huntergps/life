import 'package:go_router/go_router.dart';
import '../../../features/search/presentation/screens/global_search_screen.dart';
import '../router_keys.dart';

List<RouteBase> searchRoutes() => [
      GoRoute(
        path: '/search',
        name: 'search',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const GlobalSearchScreen(),
      ),
    ];
