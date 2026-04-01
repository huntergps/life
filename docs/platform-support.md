# Soporte por Plataforma — Galápagos Wildlife

## Matriz de features por plataforma

### Leyenda
- ✅ Funciona completamente
- ⚠️ Funciona parcialmente o con limitaciones
- ❌ No disponible en la plataforma

### Core

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Base de datos local (Drift/SQLite) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ Wasm |
| Sync offline-first (cola offline) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ Supabase directo |
| Supabase (Auth, Storage, Realtime) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| i18n (ES/EN) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Tema claro/oscuro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Catálogo y exploración

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Catálogo de 131 especies | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Detalle de especie | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Búsqueda global | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Favoritos | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Checklist | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Daily Facts | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Reproducción de sonidos | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Mapa

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Mapa interactivo (flutter_map) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Mapa base vectorial (PMTiles) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ streaming |
| Cache de tiles offline (FMTC) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Marcadores de islas/sitios | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| GPS tracking de senderos | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| Ubicación del usuario | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| Descarga de mapas HD | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

### IA e identificación

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Photo ID (TFLite on-device) | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| AR Camera (YOLO real-time) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Fallback por ubicación | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ |

### Avistamientos y campo

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Crear sighting (manual) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Foto de sighting (cámara) | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ❌ |
| GPS automático en sighting | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| Grabación de audio | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ❌ |
| Export CSV | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Edición de campo (trails/sites) | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ |

### Gamificación

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Badges | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Leaderboard | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Celebración checklist (confetti) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Certificado por email | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Compras y monetización

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| In-App Purchase (Pack/Pro) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Paywall UI | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Restaurar compras | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Roles premium (sponsored/etc) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Admin y editorial

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Panel admin | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| CRUD de especies | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Gestión de usuarios/roles | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Workflow editorial | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Actualizaciones y distribución

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Shorebird OTA patches | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Apple Watch companion | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| GitHub Pages deploy | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## Resumen por plataforma

### iOS — Plataforma principal ⭐
**Todo funciona.** Es la plataforma más completa: IA, cámara, GPS, mapas offline, Apple Watch, compras in-app, Shorebird.

### Android — Segunda plataforma ⭐
**Todo excepto Apple Watch.** Misma experiencia que iOS menos el Watch companion.

### macOS — Funcional con limitaciones
**Catálogo, búsqueda, checklist, admin, mapas.** Sin cámara real, GPS limitado, sin compras in-app. Útil para revisión de contenido y administración.

### Windows / Linux — Mínimo viable
**Catálogo, búsqueda, checklist, admin.** Sin GPS, sin cámara, sin compras. Útil para administración y editorial.

### Web — Demo y acceso rápido
**Catálogo, búsqueda, checklist, badges, admin.** Sin offline queue, sin IA, sin cámara, sin compras. Útil como demo pública y para acceso rápido desde cualquier navegador. Deployado automáticamente vía GitHub Pages.

---

## Notas técnicas

- **Web sin offline queue**: En web, los datos se leen directo de Supabase. No hay cola offline ni persistencia local robusta.
- **TFLite en web**: Se usa un stub que proporciona clases dummy para que compile. La IA no funciona en web.
- **FMTC en web**: El cache de tiles no existe en web. Los tiles se cargan por red cada vez.
- **IAP en web**: El plugin `in_app_purchase` retorna `isAvailable() = false` en web automáticamente.
- **Shorebird en web**: No aplica — la web siempre sirve la versión más reciente desde GitHub Pages.

---

**GalapagosTech — Elmer Salazar**
