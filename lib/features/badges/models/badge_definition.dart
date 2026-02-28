import 'package:flutter/material.dart';

enum BadgeCategory { sightings, species, conservation, exploration, social }

class BadgeDefinition {
  final String id;
  final String Function(dynamic t) name;
  final String Function(dynamic t) description;
  final IconData icon;
  final Color color;
  final BadgeCategory category;
  final int target;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.target,
  });
}

class BadgeProgress {
  final BadgeDefinition badge;
  final int current;

  const BadgeProgress({required this.badge, required this.current});

  bool get isUnlocked => current >= badge.target;
  double get progress => (current / badge.target).clamp(0.0, 1.0);
}
