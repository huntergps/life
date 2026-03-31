/// Barrel export for the Drift offline-first layer.
///
/// app_database.dart is intentionally NOT re-exported here to avoid
/// name collisions between Drift-generated data classes (Category, Island, etc.)
/// and the domain model classes with the same names in lib/models/.
/// Import app_database.dart directly with a prefix when Drift row types are needed.
library drift;

export 'repository/wildlife_repository.dart';
