import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/auth/providers/auth_provider.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_auth_provider.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import 'package:galapagos_wildlife/features/profile/providers/profile_provider.dart';
import 'package:galapagos_wildlife/core/widgets/celebration_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTabletOrDesktop =
        MediaQuery.sizeOf(context).shortestSide >=
        AppConstants.tabletBreakpoint;

    if (isTabletOrDesktop) {
      final isDesktop = width >= AppConstants.desktopBreakpoint;
      return _TabletLayout(extended: isDesktop, child: child);
    }
    return _PhoneLayout(child: child);
  }

  static bool isAdminRoute(BuildContext context) {
    return GoRouterState.of(context).uri.path.startsWith('/admin');
  }

  static int calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/admin')) {
      if (location.startsWith('/admin/species')) return 1;
      if (location.startsWith('/admin/categories')) return 2;
      if (location.startsWith('/admin/islands')) return 3;
      if (location.startsWith('/admin/visit-sites')) return 4;
      if (location.startsWith('/admin/species-sites')) return 5;
      return 0;
    }
    if (location.startsWith('/species')) return 1;
    if (location.startsWith('/map')) return 2;
    if (location.startsWith('/favorites')) return 3;
    if (location.startsWith('/sightings')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0;
  }

  static void onItemTapped(int index, BuildContext context) {
    if (isAdminRoute(context)) {
      switch (index) {
        case 0:
          context.go('/admin');
        case 1:
          context.go('/admin/species');
        case 2:
          context.go('/admin/categories');
        case 3:
          context.go('/admin/islands');
        case 4:
          context.go('/admin/visit-sites');
        case 5:
          context.go('/admin/species-sites');
        case 6:
          context.go('/');
      }
      return;
    }
    switch (index) {
      case 0:
        context.goNamed('home');
      case 1:
        context.goNamed('species');
      case 2:
        context.goNamed('map');
      case 3:
        context.goNamed('favorites');
      case 4:
        context.goNamed('sightings');
      case 5:
        context.goNamed('settings');
    }
  }
}

// ── Phone layout ──

class _PhoneLayout extends StatelessWidget {
  final Widget child;
  const _PhoneLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    final isAdmin = ScaffoldWithNav.isAdminRoute(context);
    final tr = context.t;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: ScaffoldWithNav.calculateSelectedIndex(context),
        onDestinationSelected: (index) =>
            ScaffoldWithNav.onItemTapped(index, context),
        destinations: isAdmin
            ? _adminDestinations(tr)
            : _appDestinations(tr),
      ),
    );
  }

  static List<NavigationDestination> _appDestinations(Translations tr) => [
    NavigationDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home),
      label: tr.nav.home,
    ),
    NavigationDestination(
      icon: const Icon(Icons.pets_outlined),
      selectedIcon: const Icon(Icons.pets),
      label: tr.nav.species,
    ),
    NavigationDestination(
      icon: const Icon(Icons.map_outlined),
      selectedIcon: const Icon(Icons.map),
      label: tr.nav.map,
    ),
    NavigationDestination(
      icon: const Icon(Icons.favorite_outline),
      selectedIcon: const Icon(Icons.favorite),
      label: tr.nav.favorites,
    ),
    NavigationDestination(
      icon: const Icon(Icons.camera_alt_outlined),
      selectedIcon: const Icon(Icons.camera_alt),
      label: tr.nav.sightings,
    ),
    NavigationDestination(
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings),
      label: tr.settings.title,
    ),
  ];

  static List<NavigationDestination> _adminDestinations(Translations tr) => [
    NavigationDestination(
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: const Icon(Icons.dashboard),
      label: tr.admin.dashboard,
    ),
    NavigationDestination(
      icon: const Icon(Icons.pets_outlined),
      selectedIcon: const Icon(Icons.pets),
      label: tr.admin.species,
    ),
    NavigationDestination(
      icon: const Icon(Icons.category_outlined),
      selectedIcon: const Icon(Icons.category),
      label: tr.admin.categories,
    ),
    NavigationDestination(
      icon: const Icon(Icons.landscape_outlined),
      selectedIcon: const Icon(Icons.landscape),
      label: tr.admin.islands,
    ),
    NavigationDestination(
      icon: const Icon(Icons.place_outlined),
      selectedIcon: const Icon(Icons.place),
      label: tr.admin.sites,
    ),
    NavigationDestination(
      icon: const Icon(Icons.link),
      selectedIcon: const Icon(Icons.link),
      label: tr.admin.speciesSites,
    ),
    NavigationDestination(
      icon: const Icon(Icons.exit_to_app),
      selectedIcon: const Icon(Icons.exit_to_app),
      label: tr.admin.exitAdmin,
    ),
  ];
}

// ── Tablet / Desktop layout ──

class _TabletLayout extends ConsumerStatefulWidget {
  final Widget child;
  final bool extended;
  const _TabletLayout({required this.child, this.extended = false});

  @override
  ConsumerState<_TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends ConsumerState<_TabletLayout> {
  @override
  Widget build(BuildContext context) {
    final collapsed = ref.watch(navCollapsedProvider);
    final selectedIndex = ScaffoldWithNav.calculateSelectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.t;
    // Extended = show labels next to icons (only on desktop when not collapsed)
    final showExtended = widget.extended && !collapsed;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.digit1, meta: true): () =>
            ScaffoldWithNav.onItemTapped(0, context),
        const SingleActivator(LogicalKeyboardKey.digit2, meta: true): () =>
            ScaffoldWithNav.onItemTapped(1, context),
        const SingleActivator(LogicalKeyboardKey.digit3, meta: true): () =>
            ScaffoldWithNav.onItemTapped(2, context),
        const SingleActivator(LogicalKeyboardKey.digit4, meta: true): () =>
            ScaffoldWithNav.onItemTapped(3, context),
        const SingleActivator(LogicalKeyboardKey.digit5, meta: true): () =>
            ScaffoldWithNav.onItemTapped(4, context),
        const SingleActivator(LogicalKeyboardKey.digit6, meta: true): () =>
            ScaffoldWithNav.onItemTapped(5, context),
        const SingleActivator(LogicalKeyboardKey.bracketLeft, meta: true): () =>
            ref.read(navCollapsedProvider.notifier).toggle(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              _TopHeaderBar(collapsed: collapsed),
              Expanded(
                child: Row(
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: NavigationRail(
                        selectedIndex: selectedIndex,
                        extended: showExtended,
                        onDestinationSelected: (index) =>
                            ScaffoldWithNav.onItemTapped(index, context),
                        labelType: showExtended
                            ? NavigationRailLabelType.none
                            : collapsed
                                ? NavigationRailLabelType.none
                                : NavigationRailLabelType.all,
                        backgroundColor: isDark ? AppColors.darkSurface : null,
                        destinations: ScaffoldWithNav.isAdminRoute(context)
                            ? _adminRailDestinations(tr)
                            : _appRailDestinations(tr),
                        trailing: _RailTrailingActions(
                          collapsed: collapsed,
                          showExtended: showExtended,
                        ),
                      ),
                    ),
                    isDark
                        ? const VerticalDivider(
                            width: 0.5,
                            thickness: 0.5,
                            color: AppColors.darkBorder,
                          )
                        : const VerticalDivider(width: 1, thickness: 1),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<NavigationRailDestination> _appRailDestinations(Translations tr) => [
    NavigationRailDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home),
      label: Text(tr.nav.home),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.pets_outlined),
      selectedIcon: const Icon(Icons.pets),
      label: Text(tr.nav.species),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.map_outlined),
      selectedIcon: const Icon(Icons.map),
      label: Text(tr.nav.map),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.favorite_outline),
      selectedIcon: const Icon(Icons.favorite),
      label: Text(tr.nav.favorites),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.camera_alt_outlined),
      selectedIcon: const Icon(Icons.camera_alt),
      label: Text(tr.nav.sightings),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings),
      label: Text(tr.settings.title),
    ),
  ];

  static List<NavigationRailDestination> _adminRailDestinations(Translations tr) => [
    NavigationRailDestination(
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: const Icon(Icons.dashboard),
      label: Text(tr.admin.dashboard),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.pets_outlined),
      selectedIcon: const Icon(Icons.pets),
      label: Text(tr.admin.species),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.category_outlined),
      selectedIcon: const Icon(Icons.category),
      label: Text(tr.admin.categories),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.landscape_outlined),
      selectedIcon: const Icon(Icons.landscape),
      label: Text(tr.admin.islands),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.place_outlined),
      selectedIcon: const Icon(Icons.place),
      label: Text(tr.admin.sites),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.link),
      selectedIcon: const Icon(Icons.link),
      label: Text(tr.admin.speciesSites),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.exit_to_app),
      selectedIcon: const Icon(Icons.exit_to_app),
      label: Text(tr.admin.exitAdmin),
    ),
  ];
}

// ── Trailing actions for NavigationRail (Admin + Sign Out) ──

class _RailTrailingActions extends ConsumerWidget {
  final bool collapsed;
  final bool showExtended;

  const _RailTrailingActions({
    required this.collapsed,
    required this.showExtended,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isAdminAsync = isAuthenticated ? ref.watch(isAdminProvider) : null;
    final isAdmin = isAdminAsync?.asData?.value ?? false;
    final tr = context.t;
    final isOnAdminRoute = ScaffoldWithNav.isAdminRoute(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 8),
        // Admin panel button (only for admins, not shown when already on admin routes)
        if (isAdmin && !isOnAdminRoute)
          _RailActionButton(
            icon: Icons.admin_panel_settings,
            label: tr.admin.panel,
            showExtended: showExtended,
            collapsed: collapsed,
            onTap: () => context.go('/admin'),
          ),
        // Sign out button
        if (isAuthenticated)
          _RailActionButton(
            icon: Icons.logout,
            label: tr.auth.signOut,
            showExtended: showExtended,
            collapsed: collapsed,
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              ref.invalidate(isAdminProvider);
            },
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _RailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showExtended;
  final bool collapsed;
  final VoidCallback onTap;

  const _RailActionButton({
    required this.icon,
    required this.label,
    required this.showExtended,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurface;
    final textColor = theme.colorScheme.onSurface;

    if (showExtended) {
      // Extended mode (desktop): icon + label in a row
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: iconColor),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!collapsed) {
      // Tablet with labels visible: icon + label below (like NavigationRail destinations)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: SizedBox(
              width: 72,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 24, color: iconColor),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Collapsed: icon only
    return Tooltip(
      message: label,
      child: IconButton(
        icon: Icon(icon, size: 24, color: iconColor),
        onPressed: onTap,
      ),
    );
  }
}

// ── Top header bar for tablet/desktop ──

class _TopHeaderBar extends ConsumerWidget {
  final bool collapsed;
  const _TopHeaderBar({required this.collapsed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final tr = context.t;
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Container(
      height: 48 + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : Theme.of(context).dividerColor,
            width: isDark ? 0.5 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Hamburger toggle
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(collapsed ? Icons.menu : Icons.menu_open, size: 20),
              tooltip: collapsed ? tr.admin.showMenu : tr.admin.hideMenu,
              onPressed: () => ref.read(navCollapsedProvider.notifier).toggle(),
            ),
          ),

          // App logo + title (with celebration overlay)
          CelebrationOverlay(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/gwl_logo.png',
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppConstants.appName,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          // Search
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            tooltip: tr.search.title,
            onPressed: () => context.pushNamed('search'),
          ),

          // Language toggle
          IconButton(
            icon: Text(
              locale == 'es' ? 'ES' : 'EN',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            tooltip: tr.settings.language,
            onPressed: () {
              final next = locale == 'en' ? 'es' : 'en';
              ref.read(localeProvider.notifier).setLocale(next);
            },
          ),

          // Theme toggle (light → dark → system)
          IconButton(
            icon: Icon(
              switch (themeMode) {
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
                ThemeMode.system => Icons.brightness_auto,
              },
              size: 20,
            ),
            tooltip: switch (themeMode) {
              ThemeMode.light => tr.settings.light,
              ThemeMode.dark => tr.settings.dark,
              ThemeMode.system => tr.settings.system,
            },
            onPressed: () {
              final next = switch (themeMode) {
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
                ThemeMode.system => ThemeMode.light,
              };
              ref.read(themeModeProvider.notifier).setThemeMode(next);
            },
          ),

          // Profile
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ProfileButton(),
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);

    if (!isAuthenticated) {
      return IconButton(
        icon: const Icon(Icons.person_outline, size: 20),
        tooltip: context.t.auth.signIn,
        onPressed: () => context.push('/login'),
      );
    }

    final email = user?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final profileAsync = ref.watch(userProfileProvider);
    final avatarUrl = profileAsync.asData?.value?.avatarUrl;

    return GestureDetector(
      onTap: () => context.goNamed('profile'),
      child: Tooltip(
        message: email,
        child: CircleAvatar(
          radius: 14,
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Text(initial, style: const TextStyle(fontSize: 11))
              : null,
        ),
      ),
    );
  }
}
