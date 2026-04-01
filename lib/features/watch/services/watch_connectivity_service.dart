import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_watch_os_connectivity/flutter_watch_os_connectivity.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';

/// Servicio de comunicación con el Apple Watch via flutter_watch_os_connectivity.
///
/// Usa WatchConnectivity (WCSession) de Apple para sincronizar datos entre
/// el iPhone (Flutter) y el Watch (SwiftUI).
///
/// Flujos de datos:
///   iPhone → Watch : especies via updateApplicationContext (background sync)
///   Watch → iPhone : avistamientos via sendMessage (tiempo real) o transferUserInfo (offline)
///   Watch → iPhone : trails via transferUserInfo (background)
class WatchConnectivityService {
  static WatchConnectivityService? _instance;
  static WatchConnectivityService get instance =>
      _instance ??= WatchConnectivityService._();

  final _watch = FlutterWatchOsConnectivity();
  bool _activated = false;

  final _sightingController = StreamController<Map<String, dynamic>>.broadcast();
  final _trailController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onSightingReceived => _sightingController.stream;
  Stream<Map<String, dynamic>> get onTrailReceived => _trailController.stream;

  WatchConnectivityService._();

  // ─────────────────────────────────────────────────────
  // Inicialización
  // ─────────────────────────────────────────────────────

  Future<void> activate() async {
    if (_activated) return;
    try {
      // configureAndActivateSession() inicializa el observer Y llama activate().
      // Debe llamarse PRIMERO antes de acceder a cualquier stream.
      await _watch.configureAndActivateSession();

      // Ahora sí podemos escuchar el evento de activación (si no ha llegado aún).
      final completer = Completer<void>();
      late StreamSubscription sub;
      sub = _watch.activationStateChanged.listen((state) {
        debugPrint('🐾 WatchConnectivity: activationState=$state');
        if (state == ActivationState.activated) {
          sub.cancel();
          if (!completer.isCompleted) completer.complete();
        }
      });
      // Timeout de 5 s; si ya estaba activado el evento puede no re-emitirse
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () { sub.cancel(); },
      );
      _activated = true;
      _listenIncoming();

      // Log estado del Watch para diagnóstico
      try {
        final info = await _watch.getPairedDeviceInfo();
        debugPrint('🐾 Watch isPaired=${info.isPaired} isInstalled=${info.isWatchAppInstalled} isReachable=${await _watch.getReachability()}');
      } catch (e) {
        debugPrint('🐾 Watch info error: $e');
      }
      debugPrint('🐾 WatchConnectivity: sesión activada');
    } catch (e) {
      debugPrint('🐾 WatchConnectivity ERROR activando: $e');
      AppLogger.error('WatchConnectivity: error activando sesión', e);
    }
  }

  void _listenIncoming() {
    // Mensajes en tiempo real (Watch en foreground, iPhone desbloqueado)
    _watch.messageReceived.listen((message) {
      _handleIncoming(message.data);
    });

    // Cola offline (transferUserInfo — entrega garantizada)
    _watch.userInfoReceived.listen((userInfo) {
      _handleIncoming(userInfo);
    });
  }

  void _handleIncoming(Map<dynamic, dynamic> raw) {
    final dict = raw.map((k, v) => MapEntry(k.toString(), v));
    final action = dict['action'] as String?;

    switch (action) {
      case 'new_sighting':
        final data = (dict['data'] as Map?)
            ?.map((k, v) => MapEntry(k.toString(), v));
        if (data != null) {
          AppLogger.info('Watch: avistamiento recibido — ${data['species_name']}');
          _sightingController.add(data);
        }

      case 'new_trail':
        AppLogger.info('Watch: trail recibido — ${dict['name']}');
        _trailController.add(dict);

      default:
        AppLogger.info('Watch: mensaje desconocido — $action');
    }
  }

  // ─────────────────────────────────────────────────────
  // Enviar especies al Watch
  // ─────────────────────────────────────────────────────

  /// Sincroniza la lista de especies al Watch.
  /// - updateApplicationContext: entrega en background (persiste aunque Watch reinicie)
  /// - sendMessage: entrega inmediata si el Watch está en foreground (más confiable al probar)
  Future<void> sendSpeciesToWatch(List<Map<String, dynamic>> species) async {
    if (!_activated) await activate();

    // Skip entirely if the Watch app is not installed
    try {
      final info = await _watch.getPairedDeviceInfo();
      if (!info.isWatchAppInstalled) {
        debugPrint('🐾 Watch: app no instalada, omitiendo sincronización');
        return;
      }
    } catch (e) {
      debugPrint('🐾 Watch: no se pudo verificar instalación, omitiendo: $e');
      return;
    }

    final data = jsonEncode(species);
    debugPrint('🐾 Watch: enviando ${species.length} especies...');

    // 1. Background: persiste para próximo launch del Watch
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await _watch.updateApplicationContext({'species': data});
        debugPrint('🐾 Watch: applicationContext OK (intento $attempt)');
        break;
      } catch (e) {
        debugPrint('🐾 Watch: applicationContext FALLÓ intento $attempt: $e');
        if (attempt < 3) await Future.delayed(const Duration(seconds: 3));
      }
    }

    // 2. Real-time: entrega inmediata si el Watch está en foreground
    try {
      final isReachable = await _watch.getReachability();
      debugPrint('🐾 Watch: isReachable=$isReachable');
      if (isReachable) {
        await _watch.sendMessage({'action': 'update_species', 'data': data});
        debugPrint('🐾 Watch: sendMessage OK');
      }
    } catch (e) {
      debugPrint('🐾 Watch: sendMessage FALLÓ: $e');
      AppLogger.error('Watch: sendMessage falló', e);
    }
  }

  void dispose() {
    _sightingController.close();
    _trailController.close();
  }
}
