import 'package:go_router/go_router.dart';
import '../../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../features/admin/presentation/screens/species/admin_species_list_screen.dart';
import '../../../features/admin/presentation/screens/species/admin_species_form_screen.dart';
import '../../../features/admin/presentation/screens/species/admin_species_images_screen.dart';
import '../../../features/admin/presentation/screens/species/admin_species_sites_screen.dart';
import '../../../features/admin/presentation/screens/categories/admin_category_list_screen.dart';
import '../../../features/admin/presentation/screens/categories/admin_category_form_screen.dart';
import '../../../features/admin/presentation/screens/islands/admin_island_list_screen.dart';
import '../../../features/admin/presentation/screens/islands/admin_island_form_screen.dart';
import '../../../features/admin/presentation/screens/visit_sites/admin_visit_site_list_screen.dart';
import '../../../features/admin/presentation/screens/visit_sites/admin_visit_site_form_screen.dart';
import '../../../features/admin/presentation/screens/taxonomy/admin_taxonomy_screen.dart';
import '../../../features/admin/presentation/screens/site_catalogs/admin_site_catalogs_screen.dart';

List<RouteBase> adminRoutes() => [
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'species',
            name: 'admin-species',
            builder: (context, state) => const AdminSpeciesListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'admin-species-new',
                builder: (context, state) => const AdminSpeciesFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'admin-species-edit',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return AdminSpeciesFormScreen(speciesId: id);
                },
              ),
              GoRoute(
                path: ':id/images',
                name: 'admin-species-images',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return AdminSpeciesImagesScreen(speciesId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'categories',
            name: 'admin-categories',
            builder: (context, state) => const AdminCategoryListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'admin-category-new',
                builder: (context, state) => const AdminCategoryFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'admin-category-edit',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return AdminCategoryFormScreen(categoryId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'islands',
            name: 'admin-islands',
            builder: (context, state) => const AdminIslandListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'admin-island-new',
                builder: (context, state) => const AdminIslandFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'admin-island-edit',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return AdminIslandFormScreen(islandId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'visit-sites',
            name: 'admin-visit-sites',
            builder: (context, state) => const AdminVisitSiteListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'admin-visit-site-new',
                builder: (context, state) => const AdminVisitSiteFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'admin-visit-site-edit',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return AdminVisitSiteFormScreen(siteId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'species-sites',
            name: 'admin-species-sites',
            builder: (context, state) => const AdminSpeciesSitesScreen(),
          ),
          GoRoute(
            path: 'taxonomy',
            name: 'admin-taxonomy',
            builder: (context, state) => const AdminTaxonomyScreen(),
          ),
          GoRoute(
            path: 'site-catalogs',
            name: 'admin-site-catalogs',
            builder: (context, state) => const AdminSiteCatalogsScreen(),
          ),
        ],
      ),
    ];
