# Análisis de monetización — Galápagos Wildlife

## Comparación: Deep Research Report vs Estado Real del Producto

### Donde el reporte acierta

1. **Modelo híbrido B2C + B2B es correcto.** El mercado de ~300K turistas/año en Galápagos sí justifica un canal turista (pago por viaje) + un canal enterprise (operadores, PNG, guías).

2. **"Offline es el hook" — 100% correcto.** La app ya tiene offline-first real: 131 especies, 891 sitios, mapa PMTiles, todo en SQLite local después del primer sync. Esto es diferenciador real vs competidores como iNaturalist que requieren conexión.

3. **Precio de referencia US$14.99 es viable.** Ya existe precedente (Galapagos Wildlife Guide). Nuestra app ofrece significativamente más: IA, mapas, sightings, gamificación.

4. **No fragmentar en múltiples apps — correcto.** La arquitectura actual ya soporta modos (turista/guía/admin) con roles en Supabase.

5. **El backoffice editorial es diferenciador real para B2B.** Tenemos 15 pantallas admin + workflow editorial completo (propuestas → curador → admin). Esto no lo tiene ningún competidor local.

### Donde el reporte es optimista vs la realidad

| Lo que asume el reporte | Estado real |
|---|---|
| IA de identificación funcional | Solo cubre 39 de 131 especies (30%). MobileNetV3Small de 2.1 MB |
| Sound ID | NO existe. Solo es lookup por GPS+hora. No hay modelo de audio |
| AR Camera (YOLO) | Solo pantalla placeholder. No hay modelo YOLO |
| Mapas offline listos | Funcional pero detrás de flag beta. PMTiles de solo 2.9 MB |
| "Pack Galápagos Offline" vendible | Falta: account deletion, privacy policy, Apple Sign-In, App Store listing |
| Relación especies↔sitios | La tabla `species_sites` tiene 1 fila de 891×131 posibles |
| Base de usuarios para A/B testing | 5 usuarios registrados |

### Lo que falta ANTES de poder vender

**Bloqueantes para App Store / Google Play:**
1. ❌ Account deletion flow (requerido por Apple y Google)
2. ❌ Privacy policy (URL no configurada, no visible en app)
3. ❌ Terms of Service
4. ❌ Apple Sign-In (recomendado si no hay social login; obligatorio si lo agregas)

**Bloqueantes para que el producto tenga valor vendible:**
5. ❌ `species_sites` table poblada (sin esto, "qué puedo ver aquí" no funciona)
6. ❌ 10 especies sin imágenes
7. ❌ Sound ID real (BirdNET-Lite) o eliminarlo del marketing
8. ❌ AI cubre solo 30% de especies → entrenar modelo con más clases

---

## Mi estrategia recomendada

### Fase 0 — Store-Ready (1-2 semanas)
Sin esto no puedes publicar en stores ni cobrar.

- [ ] Implementar account deletion (Settings → Delete Account → confirmación → Supabase delete)
- [ ] Privacy policy page (web URL + link en app)
- [ ] Terms of Service page
- [ ] Poblar `species_sites` (script que cruza datos de PNG con especies por isla/sitio)
- [ ] Agregar imágenes a las 10 especies que faltan (reusar script `fetch_spider_images.dart`)
- [ ] App Store metadata (descripción, screenshots, keywords)

### Fase 1 — Lanzamiento Free (mes 1-2)
Lanzar gratis para validar tracción y recoger métricas.

**Lo que se ofrece gratis:**
- Catálogo completo de 131 especies (offline)
- Búsqueda y favoritos
- Sightings con foto+GPS
- Badges y leaderboard
- Bilingüe ES/EN

**Lo que queda como preview/teaser:**
- Photo ID: permitir 3 identificaciones/día gratis (ya funciona con 39 spp)
- Mapa: mostrar versión limitada (solo islas, sin sitios ni trails)

**Métricas a trackear:**
- Descargas por semana
- % que completa onboarding
- % que registra cuenta
- % que usa Photo ID
- Retención D1, D7, D30

### Fase 2 — Pack Galápagos (mes 3-4) — US$9.99 one-time
**Incluye:**
- Mapa completo offline (891 sitios + 43 trails + capas)
- Photo ID ilimitado
- Checklist de especies por sitio ("qué puedo ver aquí")
- Export CSV de sightings

**Implementación:** In-App Purchase (StoreKit 2 / Google Billing). Una sola compra, acceso permanente.

### Fase 3 — Suscripción Pro (mes 5-6) — US$3.99/mes o US$29.99/año
Para guías, naturalistas recurrentes, residentes.

**Incluye todo del Pack +:**
- IA mejorada (modelo más grande, más especies)
- Sound ID cuando esté listo
- Mapas satellite offline (cache extendido)
- Priority sync
- Export GeoJSON

### Enterprise (futuro — no implementado aún)
Requiere features que no existen: calendario, reservas, gestión de guías, facturación.
Se evaluará cuando haya tracción demostrada y demanda real de operadores.

---

## Pricing comparativo

| Tier | Precio | Benchmark |
|---|---|---|
| Free | $0 | Merlin, Seek, iNaturalist |
| Pack Galápagos | $9.99 one-time IAP | Galápagos Wildlife Guide ($14.99) |
| Pro | $29.99/año suscripción IAP | AllTrails ($35.99/año), más barato por ser destino único |

---

## Ventaja competitiva real

Lo que NINGÚN competidor actual ofrece juntos:

1. **Offline-first REAL** (no "offline parcial" como iNaturalist)
2. **IA on-device** (no requiere conexión, a diferencia de iNaturalist/Seek que necesitan server)
3. **Backoffice editorial completo** (ninguna app de fauna tiene esto)
4. **Bilingüe nativo** (ES/EN, crítico para Galápagos donde ~50% son hispanohablantes)
5. **Datos oficiales del PNG** (891 sitios, no crowdsourced)
6. **Mapas vectoriales offline** (PMTiles, no tiles raster pesados)
7. **Gamificación** (badges, leaderboard — engancha al turista casual)

---

## Riesgos principales

1. **Mercado limitado a 300K turistas/año.** Conversión del 5% = 15K pagos. A $9.99 = ~$150K/año revenue. No es un negocio masivo, pero sí sostenible.

2. **Dependencia de contenido.** Si las especies no tienen buenas fotos/descripciones, el producto pierde valor. Necesitas pipeline editorial continuo.

3. **AI de 30% cobertura.** Si el turista prueba Photo ID y no reconoce su especie, la percepción es "no funciona". Prioridad: entrenar modelo con más clases.

4. **Un solo desarrollador.** Escalar features + soporte + contenido es difícil solo.

---

## Decisión estratégica clave

**¿Vender la app o el negocio?**

| Opción | Pros | Contras |
|---|---|---|
| **Vender la tecnología (licencia)** | Ingreso inmediato. Sin operación. | Pierdes control. Precio bajo sin tracción demostrada. |
| **Vender como SaaS/producto** | Ingreso recurrente. Escalable a otros destinos. | Requiere operación, marketing, soporte. |
| **Buscar socio/inversor** | Mantener equity. Capital para crecer. | Dilución. Necesitas demostrar tracción. |
| **Licenciar al PNG/CDF** | Alineado con misión. Presupuesto institucional. | Ciclos de compra largos. Burocracia. |
| **White-label para otros parques** | Escala horizontal (otros parques nacionales). | Requiere abstraer el contenido del código. |

**Mi recomendación:** Lanzar gratis en stores → demostrar tracción → activar Pack IAP a $9.99 → con métricas reales, activar Pro suscripción a $29.99/año. Enterprise se evalúa solo cuando existan features de operación (calendario, reservas, facturación).

## Estrategia de stores

La app se publica como **gratuita con compras in-app** desde el día 1. NUNCA cambiar a "app de pago" porque:
- Pierdes rankings y reviews acumuladas
- Los usuarios existentes se sienten traicionados
- Apple y Google penalizan el cambio

**Ruta:**
1. Publicar gratis → medir descargas, retención, uso de features
2. Activar IAP Pack ($9.99 one-time) cuando haya ~1000 descargas
3. Activar IAP Pro ($29.99/año suscripción) cuando haya ~100 compradores del Pack
4. Evaluar Enterprise solo con demanda real demostrada
