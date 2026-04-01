import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import '../providers/purchase_provider.dart';
import '../services/purchase_service.dart';

/// Shows the paywall as a bottom sheet
Future<void> showPaywall(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const PaywallSheet(),
  );
}

class PaywallSheet extends ConsumerWidget {
  const PaywallSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPack = ref.watch(hasPackProvider);
    final hasPro = ref.watch(hasProProvider);
    final packPrice = ref.watch(packPriceProvider);
    final proPrice = ref.watch(proPriceProvider);
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            isEs ? 'Desbloquea Galapagos' : 'Unlock Galapagos',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isEs
                ? 'Accede a todas las herramientas de exploracion'
                : 'Access all exploration tools',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Pack tile
          _PurchaseTile(
            title: isEs ? 'Pack Galapagos' : 'Galapagos Pack',
            price: packPrice,
            subtitle: isEs ? 'Pago unico' : 'One-time purchase',
            features: isEs
                ? [
                    'Mapa interactivo (891 sitios)',
                    'Photo ID con IA',
                    'Que ver en cada sitio',
                    'Export de avistamientos',
                  ]
                : [
                    'Interactive map (891 sites)',
                    'AI Photo ID',
                    'Species by site',
                    'Sighting export',
                  ],
            isPurchased: hasPack,
            onBuy: hasPack
                ? null
                : () async {
                    await PurchaseService.instance.buyPack();
                  },
            color: AppColors.primary,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Pro tile
          _PurchaseTile(
            title: 'Pro',
            price: proPrice,
            subtitle: isEs ? 'Suscripcion anual' : 'Annual subscription',
            features: isEs
                ? [
                    'Todo del Pack +',
                    'Mapas satellite offline',
                    'IA mejorada',
                    'Sync prioritario',
                  ]
                : [
                    'Everything in Pack +',
                    'Offline satellite maps',
                    'Enhanced AI',
                    'Priority sync',
                  ],
            isPurchased: hasPro,
            onBuy: hasPro
                ? null
                : () async {
                    await PurchaseService.instance.buyPro();
                  },
            color: Colors.amber.shade700,
            isDark: isDark,
            highlighted: true,
          ),
          const SizedBox(height: 16),

          // Restore purchases
          TextButton(
            onPressed: () async {
              await PurchaseService.instance.restore();
              ref.read(hasPackProvider.notifier).refresh();
              ref.read(hasProProvider.notifier).refresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(isEs
                          ? 'Compras restauradas'
                          : 'Purchases restored')),
                );
              }
            },
            child: Text(isEs ? 'Restaurar compras' : 'Restore purchases'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final List<String> features;
  final bool isPurchased;
  final VoidCallback? onBuy;
  final Color color;
  final bool isDark;
  final bool highlighted;

  const _PurchaseTile({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.features,
    required this.isPurchased,
    required this.onBuy,
    required this.color,
    required this.isDark,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? color
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          width: highlighted ? 2 : 1,
        ),
        color: isDark ? Colors.grey.shade900 : Colors.white,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
              Text(price,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: color),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(f,
                            style: Theme.of(context).textTheme.bodySmall)),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: isPurchased
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check),
                    label: Text(isEs ? 'Comprado' : 'Purchased'),
                  )
                : FilledButton(
                    onPressed: onBuy,
                    style: FilledButton.styleFrom(backgroundColor: color),
                    child: Text(
                      isEs ? 'Comprar' : 'Buy',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
