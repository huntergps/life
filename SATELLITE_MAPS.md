# 🛰️ Mapas Satelitales GRATUITOS

La app usa **ESRI World Imagery** - imágenes satelitales gratuitas de alta resolución.

## ✅ Proveedor: ESRI ArcGIS (100% GRATIS)

- ✅ **SIN token** - Funciona sin configuración
- ✅ **SIN límites** - Uso ilimitado
- ✅ **Alta calidad** - Zoom hasta nivel 19
- ✅ **Cobertura Galápagos** - Excelente
- ✅ **Uso comercial** - Permitido

## 🗺️ 4 Modos de Mapa

1. **Street** - OpenStreetMap (gratis, offline 100%)
2. **Vector** - PMTiles vectoriales (gratis, offline 100%, 3 MB)
3. **Satellite** 🔒 - ESRI imágenes satelitales (requiere login, caché oportunista)
4. **Hybrid** 🔒 - Satellite + etiquetas (requiere login, caché oportunista)

### 💾 Caché Oportunista (Satellite/Hybrid)

A partir de feb 2026, los modos Satellite/Hybrid usan caché persistente:

- ✅ **Caché automático**: Todo lo que navegas se guarda en disco
- ✅ **Funciona offline**: En áreas ya visitadas (parcial)
- ✅ **Tamaño controlado**: Solo guarda lo que viste (~50-500 MB)
- ⚠️ **No es 100% offline**: Áreas nuevas necesitan internet

Es como Google Maps offline: funciona en áreas que ya exploraste.

## 🚀 Uso

```bash
# Ejecutar la app (sin configuración adicional)
flutter run -d macos

# Login requerido para Satellite/Hybrid
# Usar: esalazargps@gmail.com / sys4dm1n
```

**Eso es todo!** No necesitas token de Mapbox ni ninguna configuración. 🎉

## 📊 Detalles Técnicos

- **Proveedor**: ESRI ArcGIS Online
- **URL**: https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer
- **Max Zoom**: 19 (nativo)
- **Formato**: JPEG
- **Licencia**: Uso libre (comercial y no comercial)

## 🔧 Opcional: Usar Mapbox

Si prefieres Mapbox, descomenta el código en:
`lib/core/constants/mapbox_constants.dart`

Token gratis en: https://account.mapbox.com (200k tiles/mes)

---

**Actualizado**: 2026-02-16
