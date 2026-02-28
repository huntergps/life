# 🗺️ Caché de Mapas Satelitales - Explicación

## 🔍 Estado Actual

### Street Mode (OpenStreetMap)
```dart
TileLayer(
  tileProvider: FMTCTileProvider(  // ✅ Caché persistente
    stores: const {
      'galapagosMap': BrowseStoreStrategy.readUpdateCreate,
    },
  ),
)
```
- ✅ **Caché persistente** con FMTC (Flutter Map Tile Caching)
- ✅ **Sobrevive al cerrar la app**
- ✅ **Funciona 100% offline** después de descargar
- ✅ **Descarga proactiva** (puedes pre-descargar áreas)

### Satellite Mode (ESRI)
```dart
TileLayer(
  urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
  // ❌ NO tiene tileProvider con FMTC
)
```
- ⚠️ **Solo caché temporal en memoria** (flutter_map interno)
- ❌ **Se borra al cerrar la app**
- ❌ **NO funciona offline**
- ❌ **NO hay descarga proactiva**

---

## 💡 ¿Por Qué Funciona Online?

Cuando ves el mapa satelital online:

1. **Primera vez**: Descarga tiles desde ESRI → se muestran → **caché en memoria** (RAM)
2. **Pan/Zoom**: Si ya está en RAM → muestra inmediatamente (muy rápido)
3. **Cierras la app**: RAM se libera → **caché se pierde**
4. **Abres de nuevo**: Necesita descargar otra vez

**Ese caché temporal SÍ existe, pero NO es persistente.**

---

## ✅ Solución: Caché Oportunista para Satellite

### ¿Qué es "Caché Oportunista"?

No es "descargar todo Galápagos" (50-100 GB), sino:
- **Guardar solo lo que ya viste**
- Si navegas a Santa Cruz → se guarda en disco
- Si vuelves a Santa Cruz offline → muestra el caché
- Si vas a Isabella offline → no hay caché, muestra error

### Implementación Técnica

```dart
// ANTES (sin caché persistente)
TileLayer(
  urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
  // Solo caché temporal en memoria
)

// DESPUÉS (con caché persistente oportunista)
TileLayer(
  urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
  tileProvider: FMTCTileProvider(  // ✅ Igual que Street
    stores: const {
      'satelliteCache': BrowseStoreStrategy.readUpdateCreate,
    },
  ),
)
```

### Ventajas
- ✅ **Gratis** - sin configuración adicional
- ✅ **Tamaño controlado** - solo lo que viste (típicamente 50-500 MB)
- ✅ **Offline parcial** - áreas visitadas funcionan offline
- ✅ **UX mejorado** - menos recargas innecesarias
- ✅ **No viola ToS** - solo cachea lo que mostraste, no descarga masiva

### Desventajas
- ⚠️ **No es 100% offline** - solo áreas ya visitadas
- ⚠️ **Puede crecer** - si navegas mucho, el caché crece
- ⚠️ **Gestión manual** - usuario podría querer limpiar caché

---

## 🎯 Recomendación

### Opción 1: **Implementar Caché Oportunista** ✅ (Recomendado)

**Razones:**
- Gratis, fácil de implementar (1 línea de código)
- Mejora UX sin inflar app
- No viola ToS (no es descarga masiva)
- Usuario decide qué áreas cachear (navegando)

**Limitaciones:**
- No es descarga proactiva como Street
- Solo funciona offline en áreas ya visitadas
- Necesitas agregar UI para gestionar caché (opcional)

### Opción 2: **Mantener Como Está** (Online-only)

**Razones:**
- Más simple
- Sin gestión de caché
- Tamaño app más pequeño

**Limitaciones:**
- Necesita internet SIEMPRE para satellite
- Recargas innecesarias

---

## 🚀 Implementación Propuesta

### Paso 1: Agregar FMTC a Satellite/Hybrid

```dart
// lib/features/map/presentation/screens/map_screen.dart

// Satellite mode
else if (tileMode == MapTileMode.satellite)
  TileLayer(
    urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
    tileProvider: FMTCTileProvider(
      stores: const {
        'satelliteCache': BrowseStoreStrategy.readUpdateCreate,
      },
    ),
    maxNativeZoom: 19,
    maxZoom: 19,
  ),

// Hybrid mode (satellite base)
else if (tileMode == MapTileMode.hybrid) ...[
  TileLayer(
    urlTemplate: SatelliteMapConstants.esriSatelliteUrl,
    tileProvider: FMTCTileProvider(
      stores: const {
        'satelliteCache': BrowseStoreStrategy.readUpdateCreate,  // Mismo store
      },
    ),
    maxNativeZoom: 19,
    maxZoom: 19,
  ),
  // CartoDB labels
  TileLayer(
    urlTemplate: SatelliteMapConstants.cartoLabelsUrl,
    tileProvider: FMTCTileProvider(
      stores: const {
        'labelsCache': BrowseStoreStrategy.readUpdateCreate,
      },
    ),
  ),
]
```

### Paso 2: Agregar UI para Gestionar Caché (Opcional)

En Settings → Storage:

```dart
// Mostrar tamaño de caché satellite
ListTile(
  leading: Icon(Icons.satellite),
  title: Text('Satellite Cache'),
  subtitle: Text('150 MB'), // Tamaño calculado
  trailing: IconButton(
    icon: Icon(Icons.delete),
    onPressed: () {
      // Limpiar caché satellite
      FMTC.instance('satelliteCache').manage.delete();
    },
  ),
)
```

### Paso 3: Actualizar Documentación

En `OFFLINE_MAPS_EXPLANATION.md`:

```markdown
| Modo | Offline | Online | Notas |
|------|---------|--------|-------|
| Satellite | ⚠️ Parcial | ✅ Funciona | Funciona offline en áreas ya visitadas |
| Hybrid | ⚠️ Parcial | ✅ Funciona | Funciona offline en áreas ya visitadas |
```

---

## 📊 Comparación: Antes vs Después

| Característica | Antes (Sin Caché) | Después (Caché Oportunista) |
|----------------|-------------------|------------------------------|
| **Primera visita** | Descarga desde ESRI | Descarga desde ESRI |
| **Segunda visita (online)** | Redownload innecesario | Usa caché (rápido) |
| **Segunda visita (offline)** | ❌ Error | ✅ Muestra caché |
| **Tamaño app** | ~50 MB | ~50-500 MB (crece con uso) |
| **ToS compliance** | ✅ OK | ✅ OK (no es descarga masiva) |
| **UX offline** | ❌ No funciona | ⚠️ Parcial (áreas visitadas) |

---

## ✅ Conclusión

**Sí, SE PUEDE cachear las imágenes satelitales que ya se mostraron.**

Es tan simple como agregar `tileProvider: FMTCTileProvider(...)` a los TileLayer de satellite/hybrid.

**¿Quieres que lo implemente?** Es un cambio de ~10 líneas de código.

---

**Actualizado:** 2026-02-16
