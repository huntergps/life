# Arañas de Galápagos — Pendiente de implementar

## Contexto
Investigación realizada el 2026-03-03. Los datos de arañas deben agregarse a
**este proyecto** (`galapagos_wildlife`), NO a PILAR ERP.

El schema debe reutilizar las tablas geográficas ya existentes en este proyecto
en lugar de crear tablas de islas duplicadas.

---

## Datos investigados

### Resumen taxonómico
- **~159 especies** de arañas en Galápagos
- **~50% endémicas**, 26% continentales, 24% cosmopolitas
- Fuente principal: Baert et al. 2023 — *Belgian Journal of Entomology*
- dataZone Darwin Foundation: https://datazone.darwinfoundation.org/en/checklist/

---

## Especies documentadas (18)

### Familia Lycosidae — Arañas lobo (género *Hogna*) — 7 endémicas
| Especie | Autor | Hábitat | Islas |
|---------|-------|---------|-------|
| *Hogna galapagoensis* | Banks, 1902 | Pampa / húmedo alto > 400 m | Santa Cruz, Isabela |
| *Hogna albemarlensis* | Banks, 1902 | Costa húmeda, salina | Fernandina, Santiago |
| *Hogna snodgrassi* | Banks, 1902 | Árida costera, dunas, Opuntia | San Cristóbal, Española, Santa Fe |
| *Hogna jacquesbreli* | — | Zona seca | Varias |
| *Hogna junco* | — | Transición árido-húmedo | Varias |
| *Hogna española* | — | Árida costera | Española |
| *Hogna hendrickxi* | — | Pampa húmeda | Varias |

**Tamaños**: hembra 11–16 mm / macho 8–12 mm. Cazadoras terrestres, sin tela.
Ojos en 3 filas (4-2-2). Hembras cargan saco de huevos y crías sobre el abdomen.
Ref: Baert et al. 2020 — *Parallel phenotypic evolution*

### Familia Araneidae — Orb-weavers
| Especie | Estado | Distribución | Tamaño hembra |
|---------|--------|--------------|---------------|
| *Argiope argentata* (Fabricius, 1775) | Nativa | Todas las islas | 10–15 mm |
| *Metepeira desenderi* | Endémica | Varias | 6–9 mm |
| *Cyclosa turbinata* (Walckenaer, 1841) | Nativa | Varias | 3.5–5.5 mm |

*Argiope argentata*: estabilimento zigzag blanco en tela, abdomen plateado,
patas en X al reposar. dataZone ID: 5553. iNaturalist ID: 47208.

### Familia Theridiidae
| Especie | Estado | Notas |
|---------|--------|-------|
| *Latrodectus apicalis* (Butler, 1877) | **Endémica** | Única viuda negra de Galápagos. Abdomen globoso negro, marcas rojas ventrales. Veneno neurotóxico — sin registros de mordidas. |

### Familia Sparassidae
| Especie | Estado | Notas |
|---------|--------|-------|
| *Heteropoda venatoria* (Linnaeus, 1767) | Introducida | Hasta 9 cm de envergadura. Frecuente en hoteles. iNaturalist: 51885 |

### Familia Pholcidae — Arañas de cueva (género *Metagonia*) — 3 endémicas 2022
| Especie | Isla | Tamaño | Nota especial |
|---------|------|--------|---------------|
| *Metagonia bellavista* (2022) | Santa Cruz | 1.5–2.5 mm | Cuevas de lava |
| *Metagonia reederi* (2022) | Isabela | 1.5–2.5 mm | Cuevas de lava |
| *Metagonia zatoichi* (2022) | Santa Cruz | **0.8–0.9 mm** | Ciega, sin pigmentación — la más pequeña de su familia en el mundo |

Ref: Baert et al. 2022 — *new cave species Galápagos*

### Familia Desidae — Género *Galapa* (endémico exclusivo Galápagos)
| Especie | Isla principal |
|---------|---------------|
| *Galapa baerti* | Varias |
| *Galapa bella* | Varias |
| *Galapa floreana* | Floreana |

Solo 3 especies conocidas en el mundo entero. Género exclusivo del archipiélago.

---

## Caracteres de identificación documentados

| Especie | Caracteres clave | Distinguir de |
|---------|-----------------|---------------|
| *Hogna galapagoensis* | Ojos 3 filas; carga huevos; sin tela; pampa alta | Otras Hogna — más contrastada y en altura |
| *Hogna snodgrassi* | La más pálida; dunas y cactus; islas antiguas | H. albemarlensis — esta es costera húmeda |
| *Argiope argentata* | Estabilimento zigzag blanco; abdomen plateado; patas en X | Inconfundible en Galápagos |
| *Latrodectus apicalis* | Abdomen esférico negro brillante; marcas rojas ventrales | Inconfundible |
| *Heteropoda venatoria* | Hasta 9 cm envergadura; plana; sin tela; en edificios | La más grande del archipiélago |
| *Metagonia zatoichi* | 0.8 mm; ciega; transparente; solo cuevas | M. bellavista/reederi — esas son más grandes |

---

## Schema a implementar en este proyecto

### Decisión clave: reutilizar tablas existentes
- **NO crear tabla de islas nueva** — revisar si ya existe en el schema actual
- Las islas ya deben estar en la tabla geográfica del proyecto
- Verificar antes de crear cualquier tabla: `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`

### Tablas nuevas propuestas (prefijo `bio_`)
```
bio_ordenes          — Araneae, Coleoptera, etc.
bio_familias         — Lycosidae, Araneidae, etc.
bio_generos          — Hogna, Argiope, etc.
bio_especies         — especie completa con morfología
bio_distribucion     — especie ↔ localidad/isla (FK a tabla geográfica existente)
bio_caracteres       — rasgos diagnósticos para identificación (1:1 con especie)
bio_imagenes         — fotos de referencia por especie
bio_observaciones    — registros ciudadanos
bio_observacion_fotos— fotos de observaciones
```

### Columnas clave de `bio_especies`
```sql
epiteto, nombre_cientifico, autor, anio_descripcion
nombre_comun_es, nombre_comun_en
estado_origen: 'endemica' | 'nativa' | 'introducida' | 'cosmopolita'
estado_conservacion: IUCN (EX/EW/CR/EN/VU/NT/LC/DD/NE)
descripcion, habitat, comportamiento, dieta
tamanio_hembra_min_mm, tamanio_hembra_max_mm (DECIMAL 5,1)
tamanio_macho_min_mm,  tamanio_macho_max_mm  (DECIMAL 5,1)
activa_noche BOOLEAN
teje_telarana BOOLEAN
tipo_telarana: 'orbicular' | 'cobweb' | 'irregular' | 'embudo' | null
venenosa_humanos BOOLEAN
datazone_id INTEGER       -- Darwin Foundation
inaturalist_taxon_id INTEGER
gbif_taxon_id BIGINT
```

### RLS
- Catálogo (`bio_ordenes` … `bio_imagenes`): **lectura pública** (anon + authenticated)
- Observaciones: lectura pública, INSERT/UPDATE solo authenticated (propio registro)

---

## Próximos pasos

1. [ ] Revisar schema actual del proyecto (`supabase/migrations/`) para no duplicar
2. [ ] Identificar tabla geográfica de islas/sitios ya existente
3. [ ] Crear migración `bio_taxonomia` (ordenes → familias → generos → especies)
4. [ ] Crear migración `bio_distribucion` referenciando tabla geográfica existente
5. [ ] Crear migración `bio_caracteres` + `bio_imagenes`
6. [ ] Crear migración `bio_observaciones` + `bio_observacion_fotos`
7. [ ] Seed data arañas (18 especies documentadas arriba)
8. [ ] Repetir para siguiente grupo taxonómico
