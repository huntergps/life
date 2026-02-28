/// Seeds official Parque Nacional Galápagos data into Supabase.
///
/// Sources:
///   - geo_isla_202602231216.csv           → islands (park_id + new fields)
///   - sitios.csv                          → visit_sites PRIMARY source (891 rows)
///   - _SELECT_master_geo_sitio_...csv     → enrichment for tourist sites (222 rows)
///   - geo_sitio_tipo.csv                  → site_type_catalog + visit_site_types
///   - geo_sitio_modalidad.csv             → site_modality_catalog + visit_site_modalities
///   - geo_sitio_actividad.csv             → site_activity_catalog + visit_site_activities
///
/// Status values (visit_sites.status):
///   'active'     → in master CSV with estado='A'  (visible tourist sites)
///   'inactive'   → in master CSV with estado='I'  (temporarily closed)
///   'monitoring' → only in sitios.csv             (research/monitoring sites)
///
/// Usage:
///   dart run bin/seed_official_park_data.dart
library;

import 'dart:io';
import 'package:supabase/supabase.dart';

// ── Supabase credentials ───────────────────────────────────────────────────
const _supabaseUrl = 'https://vojbznerffkemxqlwapf.supabase.co';
const _serviceRoleKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvamJ6bmVyZmZrZW14cWx3YXBmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTc2NTk0OSwiZXhwIjoyMDg3MzQxOTQ5fQ.Edz8JhsevSfJ3rj-U8q2lg6mYOjnXrbh68O_4XpB72s';

// ── CSV file paths (relative to project root) ─────────────────────────────
const _csvIslands =
    'geo_isla_202602231216.csv';
const _csvSitios =
    'sitios.csv';
const _csvTipos =
    'geo_sitio_tipo.csv';
const _csvModalidades =
    'geo_sitio_modalidad.csv';
const _csvActividades =
    'geo_sitio_actividad.csv';
const _csvMaster =
    '_SELECT_master_geo_sitio_id_master_geo_sitio_descripcion_master__202602231224.csv';

// ── Helpers ────────────────────────────────────────────────────────────────

/// Parses a CSV string into a list of maps, handling quoted fields.
/// Keys are the header names (trimmed of surrounding quotes and whitespace).
List<Map<String, String>> parseCsv(String content) {
  final lines = content.split('\n');
  if (lines.isEmpty) return [];

  final headers = _parseCsvRow(lines.first)
      .map((h) => h.trim())
      .toList();

  final result = <Map<String, String>>[];
  for (var i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    final values = _parseCsvRow(line);
    final row = <String, String>{};
    for (var j = 0; j < headers.length; j++) {
      row[headers[j]] = j < values.length ? values[j] : '';
    }
    result.add(row);
  }
  return result;
}

/// Splits a single CSV row into fields, respecting double-quoted fields
/// (which may contain commas).  Surrounding quotes are stripped.
List<String> _parseCsvRow(String line) {
  final fields = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        // Escaped double-quote inside a quoted field
        buffer.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (ch == ',' && !inQuotes) {
      fields.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(ch);
    }
  }
  fields.add(buffer.toString());
  return fields;
}

/// Returns null if [value] is null or blank, otherwise the trimmed value.
String? orNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Parses a double, returning null on failure.
double? parseDouble(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return double.tryParse(value.trim());
}

/// Parses an int, returning null on failure.
int? parseInt(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return int.tryParse(value.trim());
}

/// Normalizes a name for comparison: uppercase and trimmed.
String normalizeName(String name) => name.trim().toUpperCase();

// ── Entry point ────────────────────────────────────────────────────────────

Future<void> main() async {
  final client = SupabaseClient(_supabaseUrl, _serviceRoleKey);

  try {
    // ── STEP 1: Update / insert islands ─────────────────────────────────
    print('\n[STEP 1] Updating islands with official park data...');
    await _step1Islands(client);

    // ── STEP 2: Seed catalog tables ──────────────────────────────────────
    print('\n[STEP 2] Seeding catalog tables...');
    await _step2Catalogs(client);

    // ── STEP 3: Clear existing visit_sites data ──────────────────────────
    print('\n[STEP 3] Clearing existing visit_sites data...');
    await _step3ClearVisitSites(client);

    // ── STEP 4: Import ALL 891 visit_sites from sitios.csv ──────────────
    print('\n[STEP 4] Importing ALL visit_sites from sitios.csv...');
    await _step4ImportVisitSites(client);

    // ── STEP 5: Build park_id → db id lookup ─────────────────────────────
    print('\n[STEP 5] Building park_id → integer id lookup...');
    final parkIdToDbId = await _step5BuildParkIdMap(client);
    print('  ✓ Loaded ${parkIdToDbId.length} visit_site id mappings');

    // ── STEP 6: Seed junction tables ─────────────────────────────────────
    print('\n[STEP 6] Seeding junction tables...');
    await _step6JunctionTables(client, parkIdToDbId);

    print('\n✓ Seed complete.\n');
  } catch (e, st) {
    print('\n✗ Fatal error: $e');
    print(st);
    exitCode = 1;
  } finally {
    client.dispose();
  }
}

// ── Step implementations ───────────────────────────────────────────────────

Future<void> _step1Islands(SupabaseClient client) async {
  final content = await File(_csvIslands).readAsString();
  final rows = parseCsv(content);

  // Load existing islands from DB
  final existing = await client.from('islands').select('id, name_es');
  final dbIslands = <String, int>{};
  for (final row in existing) {
    final name = normalizeName(row['name_es'] as String? ?? '');
    dbIslands[name] = row['id'] as int;
  }

  var updated = 0;
  var inserted = 0;

  for (final row in rows) {
    final parkId    = orNull(row['id']);
    final nameEs    = orNull(row['descripcion']);
    final tipoIsla  = orNull(row['tipo_isla']);
    final clasif    = orNull(row['clasificacion']);
    final superfKm  = orNull(row['superficie_km']);
    final superfHa  = orNull(row['superficie_ha']);
    final lat       = orNull(row['latitud']);
    final lng       = orNull(row['longitud']);
    final esPoblada = row['es_poblada']?.trim() == 'true';
    final estado    = orNull(row['estado']);

    if (parkId == null || nameEs == null) continue;
    // Skip eliminated records
    if (orNull(row['eliminado']) == 'true') continue;
    // Skip inactive islands
    if (estado == 'I') continue;

    final normalizedName = normalizeName(nameEs);
    final existingId = dbIslands[normalizedName];

    final data = <String, dynamic>{
      'park_id'       : parkId,
      'island_type'   : tipoIsla,
      'classification': clasif,
      'area_ha'       : parseDouble(superfHa),
      'is_populated'  : esPoblada,
    };

    // Also update lat/lng only when the CSV has them (islands CSV has decimal coords)
    final latVal = parseDouble(lat);
    final lngVal = parseDouble(lng);
    if (latVal != null) data['latitude']  = latVal;
    if (lngVal != null) data['longitude'] = lngVal;

    if (superfKm != null) {
      final kmVal = parseDouble(superfKm);
      if (kmVal != null) data['area_km2'] = kmVal;
    }

    if (existingId != null) {
      await client.from('islands').update(data).eq('id', existingId);
      updated++;
    } else {
      // Insert new island — name_en defaults to the Spanish name for now
      await client.from('islands').insert({
        ...data,
        'name_es': nameEs,
        'name_en': nameEs,
      });
      inserted++;
      print('  + Inserted new island: $nameEs');
    }
  }

  print('  ✓ Islands updated: $updated, inserted: $inserted');
}

Future<void> _step2Catalogs(SupabaseClient client) async {
  // ── site_type_catalog ──────────────────────────────────────────────────
  final tiposContent = await File(_csvTipos).readAsString();
  final tiposRows = parseCsv(tiposContent);

  final uniqueTypes = <String, Map<String, dynamic>>{};
  for (final row in tiposRows) {
    final id   = orNull(row['tipo_id']);
    final name = orNull(row['tipo']);
    if (id != null && name != null) {
      uniqueTypes[id] = {'id': id, 'name': name};
    }
  }

  if (uniqueTypes.isNotEmpty) {
    await client
        .from('site_type_catalog')
        .upsert(uniqueTypes.values.toList(), onConflict: 'id');
    print('  ✓ site_type_catalog: ${uniqueTypes.length} records upserted');
  }

  // ── site_modality_catalog ──────────────────────────────────────────────
  final modalContent = await File(_csvModalidades).readAsString();
  final modalRows = parseCsv(modalContent);

  final uniqueModalities = <String, Map<String, dynamic>>{};
  for (final row in modalRows) {
    final id   = orNull(row['id_mod']);
    final name = orNull(row['nombre']);
    if (id != null && name != null) {
      uniqueModalities[id] = {'id': id, 'name': name};
    }
  }

  if (uniqueModalities.isNotEmpty) {
    await client
        .from('site_modality_catalog')
        .upsert(uniqueModalities.values.toList(), onConflict: 'id');
    print('  ✓ site_modality_catalog: ${uniqueModalities.length} records upserted');
  }

  // ── site_activity_catalog ──────────────────────────────────────────────
  final actContent = await File(_csvActividades).readAsString();
  final actRows = parseCsv(actContent);

  final uniqueActivities = <String, Map<String, dynamic>>{};
  for (final row in actRows) {
    final id           = orNull(row['actividad_id']);
    final name         = orNull(row['actividad_label']);
    final abbreviation = orNull(row['abreviatura_label']);
    if (id != null && name != null) {
      uniqueActivities[id] = {
        'id'          : id,
        'name'        : name,
        'abbreviation': abbreviation,
      };
    }
  }

  if (uniqueActivities.isNotEmpty) {
    await client
        .from('site_activity_catalog')
        .upsert(uniqueActivities.values.toList(), onConflict: 'id');
    print('  ✓ site_activity_catalog: ${uniqueActivities.length} records upserted');
  }
}

Future<void> _step3ClearVisitSites(SupabaseClient client) async {
  // Delete junction rows first (FK constraints), then visit_sites
  await client.from('visit_site_activities').delete().neq('visit_site_id', 0);
  await client.from('visit_site_modalities').delete().neq('visit_site_id', 0);
  await client.from('visit_site_types').delete().neq('visit_site_id', 0);
  await client.from('visit_sites').delete().neq('id', 0);
  print('  ✓ Cleared existing visit_sites data');
}

Future<void> _step4ImportVisitSites(SupabaseClient client) async {
  // ── PRIMARY source: sitios.csv (891 sites — ALL park sites) ──────────────
  final sitiosContent = await File(_csvSitios).readAsString();
  final sitiosRows    = parseCsv(sitiosContent);

  // ── ENRICHMENT: master CSV (222 tourist sites with island, capacity, etc.) ─
  final masterContent = await File(_csvMaster).readAsString();
  final masterRows    = parseCsv(masterContent);

  // Build master lookup by id (same UUID as sitio_id in sitios.csv)
  final masterById = <String, Map<String, String>>{};
  for (final row in masterRows) {
    final id = orNull(row['id']);
    if (id != null) masterById[id] = row;
  }

  // Build island name → db id cache
  final islandRows = await client.from('islands').select('id, name_es');
  final islandIdByName = <String, int>{};
  for (final row in islandRows) {
    final name = normalizeName(row['name_es'] as String? ?? '');
    islandIdByName[name] = row['id'] as int;
  }

  var activeCount     = 0;
  var inactiveCount   = 0;
  var monitoringCount = 0;
  var skippedCount    = 0;

  for (final sitio in sitiosRows) {
    final parkId = orNull(sitio['sitio_id']);
    final nameEs = orNull(sitio['descripcion']);

    if (parkId == null || nameEs == null) {
      skippedCount++;
      continue;
    }

    // Check if this site appears in the master CSV (tourist-accessible site)
    final master        = masterById[parkId];
    final isTouristSite = master != null;

    // Determine status:
    //   'active'     → tourist site, currently open
    //   'inactive'   → tourist site, temporarily closed
    //   'monitoring' → research/monitoring site, not shown to tourists
    final String status;
    if (isTouristSite) {
      status = (master['estado'] ?? 'A') == 'A' ? 'active' : 'inactive';
    } else {
      status = 'monitoring';
    }

    // Resolve island_id from master CSV isla field (tourist sites only)
    int? islandId;
    if (isTouristSite) {
      final islaName = orNull(master!['isla']);
      if (islaName != null) {
        islandId = islandIdByName[normalizeName(islaName)];
        if (islandId == null) {
          // Partial match fallback
          final normalized = normalizeName(islaName);
          for (final entry in islandIdByName.entries) {
            if (entry.key.contains(normalized) || normalized.contains(entry.key)) {
              islandId = entry.value;
              break;
            }
          }
        }
      }
    }

    // Coordinates: sitios.csv has decimal degrees (preferred)
    double? lat = parseDouble(sitio['latitud']);
    double? lng = parseDouble(sitio['longitud']);

    // Fallback to master CSV coords only if they look like decimal degrees (abs < 200)
    if (lat == null && lng == null && isTouristSite) {
      final rawLat = parseDouble(master!['latitud']);
      final rawLng = parseDouble(master['longitud']);
      if (rawLat != null && rawLat.abs() < 200) lat = rawLat;
      if (rawLng != null && rawLng.abs() < 200) lng = rawLng;
    }

    final data = <String, dynamic>{
      'park_id'           : parkId,
      'name_es'           : nameEs.trim(),
      'name_en'           : null,
      'island_id'         : islandId,
      'latitude'          : lat,
      'longitude'         : lng,
      'monitoring_type'   : orNull(sitio['tipo_monitoreo']),
      'difficulty'        : orNull(sitio['dificultad']),
      'conservation_zone' : orNull(sitio['zonificacion']),
      'public_use_zone'   : orNull(sitio['zona_uso_publico']),
      'status'            : status,
      // Tourist-site-only enrichment from master CSV
      'capacity'     : isTouristSite ? parseInt(master!['carga_aceptable'])       : null,
      'attraction_es': isTouristSite ? orNull(master!['atractivo_principal'])      : null,
      'abbreviation' : isTouristSite ? orNull(master!['abreviatura'])              : null,
      'last_revision': isTouristSite ? orNull(master!['fecha_ultima_revision'])    : null,
    };

    try {
      await client.from('visit_sites').insert(data);
      if (status == 'active')     activeCount++;
      else if (status == 'inactive') inactiveCount++;
      else                        monitoringCount++;
    } catch (e) {
      print('  ✗ Failed: "$nameEs" ($parkId): $e');
      skippedCount++;
    }
  }

  final total = activeCount + inactiveCount + monitoringCount;
  print('  ✓ visit_sites imported: $total');
  print('    → active (tourist visible): $activeCount');
  print('    → inactive (tourist, closed): $inactiveCount');
  print('    → monitoring/research: $monitoringCount');
  if (skippedCount > 0) print('    → skipped/failed: $skippedCount');
}

Future<Map<String, int>> _step5BuildParkIdMap(SupabaseClient client) async {
  final rows = await client
      .from('visit_sites')
      .select('id, park_id')
      .not('park_id', 'is', null);

  final map = <String, int>{};
  for (final row in rows) {
    final parkId = row['park_id'] as String?;
    final dbId   = row['id']      as int?;
    if (parkId != null && dbId != null) {
      map[parkId] = dbId;
    }
  }
  return map;
}

Future<void> _step6JunctionTables(
  SupabaseClient client,
  Map<String, int> parkIdToDbId,
) async {
  // ── visit_site_types ───────────────────────────────────────────────────
  final tiposContent = await File(_csvTipos).readAsString();
  final tiposRows = parseCsv(tiposContent);

  final typeRows = <Map<String, dynamic>>[];
  final typeSeen = <String>{};
  for (final row in tiposRows) {
    final sitioId = orNull(row['sitio_id']);
    final tipoId  = orNull(row['tipo_id']);
    if (sitioId == null || tipoId == null) continue;
    final dbId = parkIdToDbId[sitioId];
    if (dbId == null) continue;
    final key = '$dbId|$tipoId';
    if (typeSeen.contains(key)) continue;
    typeSeen.add(key);
    typeRows.add({'visit_site_id': dbId, 'type_id': tipoId});
  }

  if (typeRows.isNotEmpty) {
    await client.from('visit_site_types').insert(typeRows);
    print('  ✓ visit_site_types: ${typeRows.length} rows inserted');
  } else {
    print('  ! visit_site_types: no rows to insert (check sitio_id matching)');
  }

  // ── visit_site_modalities ──────────────────────────────────────────────
  final modalContent = await File(_csvModalidades).readAsString();
  final modalRows = parseCsv(modalContent);

  final modalityRows = <Map<String, dynamic>>[];
  final modalitySeen = <String>{};
  for (final row in modalRows) {
    final sitioId   = orNull(row['sitio_id']);
    final modalityId = orNull(row['id_mod']);
    if (sitioId == null || modalityId == null) continue;
    final dbId = parkIdToDbId[sitioId];
    if (dbId == null) continue;
    final key = '$dbId|$modalityId';
    if (modalitySeen.contains(key)) continue;
    modalitySeen.add(key);
    modalityRows.add({'visit_site_id': dbId, 'modality_id': modalityId});
  }

  if (modalityRows.isNotEmpty) {
    await client.from('visit_site_modalities').insert(modalityRows);
    print('  ✓ visit_site_modalities: ${modalityRows.length} rows inserted');
  } else {
    print('  ! visit_site_modalities: no rows to insert (check sitio_id matching)');
  }

  // ── visit_site_activities ──────────────────────────────────────────────
  final actContent = await File(_csvActividades).readAsString();
  final actRows = parseCsv(actContent);

  final activityRows = <Map<String, dynamic>>[];
  final activitySeen = <String>{};
  for (final row in actRows) {
    final sitioId    = orNull(row['sitio_id']);
    final activityId = orNull(row['actividad_id']);
    final carga      = orNull(row['carga_actividad']);
    if (sitioId == null || activityId == null) continue;
    final dbId = parkIdToDbId[sitioId];
    if (dbId == null) continue;
    final key = '$dbId|$activityId';
    if (activitySeen.contains(key)) continue;
    activitySeen.add(key);
    activityRows.add({
      'visit_site_id': dbId,
      'activity_id'  : activityId,
      'capacity'     : parseInt(carga),
    });
  }

  if (activityRows.isNotEmpty) {
    await client.from('visit_site_activities').insert(activityRows);
    print('  ✓ visit_site_activities: ${activityRows.length} rows inserted');
  } else {
    print('  ! visit_site_activities: no rows to insert (check sitio_id matching)');
  }
}
