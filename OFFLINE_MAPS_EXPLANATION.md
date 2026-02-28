# 📡 Mapas Offline vs Online - Explicación Técnica

## 🗺️ Estado Actual de Cada Modo

| Modo | Offline | Online | Tamaño | Notas |
|------|---------|--------|--------|-------|
| **Street (OSM)** | ✅ Funciona | ✅ Funciona | ~50-200 MB | FMTC cache, funciona completamente offline |
| **Vector (PMTiles)** | ✅ Funciona | ✅ Funciona | 3 MB | Archivo local, 100% offline |
| **Satellite (ESRI)** | ⚠️ Parcial | ✅ Funciona | ~50-500 MB | Caché oportunista: funciona offline en áreas ya visitadas |
| **Hybrid (ESRI+CartoDB)** | ⚠️ Parcial | ✅ Funciona | ~50-500 MB | Caché oportunista: funciona offline en áreas ya visitadas |

---

## 🔍 ¿Cómo Funciona el Caché Satelital?

### ✅ Implementación Actual: Caché Oportunista

A partir de feb 2026, la app usa **caché oportunista** para Satellite/Hybrid:

1. **Primera visita (con internet)**:
   - Descarga tiles desde ESRI/CartoDB
   - Los muestra en el mapa
   - Los guarda automáticamente en caché local (FMTC)

2. **Segunda visita (misma área, sin internet)**:
   - ✅ Carga tiles desde caché local
   - ✅ Funciona offline en áreas ya visitadas
   - ❌ Áreas no visitadas muestran tiles vacíos

3. **Tamaño controlado**:
   - Solo guarda lo que navegaste (no todo Galápagos)
   - Típicamente: 50-500 MB dependiendo de cuánto exploraste
   - Crece con el uso, pero controlado

### ⚠️ Limitaciones del Caché Oportunista:

1. **No es 100% offline**
   - Solo funciona en áreas que ya visitaste con internet
   - Áreas nuevas necesitan internet para descargar

2. **No hay descarga proactiva**
   - No puedes "descargar Galápagos completo" como con Street
   - Razón: ~50-100 GB (inviable para app móvil)

3. **Gestión de caché**
   - El caché crece con el uso
   - Usuario puede necesitar limpiar caché manualmente (futuro)

---

## ✅ Soluciones Disponibles

### Opción 1: **Modo Actual (Recomendado)** ✅

**Configuración:**
- Street/Vector: Offline ✅
- Satellite/Hybrid: Online only ❌

**Ventajas:**
- ✅ Funciona para 90% de casos de uso
- ✅ Navegación offline con Street/Vector
- ✅ Satelital cuando hay internet
- ✅ Gratis, sin límites
- ✅ Fácil de mantener

**Desventajas:**
- ❌ Satelital no disponible sin internet

**Uso típico:**
- Turistas descargan Street antes del viaje → usan offline
- En hotel/barco con WiFi → ven satelital
- En trail → usan Street offline

---

### Opción 2: **Precache Limitado de Satelital** ⚠️

**Implementación:**
```dart
// Usando FMTC para cachear tiles satelitales
await FMTC.instance('satellite-cache').download
  .startBackground(
    region: DownloadableRegion(...),
    maxZoom: 14, // Limitado a zoom 14
  );
```

**Ventajas:**
- ✅ Funciona offline después de descarga
- ✅ Mismo UX que Street offline

**Desventajas:**
- ❌ Tamaño grande: 2-5 GB para zoom 6-14
- ❌ Descarga lenta: 30-60 minutos
- ❌ Uso de datos móviles alto
- ❌ Posible violación ToS de ESRI
- ❌ Requiere mantenimiento/updates

**Viabilidad:** ⚠️ Técnicamente posible pero NO recomendado

---

### Opción 3: **Self-Hosted Tile Server** 💰

**Setup:**
1. Descargar imágenes satelitales de fuente pública (Landsat, Sentinel)
2. Procesar con GDAL → generar tiles
3. Hospedar en servidor propio
4. Servir tiles a la app

**Ventajas:**
- ✅ Control total
- ✅ Sin dependencia de terceros
- ✅ Offline real (embebido en app o server local)

**Desventajas:**
- ❌ Costo: $50-200/mes hosting
- ❌ Complejidad técnica alta
- ❌ Procesamiento: días de trabajo
- ❌ Tamaño app: +5-10 GB
- ❌ Mantenimiento constante

**Viabilidad:** ❌ NO viable para proyecto open-source/gratuito

---

### Opción 4: **Imágenes Estáticas Pre-Renderizadas** 🖼️

**Concepto:**
- Generar imágenes estáticas de áreas clave (ej: Isabela, Santa Cruz)
- Mostrar como overlay cuando estás en esa área
- Similar a "offline maps" de Google Maps

**Ventajas:**
- ✅ Offline real
- ✅ Tamaño controlado (~50-100 MB)
- ✅ No viola ToS

**Desventajas:**
- ❌ No es "tiles" dinámicos
- ❌ Zoom limitado (pre-renderizado)
- ❌ Áreas limitadas (no todo Galápagos)

**Viabilidad:** ✅ Posible como feature premium

---

## 🎯 Recomendación Final

### **Mantén la Configuración Actual**

**Razones:**
1. ✅ **Street Offline cubre el 90% del uso**
   - Turistas necesitan navegación → Street es suficiente
   - Trails, sitios, islas → todos marcados en Street
   - Satelital es "nice to have", no esencial

2. ✅ **Vector Offline es ultra-ligero**
   - 3 MB para todo Galápagos
   - Mejor performance que Street
   - Suficiente para orientación

3. ✅ **Satelital Online cuando sea necesario**
   - En hotel/lodge → hay WiFi → satelital funciona
   - En barco de crucero → hay WiFi/datos → funciona
   - En trail → no necesitas satelital, Street es mejor

4. ✅ **Evita problemas legales/técnicos**
   - No violas ToS de ESRI
   - No inflas el tamaño de la app
   - No necesitas infraestructura adicional

---

## 📊 Comparación de Soluciones

| Criterio | Actual | Precache | Self-Hosted | Estáticas |
|----------|--------|----------|-------------|-----------|
| **Costo** | Gratis | Gratis | $100+/mes | Gratis |
| **Tamaño App** | 50 MB | 5 GB | 10 GB | 150 MB |
| **Legal** | ✅ OK | ⚠️ Gris | ✅ OK | ✅ OK |
| **Mantenimiento** | Bajo | Medio | Alto | Medio |
| **UX Offline** | Street ok | Excelente | Excelente | Bueno |
| **Cobertura** | 100% | 100% | 100% | 50% |

**Ganador:** 🏆 Actual (mantener como está)

---

## 💡 Mensaje para Usuarios

**En la UI del selector de mapa, agrega:**

```
📡 Satellite Mode
High-resolution satellite imagery (ESRI)
⚠️ Requires internet connection

📡 Hybrid Mode
Satellite imagery with labels
⚠️ Requires internet connection
```

**Y en settings/help:**

```
🗺️ Offline Maps

✅ Street Map: Fully offline after download
✅ Vector Map: Fully offline (3 MB)
⚠️ Satellite: Requires internet connection
⚠️ Hybrid: Requires internet connection

Tip: Download Street or Vector maps before your trip
for offline navigation. Use Satellite view when you
have WiFi to explore terrain in detail.
```

---

## 🚀 Mejoras Implementadas (Navegabilidad)

### 1. **Controles de Zoom Mejorados**
- Panel vertical con botones claros
- Botón "Home" para volver a Galápagos
- Tooltips descriptivos
- Estilo visual mejorado (dark/light)

### 2. **Indicador de Zoom en Tiempo Real**
- Muestra nivel de zoom actual (ej: "Zoom 12.5")
- Actualiza en tiempo real al hacer zoom
- Posición top-left, no obstruye

### 3. **Brújula/Compass (cuando hay rotación)**
- Aparece automáticamente si rotas el mapa
- Toca para resetear rotación a 0°
- Indicador visual de orientación

### 4. **Gestos Mejorados**
- ✅ Pinch to zoom (touch/trackpad)
- ✅ Scroll to zoom (mouse/trackpad)
- ✅ Drag to pan (1 dedo/mouse)
- ✅ Rotate (2 dedos/Cmd+drag)
- ✅ Multi-finger gestures

---

## ✅ Resumen

**Estado Actual:**
- ✅ Street: Offline 100% (con descarga proactiva)
- ✅ Vector: Offline 100% (3 MB, archivo local)
- ⚠️ Satellite: Offline parcial (caché oportunista - solo áreas visitadas)
- ⚠️ Hybrid: Offline parcial (caché oportunista - solo áreas visitadas)

**Caché Satelital:**
- ✅ Implementado con FMTC (feb 2026)
- ✅ Guarda automáticamente lo que navegas
- ✅ Funciona offline en áreas ya visitadas
- ⚠️ Necesita internet para áreas nuevas
- 📊 Tamaño típico: 50-500 MB (crece con uso)

**Navegabilidad:**
- ✅ Controles de zoom visibles
- ✅ Indicador de zoom en tiempo real
- ✅ Brújula cuando hay rotación
- ✅ Botón "Home" para resetear
- ✅ Gestos completos habilitados

**Mejoras Futuras Opcionales:**
- 📝 UI para gestionar caché satellite (ver tamaño, limpiar)
- 📝 Mensaje "Viewing cached imagery" cuando offline
- 📚 Documentar caché oportunista en help/FAQ

---

**Actualizado:** 2026-02-17 (PMTiles HD zoom 15 + ESRI zoom 19 configurados)

---

## 🗺️ Generar PMTiles HD (Vector Zoom 15)

El archivo `galapagos_hd.pmtiles` se genera con **Planetiler** y se sube a Supabase Storage.
Zoom 15 es el máximo soportado por Planetiler (límite duro en `PlanetilerConfig.java`).

### Requisitos

- Java 11+ instalado (`java -version`)
- ~2 GB de espacio en disco (datos temporales)
- ~1.5 GB de RAM libre (se usa `-Xmx6g`)
- Conexión a internet para descargar datos (~1.3 GB globales)

### Archivos necesarios (ya descargados)

```
/tmp/galapagos_tiles/
├── planetiler.jar         # ~89 MB - Planetiler v0.8+
├── ecuador.osm.pbf        # ~113 MB - Datos OSM de Ecuador/Galápagos
└── data/
    └── lake_centerline.shp.zip   # ~77 MB - Centroides de lagos
```

Si no existen, descargar:
```bash
# Planetiler JAR
curl -L -o /tmp/galapagos_tiles/planetiler.jar \
  "https://github.com/onthegomap/planetiler/releases/latest/download/planetiler.jar"

# Ecuador OSM (incluye Galápagos)
curl -L -o /tmp/galapagos_tiles/ecuador.osm.pbf \
  "https://download.geofabrik.de/south-america/ecuador-latest.osm.pbf"
```

### Paso 1 — Generar PMTiles

Abrir terminal **fuera de Claude Code** y ejecutar:

```bash
java -Xmx6g -jar /tmp/galapagos_tiles/planetiler.jar \
  --osm-path=/tmp/galapagos_tiles/ecuador.osm.pbf \
  --bounds=-92.2,-1.8,-89.0,0.9 \
  --maxzoom=15 \
  --download \
  --download-dir=/tmp/galapagos_tiles/data \
  --output=/tmp/galapagos_tiles/galapagos_hd.pmtiles
```

> **Tiempo estimado:** 60-90 minutos (mayor parte en descarga de datos globales).
> Los datos globales (`water_polygons` ~900 MB, `natural_earth` ~430 MB) se descargan una sola vez y quedan en `data/`.

### Paso 2 — Verificar resultado

```bash
ls -lh /tmp/galapagos_tiles/galapagos_hd.pmtiles
# Esperado: 10-30 MB
```

### Paso 3 — Subir a Supabase Storage

```bash
# Obtener SERVICE_ROLE_KEY del .env
SERVICE_KEY=$(grep SUPABASE_SERVICE_ROLE_KEY /Users/elmers/Documents/develop/2026/life/.env | cut -d'=' -f2)

curl -X PUT \
  "https://pxkopudkwqysfdeprmke.supabase.co/storage/v1/object/map-tiles/galapagos_hd.pmtiles" \
  -H "Authorization: Bearer $SERVICE_KEY" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @/tmp/galapagos_tiles/galapagos_hd.pmtiles
```

### Paso 4 — Verificar en Supabase

```bash
curl -sI "https://pxkopudkwqysfdeprmke.supabase.co/storage/v1/object/public/map-tiles/galapagos_hd.pmtiles" \
  | grep content-length
# Debe mostrar el tamaño nuevo (10-30 MB), no 3013370 (2.9 MB del temporal)
```

### Notas

- El bucket `map-tiles` en Supabase es **público** — no requiere auth para leer
- El app descarga el archivo automáticamente en background al tocar "Descargar Mapa HD"
- El archivo temporal actual (2.9 MB, zoom 0-14) funciona pero sin detalle en zoom 13-15
- Después de subir el nuevo archivo, los usuarios que ya descargaron el temporal
  deben eliminarlo desde Settings → el app lo re-descargará automáticamente
