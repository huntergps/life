import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:galapagos_wildlife/app/bootstrap/init_storage.dart';
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

/// Whether premium features are unlocked (Pack OR Pro)
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(hasPackProvider) || ref.watch(hasProProvider);
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
  // On web/desktop, also check Supabase for Stripe purchases
  if (!PurchaseService.isNativeIAP) {
    await ref.read(serverPurchaseProvider.future);
  }
});

/// Check if user has purchases stored in Supabase (for web/Stripe purchases).
/// The `user_purchases` table is populated by a Stripe webhook handler.
final serverPurchaseProvider = FutureProvider<void>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;
  try {
    final data = await Supabase.instance.client
        .from('user_purchases')
        .select('product_id')
        .eq('user_id', user.id);
    final products =
        (data as List).map((r) => r['product_id'] as String).toSet();
    if (products.contains(kPackProductId) ||
        products.contains(kProProductId)) {
      InitStorage.prefs.setBool('has_pack', true);
      ref.read(hasPackProvider.notifier).refresh();
    }
    if (products.contains(kProProductId)) {
      InitStorage.prefs.setBool('has_pro', true);
      ref.read(hasProProvider.notifier).refresh();
    }
  } catch (e) {
    // Table may not exist yet — ignore
    debugPrint('serverPurchaseProvider: $e');
  }
});
