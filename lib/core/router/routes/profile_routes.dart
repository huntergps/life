import 'package:go_router/go_router.dart';
import '../../../features/profile/presentation/screens/profile_screen.dart';
import '../router_keys.dart';

List<RouteBase> profileRoutes() => [
      GoRoute(
        path: '/profile',
        name: 'profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
    ];
