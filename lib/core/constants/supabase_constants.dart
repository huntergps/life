class SupabaseConstants {
  SupabaseConstants._();

  // Cloud project (galapagos-wildlife)
  static const String cloudUrl = 'https://vojbznerffkemxqlwapf.supabase.co';
  static const String cloudAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvamJ6bmVyZmZrZW14cWx3YXBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE3NjU5NDksImV4cCI6MjA4NzM0MTk0OX0.MnF-Esq5vR1_p20ow6Bm2Bs6Pi7m6phC3sn20s46Oh0';

  // Override via env for different environments
  static String get url => const String.fromEnvironment('SUPABASE_URL', defaultValue: cloudUrl);
  static String get anonKey => const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: cloudAnonKey);

  // Storage buckets
  static const String speciesImagesBucket = 'species-images';
  static const String sightingPhotosBucket = 'sighting-photos';
}
