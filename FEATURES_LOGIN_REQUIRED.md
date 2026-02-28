# Características que Requieren Login - Verificación Completa

Este documento lista todas las funcionalidades de la app que requieren que el usuario esté registrado y haya iniciado sesión.

## ✅ Características Implementadas con Autenticación

### 1. 🗺️ **Mapas Satelitales (Satellite & Hybrid)**

**Ubicación**: Pantalla de Mapa → Icono de layers → Selector de modo

**Verificación de Auth**:
```dart
// lib/features/map/presentation/widgets/map_mode_selector.dart:15
final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
```

**Comportamiento**:

**Usuario NO logueado:**
- ❌ Modos "Satellite" y "Hybrid" muestran icono 🔒
- ❌ Al tocar: SnackBar con mensaje "Requiere iniciar sesión para mapas satelitales"
- ✅ Modos "Street" y "Vector" funcionan normalmente

**Usuario logueado:**
- ✅ Todos los 4 modos disponibles (Street, Vector, Satellite, Hybrid)
- ✅ Sin icono 🔒 en Satellite y Hybrid
- ✅ Puede cambiar entre todos los modos libremente

**Cómo Verificar:**
1. **Sin login:**
   ```bash
   flutter run -d macos --dart-define=MAPBOX_ACCESS_TOKEN=pk.token
   ```
   - Ve a la pantalla Mapa
   - Toca el icono de layers (arriba derecha)
   - Observa: Satellite y Hybrid tienen 🔒
   - Toca Satellite → debe mostrar mensaje de login

2. **Con login:**
   - Inicia sesión en la app (usa esalazargps@gmail.com / sys4dm1n)
   - Ve a la pantalla Mapa
   - Toca el icono de layers
   - Observa: Satellite y Hybrid SIN 🔒
   - Toca Satellite → debe cambiar el mapa a vista satelital

**Código Relevante:**
- Selector: `lib/features/map/presentation/widgets/map_mode_selector.dart` (líneas 15, 69-91, 103-125)
- Enum: `lib/features/map/providers/pmtiles_provider.dart` (líneas 32-38)
- Implementación: `lib/features/map/presentation/screens/map_screen.dart` (líneas 782-835)

---

### 2. 📚 **Información Extendida de Especies**

**Ubicación**: Detalle de Especie → Scroll hacia abajo

**Verificación de Auth**:
```dart
// lib/features/species/presentation/screens/species_detail_screen.dart:170
final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
```

**Información Restringida:**
- **Comportamiento**: Dieta, patrón de actividad, estructura social, fuentes de alimento
- **Reproducción**: Temporada de reproducción, tamaño de camada, frecuencia reproductiva
- **Características Distintivas**: Rasgos identificativos (ES/EN), dimorfismo sexual
- **Rango Geográfico**: Altitud mín/máx, profundidad mín/máx (especies marinas)
- **IDs Externos**: GBIF, EOL, IUCN Assessment URL
- **Multimedia**: URLs de sonidos/videos

**Comportamiento**:

**Usuario NO logueado:**
- ✅ Ve: Nombre común, nombre científico, badges (conservación, endémico)
- ✅ Ve: Árbol taxonómico, quick facts (peso, tamaño, población, esperanza de vida)
- ✅ Ve: Descripción básica, hábitat
- ❌ NO ve: Información extendida
- 🔔 Ve: Card de login con mensaje atractivo:
  - Icono 🔒 grande
  - Título: "Información Detallada" / "Detailed Information"
  - Mensaje: "Regístrate para acceder a datos científicos completos sobre comportamiento, reproducción y características distintivas de esta especie"
  - Botón: "Iniciar Sesión" → navega a /auth

**Usuario logueado:**
- ✅ Ve TODO lo anterior +
- ✅ Ve: Sección "Comportamiento" (si tiene datos)
- ✅ Ve: Sección "Reproducción" (si tiene datos)
- ✅ Ve: Sección "Características Distintivas" (si tiene datos)
- ✅ Ve: Sección "Rango Geográfico" (si tiene datos)
- ❌ NO ve: Card de login

**Cómo Verificar:**
1. **Sin login:**
   ```bash
   flutter run -d macos
   ```
   - Ve a cualquier especie (ej: Galápagos Tortoise)
   - Scroll hasta el final de la descripción
   - Observa: Card azul con 🔒 "Información Detallada"
   - Toca "Iniciar Sesión" → debe navegar a pantalla de auth

2. **Con login:**
   - Inicia sesión
   - Ve a la misma especie
   - Scroll hacia abajo
   - Observa: Secciones adicionales con datos (Comportamiento, Reproducción, etc.)
   - NO debe aparecer el card de login

**Código Relevante:**
- Verificación: `species_detail_screen.dart:170, 252`
- Info extendida: `species_detail_screen.dart:258-330` (método `_buildExtendedInfo`)
- Login prompt: `species_detail_screen.dart:332-380` (método `_buildLoginPrompt`)

---

### 3. ❤️ **Sistema de Favoritos**

**Ubicación**: Cards de especies, detalle de especie, pantalla de favoritos

**Verificación de Auth**:
```dart
// lib/core/widgets/favorite_heart_button.dart:59
final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
```

**Comportamiento**:

**Usuario NO logueado:**
- ❌ NO ve: Botón de corazón en ningún lugar
- ❌ NO puede: Agregar/quitar favoritos
- ❌ Pantalla Favoritos: Muestra mensaje "Inicia sesión para guardar favoritos"

**Usuario logueado:**
- ✅ Ve: Botón de corazón ❤️ en todas las species cards
- ✅ Ve: Botón de corazón ❤️ en detalle de especie
- ✅ Puede: Tocar para agregar/quitar de favoritos
- ✅ Ve: Animación de corazones al tocar (burbujas entrando/saliendo)
- ✅ Pantalla Favoritos: Muestra lista de especies favoritas

**Cómo Verificar:**
1. **Sin login:**
   - Ve a la pantalla de Species
   - Observa: NO aparece el botón de corazón en los cards
   - Ve a detalle de especie
   - Observa: NO aparece el botón de corazón
   - Ve a la pantalla Favorites
   - Observa: Mensaje de login requerido

2. **Con login:**
   - Inicia sesión
   - Ve a la pantalla de Species
   - Observa: Botón de corazón en esquina superior derecha de cada card
   - Toca el corazón → debe llenarse de rojo y mostrar animación de corazones
   - Ve a detalle de especie
   - Observa: Botón de corazón (más grande) en la imagen principal
   - Ve a Favorites
   - Observa: Lista de especies marcadas como favoritas

**Código Relevante:**
- Widget: `lib/core/widgets/favorite_heart_button.dart:59-60`
- Provider: `lib/features/favorites/providers/favorites_provider.dart:16, 28`
- Animación: `lib/core/widgets/heart_bubble_overlay.dart`

---

### 4. 📸 **Sistema de Avistamientos (Sightings)**

**Ubicación**: Pantalla Sightings, botón "+" para agregar

**Verificación de Auth**:
```dart
// lib/features/sightings/providers/sightings_provider.dart:10
final user = Supabase.instance.client.auth.currentUser;
```

**Comportamiento**:

**Usuario NO logueado:**
- ❌ NO puede: Ver la pantalla de sightings
- ❌ NO puede: Agregar avistamientos
- ℹ️ Redirige a login si intenta acceder

**Usuario logueado:**
- ✅ Ve: Pantalla "My Sightings" con lista de avistamientos propios
- ✅ Puede: Agregar nuevos avistamientos con foto, ubicación, fecha, notas
- ✅ Ve: Sus avistamientos en el mapa (marcadores teal 🎥)
- ✅ Puede: Ver estadísticas de avistamientos en su perfil

**Cómo Verificar:**
1. **Sin login:**
   - Intenta navegar a /sightings
   - Debe redirigir a pantalla de login

2. **Con login:**
   - Ve a la pantalla Sightings (ícono de cámara en bottom nav)
   - Toca el botón "+" para agregar avistamiento
   - Selecciona especie, sitio, agrega foto y notas
   - Guarda → debe aparecer en la lista
   - Ve al mapa → debe aparecer como marcador teal

**Código Relevante:**
- Provider: `lib/features/sightings/providers/sightings_provider.dart:10`
- Guard: `lib/core/router/app_router.dart:25` (redirect to /auth)

---

### 5. 👤 **Perfil y Estadísticas de Usuario**

**Ubicación**: Pantalla Profile

**Verificación de Auth**:
```dart
// lib/features/profile/presentation/screens/profile_screen.dart:368
final user = Supabase.instance.client.auth.currentUser;
```

**Comportamiento**:

**Usuario NO logueado:**
- ❌ NO puede: Ver la pantalla de perfil
- ℹ️ Redirige a login si intenta acceder

**Usuario logueado:**
- ✅ Ve: Avatar, nombre, email
- ✅ Ve: Estadísticas (total sightings, especies vistas, favoritos)
- ✅ Ve: Leaderboard position
- ✅ Puede: Editar perfil, cambiar avatar, cambiar contraseña
- ✅ Puede: Configurar preferencias (idioma, tema)
- ✅ Puede: Cerrar sesión

**Cómo Verificar:**
1. **Sin login:**
   - Intenta navegar a /profile
   - Debe redirigir a pantalla de login

2. **Con login:**
   - Ve a la pantalla Profile (ícono de usuario en bottom nav)
   - Observa: Avatar, nombre, estadísticas
   - Toca "Edit Profile" → debe permitir editar
   - Scroll → debe mostrar leaderboard

**Código Relevante:**
- Screen: `lib/features/profile/presentation/screens/profile_screen.dart:368-1459`
- Guard: `lib/core/router/app_router.dart:25`

---

## 🔧 Cómo Probar el Sistema de Autenticación

### Setup Inicial
```bash
# 1. Ejecutar la app
flutter run -d macos --dart-define=MAPBOX_ACCESS_TOKEN=pk.token

# 2. Cuenta de prueba (ya existe en Supabase)
Email: esalazargps@gmail.com
Password: sys4dm1n
```

### Test Plan Completo

#### Test 1: Usuario No Logueado
- [ ] Abrir la app sin login
- [ ] Ver pantalla Species → NO debe haber botones de corazón
- [ ] Abrir detalle de especie → NO debe haber botón de corazón
- [ ] Scroll en detalle → debe aparecer card de "Información Detallada" con 🔒
- [ ] Ir a Mapa → abrir selector de modos
- [ ] Verificar: Satellite y Hybrid tienen 🔒
- [ ] Tocar Satellite → debe mostrar SnackBar "Requiere iniciar sesión"
- [ ] Ir a Favorites → debe mostrar mensaje de login
- [ ] Intentar ir a Sightings → debe redirigir a login
- [ ] Intentar ir a Profile → debe redirigir a login

#### Test 2: Proceso de Login
- [ ] Tocar "Iniciar Sesión" desde cualquier card de login
- [ ] Verificar navegación a /auth
- [ ] Ingresar credenciales: esalazargps@gmail.com / sys4dm1n
- [ ] Tocar "Sign In"
- [ ] Verificar: Redirige a pantalla anterior o home

#### Test 3: Usuario Logueado
- [ ] Ver pantalla Species → debe haber botones ❤️ en todos los cards
- [ ] Tocar un corazón → debe llenarse y mostrar animación de burbujas
- [ ] Abrir detalle de especie → debe haber botón ❤️ grande en la imagen
- [ ] Scroll en detalle → NO debe aparecer card de login
- [ ] Scroll más → deben aparecer secciones "Comportamiento", "Reproducción", etc.
- [ ] Ir a Mapa → abrir selector de modos
- [ ] Verificar: Satellite y Hybrid SIN 🔒
- [ ] Tocar Satellite → debe cambiar el mapa a vista satelital
- [ ] Tocar Hybrid → debe cambiar a satelital con labels
- [ ] Ir a Favorites → debe mostrar lista de favoritos (vacía o con especies)
- [ ] Ir a Sightings → debe mostrar pantalla de sightings
- [ ] Tocar "+" → debe permitir agregar nuevo sighting
- [ ] Ir a Profile → debe mostrar perfil completo con estadísticas

#### Test 4: Logout
- [ ] Ir a Profile
- [ ] Scroll hasta abajo
- [ ] Tocar "Cerrar Sesión"
- [ ] Verificar: Redirige a /auth
- [ ] Volver a Species → botones ❤️ deben desaparecer
- [ ] Abrir detalle → debe aparecer card de "Información Detallada"

---

## 🐛 Troubleshooting

### Problema: "Satellite no funciona incluso con login"
**Solución**: Verificar que ejecutaste con el token de Mapbox:
```bash
flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.token
```

### Problema: "Información extendida no aparece con login"
**Solución**:
1. Verificar que la especie tiene datos en esos campos
2. Ejecutar migración: `supabase/migrations/20260216120000_add_extended_species_fields.sql`
3. Verificar en Supabase que los campos existen

### Problema: "Botón de corazón no aparece con login"
**Solución**:
1. Verificar en consola: `Supabase.instance.client.auth.currentUser`
2. Debe retornar un objeto User, no null
3. Hacer hot restart (no hot reload)

### Problema: "Siempre me redirige a login"
**Solución**:
1. Verificar que el token de Supabase en `.env` es correcto
2. Verificar conexión a internet
3. Revisar logs de Supabase Auth en el dashboard

---

## 📊 Resumen de Verificación de Auth

| Característica | Ubicación | Auth Check | Sin Login | Con Login |
|---|---|---|---|---|
| **Mapas Satelitales** | `map_mode_selector.dart:15` | ✅ | 🔒 Bloqueado | ✅ Disponible |
| **Info Extendida Especies** | `species_detail_screen.dart:170` | ✅ | 🔒 Card de login | ✅ Secciones completas |
| **Favoritos** | `favorite_heart_button.dart:59` | ✅ | ❌ Oculto | ✅ Visible + funcional |
| **Avistamientos** | `sightings_provider.dart:10` | ✅ | ↩️ Redirect | ✅ Acceso completo |
| **Perfil** | `profile_screen.dart:368` | ✅ | ↩️ Redirect | ✅ Acceso completo |

---

## ✅ Checklist de Implementación

- [x] MapTileMode enum ampliado (street, vector, satellite, hybrid)
- [x] MapModeSelector con verificación de auth
- [x] Species detail con información extendida restringida
- [x] Login prompt atractivo en species detail
- [x] FavoriteHeartButton solo visible para usuarios logueados
- [x] Router guards para sightings y profile
- [x] Traducciones ES/EN para todos los mensajes
- [x] Mapbox constants con token configurable
- [x] Documentación completa (MAPBOX_SETUP.md)
- [x] Memoria del proyecto actualizada

**Estado**: ✅ Todas las características implementadas y verificadas

---

## 📝 Notas para el Usuario

1. **Siempre usar `--dart-define`** para el token de Mapbox en desarrollo
2. **Hot restart** (no hot reload) después de login para actualizar UI
3. **Admin account** también es usuario regular con acceso a todas las features
4. **RLS policies** protegen los datos en Supabase (favorites, sightings solo del usuario)
5. **Offline mode**: Favoritos y extended info requieren conexión inicial para sincronizar

---

Última actualización: 2026-02-16
