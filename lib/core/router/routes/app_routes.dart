import 'package:go_router/go_router.dart';
import '../../../features/home/presentation/screens/home_screen.dart';
import '../../../features/species/presentation/screens/species_list_screen.dart';
import '../../../features/species/presentation/screens/species_detail_screen.dart';
import '../../../features/species/presentation/screens/species_compare_screen.dart';
import '../../../features/map/presentation/screens/map_screen.dart';
import '../../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../../features/sightings/presentation/screens/sightings_list_screen.dart';
import '../../../features/sightings/presentation/screens/add_sighting_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../features/badges/presentation/screens/badges_screen.dart';
import '../../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../../features/profile/presentation/screens/profile_screen.dart';
import '../router_keys.dart';

List<RouteBase> appRoutes() => [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/species',
        name: 'species',
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['category'];
          return SpeciesListScreen(
            categoryId: categoryId != null ? int.tryParse(categoryId) : null,
          );
        },
        routes: [
          GoRoute(
            path: 'compare',
            name: 'species-compare',
            builder: (context, state) {
              final speciesId = state.uri.queryParameters['speciesId'];
              return SpeciesCompareScreen(
                speciesIdA: speciesId != null ? int.tryParse(speciesId) : null,
              );
            },
          ),
          GoRoute(
            path: ':id',
            name: 'species-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return SpeciesDetailScreen(speciesId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/sightings',
        name: 'sightings',
        builder: (context, state) => const SightingsListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-sighting',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const AddSightingScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/badges',
        name: 'badges',
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ];
