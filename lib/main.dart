import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'bootstrap.dart';
import 'brick/repository.dart';
import 'core/l10n/strings.g.dart';
import 'core/presentation/screens/sync_screen.dart';
import 'core/services/initial_sync_service.dart';

Future<void> main() async {
  await Bootstrap.init();

  // On web, Brick/SQLite is not used — skip local sync check and show app directly.
  bool needsSync = false;
  if (!kIsWeb) {
    final syncService = InitialSyncService(Repository());
    needsSync = !await syncService.isSyncComplete();
  }

  runApp(
    TranslationProvider(
      child: ProviderScope(
        child: needsSync
            ? _SyncWrapper()
            : const GalapagosWildlifeApp(),
      ),
    ),
  );
}

class _SyncWrapper extends StatefulWidget {
  @override
  State<_SyncWrapper> createState() => _SyncWrapperState();
}

class _SyncWrapperState extends State<_SyncWrapper> {
  bool _syncDone = false;

  @override
  Widget build(BuildContext context) {
    if (_syncDone) {
      return const GalapagosWildlifeApp();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SyncScreen(
        onSyncComplete: () {
          if (!mounted) return;
          setState(() => _syncDone = true);
        },
      ),
    );
  }
}
