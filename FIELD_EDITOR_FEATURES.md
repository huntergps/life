# 🗺️ Field Editor - Sistema de Edición Offline

Sistema completo para corregir datos geográficos en campo sin conexión a internet.
**SOLO para usuarios administradores.**

---

## ✅ Funcionalidades Implementadas

### 1. 📍 Mover Sitios Mal Geolocalizados

#### Opción A: Arrastrar en Mapa (Manual)
- Tap en marker del sitio → entra en modo "Moving Site (Drag)"
- Arrastrar marker a nueva posición en el mapa
- Soltar → botón "Save" para confirmar
- Guarda offline en SQLite, sync automático después

#### Opción B: Usar Ubicación GPS Actual
- Tap en marker del sitio → botón "Use Current GPS Location"
- Mueve el sitio exactamente donde estás parado
- Útil cuando estás físicamente en el sitio correcto
- Guarda offline en SQLite

**Servicio:** `FieldEditService.updateVisitSiteLocation()`

---

### 2. 🛤️ Editar Senderos Existentes

#### Opción A: Edición Manual en Mapa
- Tap en polyline del trail → entra en modo "Editing Trail (Manual)"
- Muestra puntos editables del trazado (círculos pequeños)
- **Arrastrar puntos existentes** → mover a nueva posición
- **Tap en mapa** → agregar nuevo punto entre dos existentes
- **Tap en punto + Delete** → eliminar punto
- Botón "Save" para confirmar cambios
- Guarda offline en SQLite

#### Opción B: GPS Tracking (Re-grabar Caminando)
- Tap en polyline del trail → opción "Walk & Record GPS"
- Entra en modo "Editing Trail (GPS)"
- **Caminar la ruta real** → GPS graba posición cada 5 metros
- Panel en tiempo real: puntos, distancia, velocidad
- Botones: Pausar / Reanudar / Finalizar y Guardar
- Reemplaza coordenadas antiguas con las nuevas
- Guarda offline en SQLite

**Servicio:** `FieldEditService.updateTrailCoordinates()`

---

### 3. ➕ Grabar Nuevos Senderos

#### GPS Tracking desde Cero
- Botón "Record New Trail" en menú Field Edit
- Entra en modo "Recording New Trail"
- **Caminar la ruta** → GPS graba automáticamente
- Panel en tiempo real:
  - Puntos capturados
  - Distancia total (km)
  - Duración
  - Velocidad promedio
- Botones: Pausar / Reanudar / Stop & Save
- Dialog final: nombrar trail (inglés + español)
- Cálculo automático de distancia y tiempo estimado
- Guarda offline en SQLite

**Servicio:** `FieldEditService.createNewTrail()`

---

## 🔐 Seguridad: Solo Administradores

Todos los componentes verifican permisos de admin:

```dart
final isAdminAsync = ref.watch(isAdminProvider);
final isAdmin = isAdminAsync.asData?.value ?? false;

if (!isAdmin) return const SizedBox.shrink();
```

- `FieldEditToolbar` → solo visible para admins
- `isAdminProvider` → verifica tabla `admin_users` en Supabase
- Usa caché offline (SharedPreferences) para funcionar sin internet

---

## 📵 Offline-First Architecture

### Flujo de Datos:

1. **Edición Local**:
   ```
   Usuario edita → FieldEditService → Brick Repository → SQLite Local
   ```

2. **Sincronización Automática**:
   ```
   Brick detecta internet → offlineRequestQueue → Supabase Cloud
   ```

3. **Sin Internet**:
   - Todo se guarda en SQLite
   - Queue de sincronización acumula cambios
   - App funciona normalmente
   - Sync cuando vuelva internet

### Modelos Brick:

- `VisitSite` → `visit_sites` table
  - `id, islandId, nameEs, nameEn, latitude, longitude`

- `Trail` → `trails` table
  - `id, nameEs, nameEn, coordinates (JSON), distanceKm, estimatedMinutes`

---

## 🎯 UI/UX Flow

### Flujo para Mover Sitio:

```
1. Admin tap FAB "Field Edit"
2. Tap "Move Visit Site"
3. Elegir: "Drag on Map" o "Use Current GPS Location"
4. Tap en marker del sitio
   ├─ Drag on Map → arrastrar marker
   └─ GPS → automático a posición actual
5. Botón "Save" → confirma
6. Toast: "✅ Changes saved offline"
```

### Flujo para Editar Trail:

```
1. Admin tap FAB "Field Edit"
2. Tap "Edit Trail"
3. Elegir: "Edit on Map" o "Walk & Record GPS"
4. Tap en polyline del trail
   ├─ Edit on Map → drag puntos, add nuevos
   └─ Walk GPS → caminar + tracking automático
5. Pausar / Reanudar según necesario
6. Stop & Save → confirma
7. Toast: "✅ Trail updated offline"
```

### Flujo para Nuevo Trail:

```
1. Admin tap FAB "Field Edit"
2. Tap "Record New Trail"
3. Toast: "🚶 Start walking - GPS will track your path"
4. Caminar la ruta (GPS tracking automático)
5. Panel muestra stats en tiempo real
6. Stop & Save cuando termines
7. Dialog: nombrar trail (EN + ES)
8. Save → Toast: "✅ Trail saved offline"
```

---

## 📊 Componentes Implementados

### Providers:
- `FieldEditProvider` - Estado de edición
  - `FieldEditMode`: none, moveSiteManual, moveSiteGPS, editTrailManual, editTrailGPS, recordNew
  - `selectedSiteId`, `selectedTrailId`
  - `recordingPoints`, `isRecording`, `recordingStartTime`
  - `hasUnsavedChanges`

### Services:
- `FieldEditService` - Lógica offline-first
  - `updateVisitSiteLocation()` → SQLite → Supabase
  - `updateTrailCoordinates()` → SQLite → Supabase
  - `createNewTrail()` → SQLite → Supabase
  - Auto-sync con Brick's `offlineRequestQueue`

### Widgets:
- `FieldEditToolbar` - Menú y toolbar de edición
  - FAB "Field Edit" (solo admins)
  - Menú de opciones con sub-menús
  - Toolbar flotante con indicador de modo
  - Controles: Pause/Resume/Save/Cancel

- `TrailRecordingPanel` - Panel de GPS tracking
  - Stats en tiempo real (distancia, puntos, velocidad)
  - GPS tracking automático (cada 5m de movimiento)
  - Request de permisos de ubicación
  - Funciona para recordNew y editTrailGPS

---

## 🔄 Próximos Pasos

### Pendiente: Integrar en MapScreen

Necesita implementar:

1. **Gestos de Edición**:
   - `onTap` en marker → seleccionar sitio para mover
   - `onLongPress` en marker → activar drag mode
   - `onTap` en polyline → seleccionar trail para editar
   - `onTap` en mapa (edit mode) → agregar punto a trail
   - Drag de markers/puntos editables

2. **Visualización**:
   - Mostrar `FieldEditToolbar` cuando admin activo
   - Mostrar `TrailRecordingPanel` durante GPS tracking
   - Markers editables: diferentes color/estilo
   - Polylines editables: puntos visibles como círculos
   - Trail en construcción: polyline naranja en tiempo real

3. **Lógica de Guardado**:
   - Cuando usuario tap "Save" → llamar `FieldEditService`
   - Pasar coordenadas actualizadas
   - Mostrar confirmación
   - Limpiar estado de edición

---

## 📝 Notas Técnicas

### GPS Tracking Config:

```dart
const locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 5, // Solo actualizar si movió 5+ metros
);
```

### Distancia y Tiempo:

- Cálculo con `latlong2.Distance()`
- Distancia en km: `totalMeters / 1000`
- Tiempo estimado: `(distanceKm / 3.0) * 60` (asume 3 km/h caminando)

### IDs Temporales:

Para trails nuevos creados offline:
```dart
final tempId = -DateTime.now().millisecondsSinceEpoch;
```

Brick asignará ID real cuando sincronice con Supabase.

---

**Estado Actual:** 4/6 tareas completadas
**Pendiente:** Integrar en MapScreen + UI de sincronización

**Actualizado:** 2026-02-16
