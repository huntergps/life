# Plan: Apple Watch Companion App — Galápagos Wildlife

**Fecha de creación**: 2026-02-17
**Estado**: Planificación — no iniciado
**Contexto**: Investigación completada, listo para implementar

---

## Resumen Ejecutivo

Crear una app nativa watchOS en Swift/SwiftUI como companion del app Flutter.
La comunicación es: `Flutter (Dart) ↔ Method Channel ↔ WCSession ↔ watchOS (Swift)`.

**No existe ninguna app de observación de naturaleza con Apple Watch** que haga todo esto junto.
La competencia directa (iNaturalist, Merlin, AllTrails) no tiene Watch app.

---

## Prioridad de Features (en orden de implementación)

### FASE 1 — MVP (lo más impactante)

#### F1. Logger de avistamiento rápido
- Pantalla principal del Watch: lista las 5-8 especies más probables del sitio actual (por GPS)
- Toca la especie → log con timestamp + GPS automático
- **Double Tap** (Series 9+/Ultra): confirma la especie destacada sin tocar pantalla
- Funciona offline: guarda en SQLite local del Watch, sincroniza cuando el iPhone esté cerca
- Datos van a la tabla `sightings` de Supabase (misma que el app Flutter)

#### F2. Complicación del Watch Face (estadísticas del día)
- **Circular**: número de avistamientos hoy
- **Rectangular**: última especie vista + hace cuánto tiempo
- **Corner**: tap directo al logger

#### F3. Smart Stack Widget (watchOS 10+)
- Aparece automáticamente cuando el GPS detecta que estás en una zona de visita
- Muestra: nombre del sitio, isla, cuenta de avistamientos del día
- Relevancia basada en ubicación GPS

---

### FASE 2 — Herramientas de campo

#### F4. Grabación de trail (sin sacar el iPhone)
- Inicia HKWorkoutSession (GPS continuo en background)
- Graba puntos cada 5 metros (mismo filtro que el app Flutter)
- Guarda iPhone en la mochila, camina el sendero
- Al terminar: sync por WatchConnectivity → iPhone → `field_edit_service.updateTrailCoordinates()`
- Compatible con la tabla `trails` ya existente (formato `[[lat,lng],...]`)

#### F5. Actualizar posición de Visit Site
- "Estoy parado en la entrada del sitio" → toca "Actualizar ubicación"
- GPS actual → sync → `field_edit_service.updateVisitSiteLocation()`
- Solo para usuarios admin

#### F6. Brújula + Waypoints
- Marcar punto de observación ("Tortuga aquí a las 9:23am")
- Ver distancia/dirección de regreso al punto de inicio
- Integra con el Backtrack nativo de watchOS (Compass app)

---

### FASE 3 — Features premium (Ultra + avanzado)

#### F7. Modo Snorkeling (Apple Watch Ultra exclusivo)
- Profundidad + temperatura del agua (sensores del Ultra)
- Log rápido de especie marina desde bajo el agua
- Basado en el modelo de Oceanic+ app

#### F8. Guía offline por isla
- Pre-carga las 20-30 especies de la isla seleccionada en el Watch
- Foto en miniatura comprimida para identificación
- Estado de conservación, nombre científico
- No requiere red ni iPhone cerca

#### F9. Notificaciones de badges
- Vibración haptic al desbloquear una medalla
- Muestra nombre del badge en la pantalla del Watch

---

## Arquitectura Técnica

```
Flutter App (Dart)
│
├── lib/watch/
│   ├── watch_connectivity_service.dart   ← Method Channel con nativo iOS
│   └── watch_data_sync_provider.dart     ← Riverpod provider para Watch state
│
├── ios/
│   ├── Runner/WatchConnectivityHandler.swift  ← WCSession delegate (iOS side)
│   └── GalapagosWatch/                        ← TARGET watchOS (nuevo)
│       ├── GalapagosWatchApp.swift
│       ├── ContentView.swift              ← Nav principal
│       ├── Views/
│       │   ├── SightingLoggerView.swift   ← F1: logger principal
│       │   ├── TrailRecordingView.swift   ← F4: grabación de trail
│       │   └── SpeciesListView.swift      ← F8: guía offline
│       ├── Complications/
│       │   └── SightingCountComplication.swift ← F2
│       ├── Widgets/
│       │   └── SmartStackWidget.swift     ← F3
│       ├── Models/
│       │   ├── WatchSighting.swift        ← modelo local
│       │   └── WatchSpecies.swift         ← especie compacta
│       ├── Services/
│       │   ├── WatchConnectivityService.swift ← WCSession (Watch side)
│       │   ├── LocationService.swift      ← CLLocationManager
│       │   └── LocalStorageService.swift  ← SQLite/UserDefaults offline
│       └── GalapagosWatchExtension/       ← Widget extension (complicaciones)
```

### Comunicación WCSession

| Método | Uso | Dirección |
|--------|-----|-----------|
| `updateApplicationContext()` | Lista de especies por zona actual | iPhone → Watch |
| `transferUserInfo()` | Avistamientos pendientes de sync | Watch → iPhone |
| `sendMessage()` | Solicitud de datos en tiempo real | Watch ↔ iPhone |
| `transferFile()` | Imágenes comprimidas de especies (F8) | iPhone → Watch |

### Paquete Flutter recomendado
- `flutter_watch_os_connectivity` (pub.dev) — wrapper de WCSession para Dart

---

## Requisitos de Base de Datos

No se necesitan cambios al schema de Supabase. Los avistamientos del Watch usan la misma tabla `sightings` con los campos existentes:
- `user_id`, `species_id`, `latitude`, `longitude`, `observed_at`, `notes`

El `species_id` se resuelve en el iPhone antes de sincronizar (el Watch solo guarda el nombre localmente hasta sincronizar).

---

## Requisitos Mínimos del Dispositivo

| Feature | Mínimo |
|---------|--------|
| Logger + Complicaciones | Apple Watch Series 4, watchOS 7+ |
| Double Tap (manos libres) | Apple Watch Series 9 / Ultra 2 |
| Smart Stack | Apple Watch Series 4+, watchOS 10+ |
| Grabación de trail (GPS) | Apple Watch Series 2+ |
| Modo snorkeling | Apple Watch Ultra / Ultra 2 únicamente |

---

## Pasos de Implementación (paso a paso)

### Paso 1 — Configurar el target watchOS en Xcode
```
Xcode → File → New → Target → watchOS → Watch App
- Product Name: GalapagosWatch
- Bundle Identifier: com.galapagos.wildlife.watchkitapp
- Deployment Target: watchOS 7.0
- Language: Swift
- Interface: SwiftUI
```
⚠️ Asegurarse de que el nuevo target esté en el mismo scheme que Runner.

### Paso 2 — Implementar WCSession en iOS (Swift)
- Crear `WatchConnectivityHandler.swift` en `ios/Runner/`
- Conformar a `WCSessionDelegate`
- Manejar: `session(_:didReceiveUserInfo:)`, `session(_:didReceiveMessage:)`
- Registrar con Method Channel para exponer a Flutter

### Paso 3 — Implementar WCSession en watchOS (Swift)
- `WatchConnectivityService.swift` en el target watchOS
- `transferUserInfo()` para encolar avistamientos offline
- `receiveApplicationContext()` para recibir lista de especies

### Paso 4 — Implementar en Flutter (Dart)
- `lib/watch/watch_connectivity_service.dart` con Method Channel
- `lib/watch/watch_data_sync_provider.dart` con Riverpod

### Paso 5 — UI del Watch: SightingLoggerView (F1)
- Lista de 5-8 especies en NavigationStack
- Botón de confirmar grande (fácil de tocar)
- Feedback haptico al guardar

### Paso 6 — Complicaciones (F2)
- WidgetKit extension para watchOS
- Families: `.accessoryCircular`, `.accessoryRectangular`, `.accessoryCorner`
- Timeline provider: actualiza al registrar avistamiento

### Paso 7 — Smart Stack Widget (F3)
- Misma extensión de WidgetKit
- `WidgetRelevance` basado en `CLLocation`

### Paso 8 — Trail Recording (F4)
- `HKWorkoutSession` para GPS continuo en background
- Acumular `CLLocation` points
- Al finalizar: `transferUserInfo()` con array JSON `[[lat,lng],...]`
- En Flutter: `field_edit_service.updateTrailCoordinates()`

---

## Referencias Clave del Proyecto

| Recurso | Ruta |
|---------|------|
| Field Edit Service (trails) | `lib/features/map/services/field_edit_service.dart` |
| Field Edit Provider | `lib/features/map/providers/field_edit_provider.dart` |
| Trail Recording Panel (iPhone) | `lib/features/map/presentation/widgets/trail_recording_panel.dart` |
| Trail Model | `lib/brick/models/trail.model.dart` |
| Visit Site Model | `lib/brick/models/visit_site.model.dart` |
| Admin Visit Sites | `lib/features/admin/presentation/screens/visit_sites/` |
| Sightings Feature | `lib/features/sightings/` |
| Schema SQL completo | `supabase/migrations/20260210000000_complete_schema.sql` |

---

## Apps de Referencia Investigadas

- **Big Year Birding** (App Store): única app de aves con Watch logger, modelo a seguir para F1
- **Oceanic+**: modelo para F7 (snorkeling con Ultra)
- **Komoot** (ene 2026): offline maps en Watch standalone, modelo para F8
- **AllTrails**: off-route alerts con haptic, modelo para F6

---

## Notas de Investigación

- iNaturalist (2M observaciones/día) NO tiene Apple Watch app → oportunidad enorme
- Galápagos Wildlife sería la **única app de naturaleza** con: logger + GPS trail + datos offline + modo marino en Watch
- `HKWorkoutSession` es el mecanismo correcto para GPS continuo en background (sin él, watchOS suspende el GPS)
- El Watch tiene su propio GPS — no necesita el iPhone cerca para grabar trail
- `flutter_watch_os_connectivity` simplifica la comunicación pero el Watch app SIEMPRE se escribe en Swift/SwiftUI
