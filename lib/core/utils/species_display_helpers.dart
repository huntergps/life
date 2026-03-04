import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ── Shared card widgets ───────────────────────────────────────────────────────

/// Bottom-to-top black gradient used on species card images for text legibility.
const kCardGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: [0.35, 1.0],
  colors: [Colors.transparent, Colors.black87],
);

/// "IA" badge shown on species cards that support AI recognition.
Widget aiBadge() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Color.fromRGBO(0, 137, 123, 0.9), // teal.shade600
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 9, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'IA',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

/// Central place for display helpers (icons, colors, labels) derived from
/// species enum-like string fields.  Prevents copy-paste across widgets.

// ── Diet ──────────────────────────────────────────────────────────────────────

IconData dietIcon(String diet) => switch (diet) {
      'herbivore'   => Icons.eco_outlined,
      'carnivore'   => Icons.set_meal_outlined,
      'omnivore'    => Icons.restaurant_outlined,
      'piscivore'   => Icons.phishing_outlined,
      'insectivore' => Icons.bug_report_outlined,
      'nectarivore' => Icons.local_florist_outlined,
      'frugivore'   => Icons.apple_outlined,
      _             => Icons.restaurant_outlined,
    };

String dietLabel(String diet, {bool spanish = true}) => switch (diet) {
      'herbivore'   => spanish ? 'Herbívoro'   : 'Herbivore',
      'carnivore'   => spanish ? 'Carnívoro'   : 'Carnivore',
      'omnivore'    => spanish ? 'Omnívoro'    : 'Omnivore',
      'piscivore'   => spanish ? 'Piscívoro'   : 'Piscivore',
      'insectivore' => spanish ? 'Insectívoro' : 'Insectivore',
      'nectarivore' => spanish ? 'Nectarívoro' : 'Nectarivore',
      'frugivore'   => spanish ? 'Frugívoro'   : 'Frugivore',
      _             => spanish ? 'Dieta'       : 'Diet',
    };

// ── Activity pattern ──────────────────────────────────────────────────────────

IconData activityIcon(String pattern) => switch (pattern) {
      'diurnal'     => Icons.wb_sunny_outlined,
      'nocturnal'   => Icons.nightlight_outlined,
      'crepuscular' => Icons.wb_twilight_outlined,
      _             => Icons.access_time_outlined,
    };

String activityLabel(String pattern, {bool spanish = true}) => switch (pattern) {
      'diurnal'     => spanish ? 'Diurno'      : 'Diurnal',
      'nocturnal'   => spanish ? 'Nocturno'    : 'Nocturnal',
      'crepuscular' => spanish ? 'Crepuscular' : 'Crepuscular',
      _             => spanish ? 'Activo'      : 'Active',
    };

// ── Population trend ──────────────────────────────────────────────────────────

IconData trendIcon(String trend) => switch (trend) {
      'increasing' => Icons.trending_up,
      'stable'     => Icons.trending_flat,
      'decreasing' => Icons.trending_down,
      _            => Icons.remove,
    };

Color trendColor(String trend) => switch (trend) {
      'increasing' => Colors.green,
      'stable'     => Colors.amber,
      'decreasing' => Colors.red,
      _            => Colors.grey,
    };

String trendLabel(String trend, {bool spanish = true}) => switch (trend) {
      'increasing' => spanish ? 'En Aumento' : 'Increasing',
      'stable'     => spanish ? 'Estable'    : 'Stable',
      'decreasing' => spanish ? 'En Declive' : 'Decreasing',
      _            => spanish ? 'Desconocido': 'Unknown',
    };

// ── Conservation status ───────────────────────────────────────────────────────

Color conservationStatusColor(String status) => switch (status) {
      'EX' => AppColors.statusEX,
      'EW' => AppColors.statusEW,
      'CR' => AppColors.statusCR,
      'EN' => AppColors.statusEN,
      'VU' => AppColors.statusVU,
      'NT' => AppColors.statusNT,
      'LC' => AppColors.statusLC,
      'DD' => AppColors.statusDD,
      _    => AppColors.statusNE,
    };

String conservationStatusLabel(String status, {bool spanish = true}) => switch (status) {
      'CR' => spanish ? 'En Peligro Crítico' : 'Critically Endangered',
      'EN' => spanish ? 'En Peligro'         : 'Endangered',
      'VU' => spanish ? 'Vulnerable'         : 'Vulnerable',
      'NT' => spanish ? 'Casi Amenazado'     : 'Near Threatened',
      'LC' => spanish ? 'Menor Preocupación' : 'Least Concern',
      'DD' => spanish ? 'Datos Insuficientes': 'Data Deficient',
      'EX' => spanish ? 'Extinto'            : 'Extinct',
      'EW' => spanish ? 'Extinto en Silvest.': 'Extinct in the Wild',
      _    => spanish ? 'No Evaluado'        : 'Not Evaluated',
    };
