import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardEntry {
  final String userId;
  final String email;
  final int totalSightings;
  final int uniqueSpecies;
  final int totalPhotos;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.email,
    required this.totalSightings,
    required this.uniqueSpecies,
    required this.totalPhotos,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank) {
    return LeaderboardEntry(
      userId: json['user_id'] as String,
      email: json['email'] as String? ?? 'Anonymous',
      totalSightings: (json['total_sightings'] as num).toInt(),
      uniqueSpecies: (json['unique_species'] as num).toInt(),
      totalPhotos: (json['total_photos'] as num).toInt(),
      rank: rank,
    );
  }
}

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final response = await Supabase.instance.client.rpc('get_leaderboard');

  final List<dynamic> data = response as List<dynamic>;

  return data.asMap().entries.map((entry) {
    return LeaderboardEntry.fromJson(
      entry.value as Map<String, dynamic>,
      entry.key + 1,
    );
  }).toList();
});
