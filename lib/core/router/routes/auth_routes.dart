import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import '../router_keys.dart';

List<RouteBase> authRoutes() => [
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
    ];
