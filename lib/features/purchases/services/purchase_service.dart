import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:galapagos_wildlife/app/bootstrap/init_storage.dart';

/// Product IDs — must match App Store Connect and Google Play Console
const kPackProductId = 'galapagos_pack';
const kProProductId = 'galapagos_pro';
const _kAllProductIds = {kPackProductId, kProProductId};

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._();
  static PurchaseService get instance => _instance;
  PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Cached product details (loaded once)
  final Map<String, ProductDetails> products = {};

  /// Callbacks for purchase state changes
  VoidCallback? onPurchaseUpdate;

  /// Whether the current platform supports native in-app purchases (iOS/Android).
  static bool get isNativeIAP {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  Future<void> initialize() async {
    // Only initialize native IAP on iOS/Android
    if (!isNativeIAP) {
      debugPrint('IAP not available on this platform');
      return;
    }

    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('IAP not available on this platform');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) => debugPrint('IAP stream error: $error'),
    );

    // Load product details
    final response = await _iap.queryProductDetails(_kAllProductIds);
    for (final product in response.productDetails) {
      products[product.id] = product;
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP products not found: ${response.notFoundIDs}');
    }

    // Restore previous purchases
    await _iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _deliverProduct(purchase);
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
        case PurchaseStatus.pending:
          debugPrint('IAP pending: ${purchase.productID}');
        case PurchaseStatus.error:
          debugPrint('IAP error: ${purchase.error}');
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
        case PurchaseStatus.canceled:
          debugPrint('IAP canceled: ${purchase.productID}');
      }
    }
    onPurchaseUpdate?.call();
  }

  void _deliverProduct(PurchaseDetails purchase) {
    final prefs = InitStorage.prefs;
    if (purchase.productID == kPackProductId) {
      prefs.setBool('has_pack', true);
      debugPrint('Pack unlocked!');
    } else if (purchase.productID == kProProductId) {
      prefs.setBool('has_pro', true);
      prefs.setBool('has_pack', true); // Pro includes Pack
      debugPrint('Pro unlocked!');
    }
  }

  /// Buy the Galapagos Pack (non-consumable)
  Future<bool> buyPack() async {
    final product = products[kPackProductId];
    if (product == null) return false;
    return _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product));
  }

  /// Buy Pro subscription (auto-renewable)
  Future<bool> buyPro() async {
    final product = products[kProProductId];
    if (product == null) return false;
    return _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product));
  }

  /// Restore purchases (e.g., after reinstall or new device)
  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
