# Galápagos Wildlife — Estructura y Flujos por Tier

## Tiers del producto

| Tier | Precio | Tipo | Cómo se obtiene |
|------|--------|------|-----------------|
| **Free** | $0 | Gratuito | Descarga desde App Store / Google Play |
| **Pack Galápagos** | $9.99 | Compra única (IAP) | Desde paywall dentro de la app |
| **Pro** | $29.99/año | Suscripción (IAP) | Desde paywall dentro de la app |
| **Beta Tester** | — | Rol servidor | Admin asigna en Supabase (`admin_users` table) |

> **Regla de acceso premium:** `is_beta_tester OR has_pack OR has_pro`

---

## Navegación por tier

### Free (5 tabs)
```
Home → Species → Checklist → Sightings → Settings
```

### Pack / Pro / Beta (6 tabs)
```
Home → Species → Map → Checklist → Sightings → Settings
```

> Favoritos sale del nav bar pero sigue accesible desde Species Detail y Profile.

---

## Matriz completa de features

### Catálogo y exploración

| Feature | Free | Pack | Pro |
|---------|------|------|-----|
| Catálogo de 131 especies | ✅ | ✅ | ✅ |
| Detalle de especie (fotos, taxonomía, amenazas) | ✅ | ✅ | ✅ |
| Búsqueda global | ✅ | ✅ | ✅ |
| Daily facts | ✅ | ✅ | ✅ |
| Idioma ES/EN | ✅ | ✅ | ✅ |
| Onboarding | ✅ | ✅ | ✅ |

### Checklist (gancho principal)

| Feature | Free | Pack | Pro |
|---------|------|------|-----|
| Ver lista de 25 especies sugeridas | ✅ | ✅ | ✅ |
| Ver todas las 131 especies | ✅ | ✅ | ✅ |
| Marcar especie como vista (toggle) | ✅ | ✅ | ✅ |
| Fecha+hora **capturada** al marcar | ✅ (guardado) | ✅ | ✅ |
| GPS **capturado** al marcar | ✅ (guardado) | ✅ | ✅ |
| **Ver** fecha/hora del avistamiento | ❌ → paywall | ✅ | ✅ |
| **Ver** ubicación GPS | ❌ → paywall | ✅ | ✅ |
| **Ver** foto del sighting vinculado | ❌ → paywall | ✅ | ✅ |
| Barra de progreso (X / 25) | ✅ | ✅ | ✅ |
| Filtro: sugeridas / todas / vistas / no vistas | ✅ | ✅ | ✅ |
| Celebración al completar las 25 (confetti + trofeo) | ✅ | ✅ | ✅ |
| Certificado digital por email | ✅ | ✅ | ✅ |

> **Estrategia:** El free captura todo silenciosamente. Cuando el usuario quiere ver SUS datos, ve el paywall. Esto crea motivación natural para comprar.

### Avistamientos (Sightings)

| Feature | Free | Pack | Pro |
|---------|------|------|-----|
| Crear sighting (foto + GPS + notas) | ✅ | ✅ | ✅ |
| Ver lista de sightings | ✅ | ✅ | ✅ |
| Filtrar sightings | ✅ | ✅ | ✅ |
| Auto-marcar checklist al crear sighting | ✅ | ✅ | ✅ |
| Export CSV | ❌ | ✅ | ✅ |

### Favoritos

| Feature | Free | Pack | Pro |
|---------|------|------|-----|
| Marcar/desmarcar favorito (corazón) | ✅ (con cuenta) | ✅ | ✅ |
| Ver lista de favoritos | ✅ (con cuenta) | ✅ | ✅ |

> Favoritos requiere cuenta (auth) pero NO requiere pago.

### Mapa

| Feature | Free | Pack | Pro |
|---------|------|------|-----|
| Mapa interactivo | ❌ | ✅ | ✅ |
| 891 sitios de visita oficiales (PNG) | ❌ | ✅ | ✅ |
| 43 senderos | ❌ | ✅ | ✅ |
| Marcadores de islas | ❌ | ✅ | ✅ |
| Especies por sitio ("qué ver aquí") | ❌ | ✅ | ✅ |
| Mapa base vectorial (PMTiles offline) | ❌ | ✅ | ✅ |
| Tiles OSM raster (cached) | ❌ | ✅ | ✅ |
| Mapas satellite offline | ❌ | ❌ | ✅ |
| Tracking GPS de senderos | ❌ | ✅ | ✅ |
| Edición de campo (sitios/trails) | ❌ | ✅ | ✅ |

### Identificación por IA

| Feature | Free | Pack | Pro |
|---------|------|------|-----|
| Photo ID (foto estática → IA) | ❌ | ✅ | ✅ |
| AR Camera (detección en tiempo real) | ❌ | ✅ | ✅ |
| IA mejorada (modelo más preciso) | ❌ | ❌ | ✅ |

### Gamificación

| Feature | Free | Pack | Pro |
|---------|------|------|-----|
| Badges (10 logros) | ✅ (con cuenta) | ✅ | ✅ |
| Leaderboard | ✅ (con cuenta) | ✅ | ✅ |
| Perfil de usuario | ✅ (con cuenta) | ✅ | ✅ |

### Admin / Editorial (por roles, no por pago)

| Feature | Requiere |
|---------|----------|
| Panel admin (15 pantallas) | Rol `admin` |
| Editar especies | Rol `admin` o `editor` |
| Review de propuestas | Rol `curator` o `admin` |
| Gestión de usuarios | Rol `admin` |

---

## Flujos principales

### Flujo 1: Turista casual (free)

```
Descarga app → Onboarding → Home
  → Explora catálogo de especies
  → Ve checklist sugerido (25 especies)
  → Marca "Marine Iguana" como vista ✓ (fecha+GPS capturados)
  → Toca para ver detalles → ve paywall "Pack $9.99"
  → Decide si compra o sigue marcando gratis
  → Completa las 25 → celebración con confetti 🎉
  → Recibe certificado por email 📧
```

### Flujo 2: Turista que compra Pack

```
Free user → Settings → Premium → "Pack Galápagos $9.99"
  → Apple/Google Pay → Compra exitosa
  → Tab Mapa aparece en la navegación
  → Checklist ahora muestra fecha, hora, GPS de cada marca
  → Photo ID disponible desde Home
  → Puede ver "qué especies hay en este sitio" en el mapa
```

### Flujo 3: Guía naturalista (Pro)

```
Compra Pro ($29.99/año)
  → Todo del Pack +
  → Mapas satellite offline (para zonas sin señal)
  → IA mejorada para identificación
  → Sync prioritario (datos actualizados más rápido)
```

### Flujo 4: Sighting → auto-checklist

```
Usuario crea sighting:
  1. Abre tab Sightings → "+" → toma foto
  2. Selecciona especie (o IA la identifica)
  3. GPS + fecha automáticos
  4. Guarda sighting
  5. → Auto-marca especie en checklist (si no estaba marcada)
  6. → Checklist refleja inmediatamente "12/25 vistas"
```

### Flujo 5: Completar checklist

```
Usuario marca la especie #25:
  1. Toggle check → verde ✓
  2. Provider detecta: todas las 25 sugeridas completadas
  3. → Dialog fullscreen con confetti (5 segundos)
  4. → Trofeo dorado con animación elástica
  5. → "¡Felicitaciones [nombre]!"
  6. → Botón "Compartir" (share_plus)
  7. → Botón "Obtener certificado" → RPC a Supabase → email
  8. → Botón "Cerrar"
```

### Flujo 6: Restaurar compras (nuevo dispositivo)

```
Usuario instala app en iPad:
  1. Login con email → datos sincronizan de Supabase
  2. Settings → Premium → "Restaurar compras"
  3. Apple verifica Apple ID → desbloquea Pack/Pro
  4. Navegación cambia a 6 tabs (con Mapa)
  5. Checklist muestra todas las marcas con fecha+GPS
```

---

## Diferenciación clara entre features similares

| Concepto | Favoritos ❤️ | Checklist ✓ | Sightings 📷 |
|----------|-------------|-------------|--------------|
| **Propósito** | "Me gusta esta especie" | "La he visto en persona" | "Registro completo de observación" |
| **Acción** | Toggle corazón | Toggle check | Formulario con foto+GPS+notas |
| **Datos guardados** | species_id | species_id + fecha + GPS | species_id + fecha + GPS + foto + notas + sitio |
| **Requiere auth** | Sí | Sí | Sí |
| **Requiere pago** | No | No (marcar) / Sí (ver detalles) | No |
| **Ubicación en UI** | Species detail (corazón) | Tab Checklist + species detail (check) | Tab Sightings |
| **Relación** | Independiente | Auto-marcado al crear sighting | Crea sighting → marca checklist |
| **Badge vinculado** | "Curator" (10 favs) | Celebración al completar 25 | "Explorer" (10), "Field Researcher" (50) |
| **Offline** | Sí (Supabase sync) | Sí (Supabase sync) | Sí (Drift offline-first) |

---

## Puntos de conversión (free → pago)

| Momento | Qué ve el usuario | Acción |
|---------|-------------------|--------|
| Toca especie marcada en checklist | Paywall: "Tus datos de fecha, hora y GPS están guardados. Desbloquea con Pack" | Compra Pack |
| Toca tab Mapa (si no tiene pack) | Redirige a home (mapa no visible) | — |
| Settings → Premium | Estado actual + botón "Ver planes" → paywall | Compra Pack/Pro |
| Home → Photo ID (si no tiene pack) | Botón no aparece | — |
| Completa las 25 especies | Celebración → motivación para seguir con mapa/IA | Momento emocional → compra |

---

## Datos siempre capturados (independiente del tier)

Cuando un usuario free marca una especie como vista, el sistema **siempre** registra:

```
user_species_checklist:
  - user_id: UUID
  - species_id: int
  - seen_at: timestamp (DateTime.now)
  - latitude: double (GPS, best-effort, 5s timeout)
  - longitude: double (GPS)
```

Estos datos existen en Supabase. El usuario free no los ve. Cuando compra el Pack, aparecen instantáneamente — **no necesita volver a marcar nada**.

---

## Resumen ejecutivo

```
FREE = explorar + marcar + jugar (gancho)
PACK = ver tus datos + mapa + IA (valor)
PRO  = satellite + IA mejorada + sync rápido (power user)
```

**GalapagosTech — Elmer Salazar**
