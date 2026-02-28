#!/bin/bash
# ============================================================================
# Download species images from Wikimedia Commons
# Uses Wikipedia API to find main images, downloads originals,
# crops to 16:9 (1280x720), and saves attribution data.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_DIR/assets/images/species"
ATTR_FILE="$PROJECT_DIR/bin/image_attributions.json"
TEMP_DIR="$PROJECT_DIR/.tmp_images"
LOG_FILE="$PROJECT_DIR/bin/download_images.log"

mkdir -p "$ASSETS_DIR" "$TEMP_DIR"
echo "[]" > "$ATTR_FILE"
echo "" > "$LOG_FILE"

log() {
  echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# ============================================================================
# Species needing images: ID|Scientific Name|Filename base|Wikipedia title
# ============================================================================
SPECIES_LIST=(
  # === REPTILES ===
  "10|Buteo galapagoensis|galapagos_hawk|Buteo galapagoensis"
  "17|Conolophus marthae|pink_land_iguana|Conolophus marthae"
  "43|Chelonoidis chathamensis|san_cristobal_tortoise|Chelonoidis chathamensis"
  "44|Chelonoidis hoodensis|espanola_tortoise|Chelonoidis hoodensis"
  "45|Chelonoidis vandenburghi|alcedo_tortoise|Chelonoidis vandenburghi"
  "46|Chelonoidis becki|wolf_volcano_tortoise|Chelonoidis becki"
  "47|Chelonoidis darwini|santiago_tortoise|Chelonoidis darwini"
  "48|Chelonoidis duncanensis|pinzon_tortoise|Chelonoidis duncanensis"
  "49|Chelonoidis guntheri|sierra_negra_tortoise|Chelonoidis guntheri"
  "50|Chelonoidis donfaustoi|eastern_santa_cruz_tortoise|Chelonoidis donfaustoi"
  "51|Chelonoidis phantasticus|fernandina_tortoise|Chelonoidis phantasticus"
  "52|Chelonoidis abingdonii|lonesome_george|Lonesome George"
  "53|Chelonoidis microphyes|darwin_volcano_tortoise|Chelonoidis microphyes"
  "54|Chelonoidis vicina|cerro_azul_tortoise|Chelonoidis vicina"
  "55|Conolophus pallidus|santa_fe_land_iguana|Conolophus pallidus"
  "56|Pseudalsophis dorsalis|central_galapagos_racer|Pseudalsophis dorsalis"
  "57|Pseudalsophis occidentalis|western_galapagos_racer|Pseudalsophis occidentalis"
  "58|Pseudalsophis hoodensis|espanola_racer|Pseudalsophis hoodensis"
  "59|Pseudalsophis steindachneri|striped_galapagos_snake|Pseudalsophis steindachneri"
  "60|Hydrophis platurus|yellow_bellied_sea_snake|Hydrophis platurus"
  "89|Chelonoidis niger|floreana_tortoise|Chelonoidis niger (tortoise)"
  "90|Chelonoidis sp.|santa_fe_tortoise|Galápagos tortoise"
  "106|Pseudalsophis slevini|pinzon_racer|Pseudalsophis slevini"
  "107|Pseudalsophis hephaestus|santiago_racer|Pseudalsophis hephaestus"
  "109|Pseudalsophis darwini|tortuga_island_racer|Pseudalsophis darwini"
  "110|Pseudalsophis thomasi|thomas_racer|Pseudalsophis thomasi"
  # === SEA TURTLES ===
  "14|Chelonia mydas|green_sea_turtle|Green sea turtle"
  "19|Eretmochelys imbricata|hawksbill_sea_turtle|Hawksbill sea turtle"
  "61|Caretta caretta|loggerhead_sea_turtle|Loggerhead sea turtle"
  "62|Lepidochelys olivacea|olive_ridley_turtle|Olive ridley sea turtle"
  "63|Dermochelys coriacea|leatherback_turtle|Leatherback sea turtle"
  # === BIRDS ===
  "24|Asio flammeus galapagoensis|galapagos_short_eared_owl|Asio flammeus"
  "26|Setophaga petechia aureola|galapagos_yellow_warbler|Setophaga petechia"
  "27|Mimus parvulus|galapagos_mockingbird|Galápagos mockingbird"
  "31|Fregata minor|great_frigatebird|Great frigatebird"
  "64|Geospiza fuliginosa|small_ground_finch|Small ground finch"
  "65|Geospiza magnirostris|large_ground_finch|Large ground finch"
  "66|Geospiza scandens|common_cactus_finch|Common cactus finch"
  "67|Geospiza conirostris|large_cactus_finch|Geospiza conirostris"
  "68|Camarhynchus pallidus|woodpecker_finch|Woodpecker finch"
  "69|Camarhynchus parvulus|small_tree_finch|Camarhynchus parvulus"
  "70|Platyspiza crassirostris|vegetarian_finch|Vegetarian finch"
  "71|Certhidea olivacea|green_warbler_finch|Green warbler-finch"
  "72|Camarhynchus heliobates|mangrove_finch|Mangrove finch"
  "73|Laterallus spilonotus|galapagos_rail|Galapagos rail"
  "74|Leucophaeus fuliginosus|lava_gull|Lava gull"
  "75|Mimus macdonaldi|espanola_mockingbird|Española mockingbird"
  "76|Mimus trifasciatus|floreana_mockingbird|Floreana mockingbird"
  "77|Myiarchus magnirostris|galapagos_flycatcher|Galápagos flycatcher"
  "78|Pyrocephalus nanus|galapagos_vermilion_flycatcher|Pyrocephalus nanus"
  "79|Pterodroma phaeopygia|galapagos_petrel|Galápagos petrel"
  "80|Progne modesta|galapagos_martin|Galápagos martin"
  "92|Geospiza difficilis|sharp_beaked_ground_finch|Sharp-beaked ground finch"
  "93|Geospiza septentrionalis|vampire_ground_finch|Vampire ground finch"
  "94|Geospiza acutirostris|genovesa_ground_finch|Geospiza acutirostris"
  "95|Geospiza propinqua|genovesa_cactus_finch|Geospiza propinqua"
  "96|Camarhynchus pauper|medium_tree_finch|Medium tree finch"
  "97|Camarhynchus psittacula|large_tree_finch|Large tree finch"
  "98|Certhidea fusca|grey_warbler_finch|Grey warbler-finch"
  "99|Pinaroloxias inornata|cocos_finch|Cocos finch"
  "104|Mimus melanotis|san_cristobal_mockingbird|San Cristóbal mockingbird"
  "111|Anas bahamensis galapagensis|white_cheeked_pintail|White-cheeked pintail"
  "112|Nyctanassa violacea pauper|yellow_crowned_night_heron|Yellow-crowned night heron"
  "113|Haematopus palliatus galapagensis|galapagos_oystercatcher|American oystercatcher"
  "114|Puffinus subalaris|galapagos_shearwater|Galápagos shearwater"
  "115|Tyto alba punctatissima|galapagos_barn_owl|Barn owl"
  "116|Oceanodroma tethys tethys|wedge_rumped_storm_petrel|Wedge-rumped storm petrel"
  # === MAMMALS ===
  "13|Arctocephalus galapagoensis|galapagos_fur_seal|Galápagos fur seal"
  "32|Aegialomys galapagoensis|galapagos_rice_rat|Galápagos rice rat"
  "33|Lasiurus blossevillii brachyotis|galapagos_red_bat|Desert red bat"
  "34|Lasiurus villosissimus|galapagos_hoary_bat|Southern big-eared brown bat"
  "81|Tursiops truncatus|bottlenose_dolphin|Common bottlenose dolphin"
  "82|Megaptera novaeangliae|humpback_whale|Humpback whale"
  "83|Orcinus orca|orca|Orca"
  "108|Physeter macrocephalus|sperm_whale|Sperm whale"
  # === MARINE LIFE ===
  "15|Carcharhinus galapagensis|galapagos_shark|Galapagos shark"
  "16|Sphyrna lewini|scalloped_hammerhead|Scalloped hammerhead"
  "35|Mobula birostris|giant_manta_ray|Giant oceanic manta ray"
  "37|Rhincodon typus|whale_shark|Whale shark"
  "38|Hippocampus ingens|pacific_seahorse|Hippocampus ingens"
  "39|Octopus oculifer|galapagos_reef_octopus|Octopus oculifer"
  "40|Triaenodon obesus|whitetip_reef_shark|Whitetip reef shark"
  "84|Mola mola|ocean_sunfish|Ocean sunfish"
  "85|Diodon holocanthus|porcupinefish|Diodon holocanthus"
  # === INVERTEBRATES ===
  "41|Grapsus grapsus|sally_lightfoot_crab|Grapsus grapsus"
  "42|Schistocerca melanocera|galapagos_painted_locust|Schistocerca melanocera"
  "86|Panulirus penicillatus|galapagos_spiny_lobster|Panulirus penicillatus"
  "87|Holothuria atra|black_sea_cucumber|Holothuria atra"
  "88|Tripneustes depressus|white_sea_urchin|Tripneustes depressus"
)

TOTAL=${#SPECIES_LIST[@]}
SUCCESS=0
FAILED=0
SKIPPED=0

# ============================================================================
# Function: Download image from Wikipedia
# ============================================================================
download_species_image() {
  local entry="$1"
  IFS='|' read -r species_id scientific_name filename wiki_title <<< "$entry"

  local output_file="$ASSETS_DIR/${filename}.jpg"

  # Skip if already exists
  if [[ -f "$output_file" ]]; then
    log "SKIP [$species_id] $scientific_name - already exists"
    return 2
  fi

  log "FETCH [$species_id] $scientific_name (wiki: $wiki_title)"

  # URL-encode the title
  local encoded_title
  encoded_title=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$wiki_title'))")

  # Step 1: Get the main image from Wikipedia
  local api_url="https://en.wikipedia.org/w/api.php?action=query&titles=${encoded_title}&prop=pageimages&format=json&piprop=original&redirects=1"
  local response
  response=$(curl -s -L --max-time 15 "$api_url" 2>/dev/null) || {
    log "ERROR [$species_id] API request failed for $wiki_title"
    return 1
  }

  # Extract image URL
  local image_url
  image_url=$(echo "$response" | jq -r '.query.pages | to_entries[0].value.original.source // empty' 2>/dev/null)

  if [[ -z "$image_url" ]]; then
    # Fallback: try with scientific name directly
    encoded_title=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${scientific_name}'))")
    api_url="https://en.wikipedia.org/w/api.php?action=query&titles=${encoded_title}&prop=pageimages&format=json&piprop=original&redirects=1"
    response=$(curl -s -L --max-time 15 "$api_url" 2>/dev/null) || true
    image_url=$(echo "$response" | jq -r '.query.pages | to_entries[0].value.original.source // empty' 2>/dev/null)
  fi

  if [[ -z "$image_url" ]]; then
    log "WARN  [$species_id] No image found for $wiki_title / $scientific_name"
    return 1
  fi

  log "  -> Image URL: $image_url"

  # Step 2: Download the original image
  local temp_file="$TEMP_DIR/${filename}_orig"
  curl -s -L --max-time 30 -o "$temp_file" "$image_url" 2>/dev/null || {
    log "ERROR [$species_id] Download failed"
    rm -f "$temp_file"
    return 1
  }

  # Verify it's an image
  local file_type
  file_type=$(file -b --mime-type "$temp_file" 2>/dev/null)
  if [[ ! "$file_type" =~ ^image/ ]]; then
    log "ERROR [$species_id] Downloaded file is not an image: $file_type"
    rm -f "$temp_file"
    return 1
  fi

  # Step 3: Get attribution info from Wikimedia Commons
  local image_filename
  image_filename=$(basename "$image_url" | python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.stdin.read().strip()))")
  local commons_encoded
  commons_encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('File:${image_filename}'))")
  local commons_api="https://en.wikipedia.org/w/api.php?action=query&titles=${commons_encoded}&prop=imageinfo&iiprop=extmetadata&format=json&redirects=1"
  local commons_response
  commons_response=$(curl -s -L --max-time 15 "$commons_api" 2>/dev/null) || true

  local artist license
  artist=$(echo "$commons_response" | jq -r '.query.pages | to_entries[0].value.imageinfo[0].extmetadata.Artist.value // "Unknown"' 2>/dev/null | sed 's/<[^>]*>//g' | head -1)
  license=$(echo "$commons_response" | jq -r '.query.pages | to_entries[0].value.imageinfo[0].extmetadata.LicenseShortName.value // "CC"' 2>/dev/null)

  # Clean artist name (remove HTML tags)
  artist=$(echo "$artist" | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/<[^>]*>//g' | xargs)
  [[ -z "$artist" || "$artist" == "null" ]] && artist="Wikimedia Commons"
  [[ -z "$license" || "$license" == "null" ]] && license="CC"

  log "  -> Author: $artist | License: $license"

  # Step 4: Crop/resize to 16:9 (1280x720) using ImageMagick
  # Strategy: resize to fill 1280x720, then crop center
  magick "$temp_file" \
    -auto-orient \
    -resize "1280x720^" \
    -gravity center \
    -extent 1280x720 \
    -quality 85 \
    "$output_file" 2>/dev/null || {
    log "ERROR [$species_id] ImageMagick processing failed"
    rm -f "$temp_file"
    return 1
  }

  rm -f "$temp_file"

  # Step 5: Save attribution
  local attr_entry
  attr_entry=$(jq -n \
    --argjson id "$species_id" \
    --arg scientific_name "$scientific_name" \
    --arg filename "${filename}.jpg" \
    --arg author "$artist" \
    --arg license "$license" \
    --arg source_url "$image_url" \
    '{species_id: $id, scientific_name: $scientific_name, filename: $filename, author: $author, license: $license, source_url: $source_url}')

  # Append to attributions file (thread-safe with temp file)
  local tmp_attr
  tmp_attr=$(mktemp)
  jq --argjson entry "$attr_entry" '. + [$entry]' "$ATTR_FILE" > "$tmp_attr" && mv "$tmp_attr" "$ATTR_FILE"

  log "OK    [$species_id] $scientific_name -> ${filename}.jpg"
  return 0
}

# ============================================================================
# Main loop - process sequentially (to avoid API rate limits)
# ============================================================================
log "Starting download of $TOTAL species images..."
log "Output directory: $ASSETS_DIR"
log "Attribution file: $ATTR_FILE"
log "================================================"

for entry in "${SPECIES_LIST[@]}"; do
  IFS='|' read -r species_id _ _ _ <<< "$entry"

  result=0
  download_species_image "$entry" || result=$?

  if [[ $result -eq 0 ]]; then
    ((SUCCESS++))
  elif [[ $result -eq 2 ]]; then
    ((SKIPPED++))
  else
    ((FAILED++))
  fi

  # Small delay to be nice to Wikipedia API
  sleep 0.5
done

log "================================================"
log "DONE: $SUCCESS downloaded, $SKIPPED skipped, $FAILED failed (of $TOTAL total)"
log "Attribution data saved to: $ATTR_FILE"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "Summary:"
echo "  Downloaded: $SUCCESS"
echo "  Skipped:    $SKIPPED"
echo "  Failed:     $FAILED"
echo "  Total:      $TOTAL"
echo ""
echo "Next steps:"
echo "  1. Review downloaded images in $ASSETS_DIR"
echo "  2. Run: dart run bin/seed_species_images.dart"
echo "  3. Update lib/core/constants/species_assets.dart"
