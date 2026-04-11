import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/app/bootstrap/init_storage.dart';
import 'package:galapagos_wildlife/features/admin/providers/admin_auth_provider.dart';
import '../services/purchase_service.dart';

/// Whether the user has the Galapagos Pack (map, photo ID, species-by-site)
final hasPackProvider =
    NotifierProvider<HasPackNotifier, bool>(HasPackNotifier.new);

class HasPackNotifier extends Notifier<bool> {
  @override
  bool build() => InitStorage.prefs.getBool('has_pack') ?? false;

  void refresh() {
    state = InitStorage.prefs.getBool('has_pack') ?? false;
  }
}

/// Whether the user has Pro subscription (includes Pack + satellite, AI, sync)
final hasProProvider =
    NotifierProvider<HasProNotifier, bool>(HasProNotifier.new);

class HasProNotifier extends Notifier<bool> {
  @override
  bool build() => InitStorage.prefs.getBool('has_pro') ?? false;

  void refresh() {
    state = InitStorage.prefs.getBool('has_pro') ?? false;
  }
}

/// Whether premium features are unlocked (Pack OR Pro OR server role)
/// Watches both IAP purchases and server roles reactively.
final isPremiumProvider = Provider<bool>((ref) {
  final hasPack = ref.watch(hasPackProvider);
  final hasPro = ref.watch(hasProProvider);

  // Watch server roles reactively (updates when roles load from server)
  final rolesAsync = ref.watch(userRolesProvider);
  final hasRolePremium = rolesAsync.when(
    data: (roles) =>
        roles.contains('admin') ||
        roles.contains('sponsored') ||
        roles.contains('editor') ||
        roles.contains('curator') ||
        roles.contains('beta_tester'),
    loading: () =>
        (InitStorage.prefs.getBool('has_premium_role') ?? false) ||
        (InitStorage.prefs.getBool('is_beta_tester') ?? false),
    error: (_, __) =>
        (InitStorage.prefs.getBool('has_premium_role') ?? false) ||
        (InitStorage.prefs.getBool('is_beta_tester') ?? false),
  );

  return hasPack || hasPro || hasRolePremium;
});

/// Product details for the paywall UI
final packPriceProvider = Provider<String>((ref) {
  final product = PurchaseService.instance.products[kPackProductId];
  return product?.price ?? '\$9.99';
});

final proPriceProvider = Provider<String>((ref) {
  final product = PurchaseService.instance.products[kProProductId];
  return product?.price ?? '\$29.99/yr';
});

/// Initialize IAP on app start. Watch this in the app shell.
final purchaseInitProvider = FutureProvider<void>((ref) async {
  final service = PurchaseService.instance;
  await service.initialize();
  service.onPurchaseUpdate = () {
    ref.read(hasPackProvider.notifier).refresh();
    ref.read(hasProProvider.notifier).refresh();
  };
});
