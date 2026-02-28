#!/bin/bash
# =============================================================================
# generate_pmtiles.sh
# Genera galapagos_hd.pmtiles (zoom 0-15) con Planetiler y lo sube a Supabase.
#
# Uso:
#   chmod +x bin/generate_pmtiles.sh
#   ./bin/generate_pmtiles.sh
#
# Tiempo estimado:
#   - Primera vez: 60-90 min (descarga ~1.3 GB de datos globales)
#   - Con datos ya descargados: 5-15 min (solo procesa OSM + genera tiles)
#
# Zoom 15 es el máximo soportado por Planetiler (límite duro en PlanetilerConfig.java)
# =============================================================================

set -e

# --- Colores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Configuración ---
WORK_DIR="/tmp/galapagos_tiles"
DATA_DIR="$WORK_DIR/data"
JAR="$WORK_DIR/planetiler.jar"
OSM="$WORK_DIR/ecuador.osm.pbf"
OUTPUT="$WORK_DIR/galapagos_hd.pmtiles"

SUPABASE_URL="https://pxkopudkwqysfdeprmke.supabase.co"
BUCKET="map-tiles"
REMOTE_FILE="galapagos_hd.pmtiles"

ENV_FILE="$(dirname "$0")/../.env"

BOUNDS="-92.2,-1.8,-89.0,0.9"
MAX_ZOOM=15
JAVA_MEM="-Xmx6g"

# Tamaños mínimos esperados (bytes) para validar archivos existentes
MIN_JAR=50000000        #  50 MB
MIN_OSM=100000000       # 100 MB
MIN_LAKE=70000000       #  70 MB
MIN_WATER=800000000     # 800 MB
MIN_NATURAL=400000000   # 400 MB

# =============================================================================
echo ""
echo "============================================="
echo "  Galápagos PMTiles Generator (zoom $MAX_ZOOM)"
echo "============================================="
echo ""

# --- Verificar Java ---
log "Verificando Java..."
if ! command -v java &> /dev/null; then
    err "Java no está instalado. Instala Java 11+ y vuelve a intentar."
fi
JAVA_VER=$(java -version 2>&1 | head -1)
ok "Java encontrado: $JAVA_VER"

# --- Crear directorios ---
mkdir -p "$WORK_DIR" "$DATA_DIR"

# --- Función: verificar archivo por tamaño mínimo ---
check_file() {
    local file="$1"
    local min_size="$2"
    local label="$3"

    if [ -f "$file" ]; then
        local size
        size=$(wc -c < "$file")
        if [ "$size" -ge "$min_size" ]; then
            local hr
            hr=$(du -sh "$file" | cut -f1)
            ok "$label ya existe ($hr) — reutilizando"
            return 0
        else
            warn "$label existe pero parece corrupto/incompleto ($(du -sh "$file" | cut -f1)) — se re-descargará"
            rm -f "$file"
            return 1
        fi
    else
        warn "$label no existe — Planetiler lo descargará"
        return 1
    fi
}

# --- Función: descargar con curl (con reintentos y continuación) ---
download_file() {
    local url="$1"
    local dest="$2"
    local label="$3"
    local min_size="$4"

    # Verificar si ya existe y es válido
    if check_file "$dest" "$min_size" "$label"; then
        return 0
    fi

    echo ""
    log "Descargando $label..."
    log "URL: $url"

    # -C - continúa descarga parcial si existe
    # --retry 3 reintenta en caso de fallo de red
    # --retry-delay 5 espera 5s entre reintentos
    curl -L --progress-bar \
        -C - \
        --retry 3 \
        --retry-delay 5 \
        --connect-timeout 30 \
        -o "$dest" \
        "$url" || err "Falló la descarga de $label"

    check_file "$dest" "$min_size" "$label" || err "$label descargado pero parece corrupto"
}

# --- Limpiar archivos _inprogress corruptos de descargas interrumpidas ---
for f in "$DATA_DIR"/*_inprogress; do
    [ -f "$f" ] && warn "Eliminando descarga interrumpida: $(basename "$f")" && rm -f "$f"
done

# --- Verificar y descargar todos los archivos necesarios con curl ---
echo ""
log "Verificando y descargando archivos necesarios..."

download_file \
    "https://github.com/onthegomap/planetiler/releases/latest/download/planetiler.jar" \
    "$JAR" "Planetiler JAR" $MIN_JAR

download_file \
    "https://download.geofabrik.de/south-america/ecuador-latest.osm.pbf" \
    "$OSM" "Ecuador OSM" $MIN_OSM

download_file \
    "https://osmdata.openstreetmap.de/download/water-polygons-split-3857.zip" \
    "$DATA_DIR/water-polygons-split-3857.zip" "water_polygons (~900 MB)" $MIN_WATER

download_file \
    "https://naciscdn.org/naturalearth/packages/natural_earth_vector.sqlite.zip" \
    "$DATA_DIR/natural_earth_vector.sqlite.zip" "natural_earth (~430 MB)" $MIN_NATURAL

download_file \
    "https://github.com/acalcutt/osml10n/releases/download/lake_centerline_v2.8/lake_centerline.shp.zip" \
    "$DATA_DIR/lake_centerline.shp.zip" "lake_centerline" $MIN_LAKE

# --- Ejecutar Planetiler (sin --download, los archivos ya están descargados) ---
echo ""
log "Iniciando Planetiler (zoom 0-$MAX_ZOOM, bounds: $BOUNDS)..."
log "Todos los datos ya están en caché — solo procesa y genera tiles."
echo ""

java $JAVA_MEM -jar "$JAR" \
    --osm-path="$OSM" \
    --bounds="$BOUNDS" \
    --maxzoom="$MAX_ZOOM" \
    --download-dir="$DATA_DIR" \
    --output="$OUTPUT"

# --- Verificar output ---
echo ""
if [ ! -f "$OUTPUT" ]; then
    err "Planetiler terminó pero no se encontró el archivo de salida: $OUTPUT"
fi

SIZE=$(du -sh "$OUTPUT" | cut -f1)
SIZE_BYTES=$(wc -c < "$OUTPUT")

if [ "$SIZE_BYTES" -lt 5000000 ]; then
    err "El archivo generado es demasiado pequeño ($SIZE). Algo salió mal."
fi

ok "PMTiles generado: $OUTPUT ($SIZE)"

# --- Leer SERVICE_ROLE_KEY del .env ---
echo ""
log "Leyendo credenciales de Supabase..."

if [ ! -f "$ENV_FILE" ]; then
    err "No se encontró .env en: $ENV_FILE"
fi

SERVICE_KEY=$(grep "^SUPABASE_SERVICE_ROLE_KEY=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d "'")

if [ -z "$SERVICE_KEY" ]; then
    err "No se encontró SUPABASE_SERVICE_ROLE_KEY en .env"
fi

ok "SERVICE_ROLE_KEY cargado (${#SERVICE_KEY} chars)"

# --- Subir a Supabase Storage ---
echo ""
log "Subiendo a Supabase Storage ($BUCKET/$REMOTE_FILE)..."
log "Tamaño: $SIZE — puede tardar varios minutos."
echo ""

HTTP_STATUS=$(curl -s -o /tmp/supabase_upload_response.json -w "%{http_code}" \
    -X PUT \
    "$SUPABASE_URL/storage/v1/object/$BUCKET/$REMOTE_FILE" \
    -H "Authorization: Bearer $SERVICE_KEY" \
    -H "Content-Type: application/octet-stream" \
    --data-binary "@$OUTPUT")

if [ "$HTTP_STATUS" -eq 200 ]; then
    ok "Upload exitoso (HTTP $HTTP_STATUS)"
else
    warn "Respuesta HTTP: $HTTP_STATUS"
    cat /tmp/supabase_upload_response.json
    err "Upload falló. Revisa las credenciales y que el bucket '$BUCKET' exista."
fi

# --- Verificar en Supabase ---
echo ""
log "Verificando archivo en Supabase..."
REMOTE_SIZE=$(curl -sI \
    "$SUPABASE_URL/storage/v1/object/public/$BUCKET/$REMOTE_FILE" \
    | grep -i "content-length" | awk '{print $2}' | tr -d '\r')

if [ -n "$REMOTE_SIZE" ]; then
    REMOTE_MB=$(echo "scale=1; $REMOTE_SIZE / 1048576" | bc)
    ok "Archivo verificado en Supabase: ${REMOTE_MB} MB ($REMOTE_SIZE bytes)"
else
    warn "No se pudo verificar el tamaño remoto"
fi

# --- Resumen final ---
echo ""
echo "============================================="
echo -e "${GREEN}  PMTiles generado y subido exitosamente${NC}"
echo "============================================="
echo ""
echo "  Archivo local:  $OUTPUT ($SIZE)"
echo "  URL pública:    $SUPABASE_URL/storage/v1/object/public/$BUCKET/$REMOTE_FILE"
echo ""
echo "  Archivos en caché (reutilizables en próximas ejecuciones):"
for f in "$JAR" "$OSM" "$DATA_DIR/lake_centerline.shp.zip" \
          "$DATA_DIR/water-polygons-split-3857.zip" \
          "$DATA_DIR/natural_earth_vector.sqlite.zip"; do
    [ -f "$f" ] && echo "    $(du -sh "$f" | cut -f1)  $f"
done
echo ""
echo "  Los usuarios deberán re-descargar el mapa desde la app"
echo "  para obtener el nuevo archivo con zoom $MAX_ZOOM."
echo ""
