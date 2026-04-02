# Soporte por Plataforma — Galápagos Wildlife

## Leyenda
- ✅ Funciona completamente
- ✅ᶠ Funciona con fallback (resultado parcial pero funcional)
- ✅ᵇ Funciona vía cache del navegador (no plugin nativo)
- ⚠️ Limitado
- ❌ No disponible (limitación de hardware/plataforma)

## Matriz de features

| Feature | iOS | Android | macOS | Win | Linux | Web |
|---|---|---|---|---|---|---|
| **CORE** |||||||
| Base de datos local (Drift/SQLite) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Offline queue + sync automático | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Supabase (Auth, Storage, Realtime) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Bilingüe ES/EN | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Tema claro/oscuro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| GPS/Ubicación | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **CATÁLOGO** |||||||
| 131 especies + detalle completo | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Búsqueda global | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Favoritos | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Checklist (25 sugeridas + todas) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Reproducción de sonidos | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Daily Facts | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **MAPA** |||||||
| Mapa interactivo (flutter_map) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Mapa base vectorial (PMTiles) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 891 sitios + 43 senderos | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Cache de tiles offline | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ᵇ |
| GPS tracking de senderos | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Ubicación del usuario en mapa | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Descarga de mapas HD | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **IA E IDENTIFICACIÓN** |||||||
| Photo ID (seleccionar foto → IA) | ✅ | ✅ | ✅ | ✅ᶠ | ✅ᶠ | ✅ᶠ |
| AR Camera (detección tiempo real) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Fallback por ubicación GPS | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **AVISTAMIENTOS** |||||||
| Crear sighting (manual) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Adjuntar foto (cámara o archivo) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| GPS automático en sighting | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Export CSV | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Edición de campo (trails/sites) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Grabación de audio | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ❌ |
| **GAMIFICACIÓN** |||||||
| Badges (10 logros) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Leaderboard | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Celebración confetti al completar | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Certificado digital por email | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **COMPRAS** |||||||
| In-App Purchase (Pack/Pro) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Acceso premium por rol (server) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **ADMIN Y EDITORIAL** |||||||
| Panel admin (15 pantallas) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| CRUD especies/sitios/islas | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Gestión usuarios y roles | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Asignación beta/sponsored con fecha | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Workflow editorial | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **DISTRIBUCIÓN** |||||||
| Shorebird OTA patches | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Apple Watch companion | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| GitHub Pages auto-deploy | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

## Notas

### ✅ᶠ Photo ID con fallback
En iOS/Android/macOS el modelo TFLite (2.1 MB, MobileNetV3) corre on-device y clasifica la foto directamente. En Windows, Linux y Web, TFLite no está disponible — la app sugiere especies basándose en la ubicación GPS del usuario (sitio de visita más cercano + especies asociadas). El usuario siempre obtiene una respuesta útil.

### ✅ᵇ Cache de tiles en Web
FMTC (plugin nativo de cache) no funciona en web. Sin embargo, los tiles del mapa se cachean automáticamente por el **HTTP cache del navegador**. Si el usuario visitó una zona del mapa con internet, esos tiles permanecen disponibles offline en el cache del browser. Además, el **mapa base vectorial PMTiles** (2.9 MB) se carga por streaming HTTP y también se beneficia del cache del navegador. En la práctica, el mapa funciona offline en web para zonas previamente visitadas.

### ❌ Brechas irreducibles
| Brecha | Razón |
|---|---|
| AR Camera en web/desktop | Requiere stream de cámara nativo a nivel de frame — la Web API no lo soporta con la resolución y velocidad necesarias |
| In-App Purchase en web/desktop | Apple y Google IAP solo funcionan en sus stores móviles. En web/desktop el acceso premium se otorga vía roles (sponsored/editor/curator) |
| Apple Watch | Hardware exclusivo de Apple, protocolo WCSession solo disponible en iOS |
| Shorebird en web | No aplica — web siempre sirve la versión más reciente desde GitHub Pages automáticamente |
| Descarga de mapas HD en web | Requiere background_downloader (filesystem nativo). El streaming HTTP con cache del browser cumple la misma función en web |
| Grabación de audio en web | El paquete `record` no soporta web. La Web MediaRecorder API existe pero no está integrada |

---

**GalapagosTech — Elmer Salazar**
