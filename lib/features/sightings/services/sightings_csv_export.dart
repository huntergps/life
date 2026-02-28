import 'dart:io';

import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/brick/models/sighting.model.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Exports sightings list to CSV and shares via the OS share sheet.
Future<void> exportSightingsCsv({
  required BuildContext context,
  required List<Sighting> sightings,
  required Map<int, Species> speciesMap,
}) async {
  if (sightings.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t.sightings.noSightingsToExport)),
    );
    return;
  }

  final isEs = LocaleSettings.currentLocale == AppLocale.es;
  final buf = StringBuffer();

  // CSV header
  buf.writeln('Species,Scientific Name,Date,Latitude,Longitude,Notes');

  for (final s in sightings) {
    final species = speciesMap[s.speciesId];
    final name = species != null
        ? (isEs ? species.commonNameEs : species.commonNameEn)
        : 'ID ${s.speciesId}';
    final scientific = species?.scientificName ?? '';
    final date = s.observedAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(s.observedAt!)
        : '';
    final lat = s.latitude?.toStringAsFixed(6) ?? '';
    final lng = s.longitude?.toStringAsFixed(6) ?? '';
    final notes = _escapeCsv(s.notes ?? '');

    buf.writeln('${_escapeCsv(name)},$scientific,$date,$lat,$lng,$notes');
  }

  // Write to temp file
  final dir = await getTemporaryDirectory();
  final dateStamp = DateFormat('yyyyMMdd').format(DateTime.now());
  final file = File('${dir.path}/sightings_$dateStamp.csv');
  await file.writeAsString(buf.toString());

  // Share
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Galapagos Sightings Export',
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.zero,
    ),
  );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t.sightings.exported)),
    );
  }
}

/// Escapes a value for CSV (wraps in quotes if contains comma, newline, or quotes).
String _escapeCsv(String value) {
  if (value.contains(',') || value.contains('\n') || value.contains('"')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
