import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/shell/galapagos_wildlife_app.dart';
import 'app/bootstrap/bootstrap.dart';
import 'data/local/drift/repository/wildlife_repository.dart';
import 'core/l10n/strings.g.dart';
import 'core/presentation/screens/sync_screen.dart';
import 'data/sync/initial_sync_service.dart';

Future<void> main() async {
  await Bootstrap.init();

  // Drift offline-first runs on all platforms (native SQLite + web Wasm/IndexedDB).
  final syncService = InitialSyncService(WildlifeRepository.instance);
  final needsSync = !await syncService.isSyncComplete();

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
