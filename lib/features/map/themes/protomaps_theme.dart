import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Light theme for Protomaps Basemap v4 vector tiles.
///
/// Designed for the Galápagos region — emphasises water, earth, and natural
/// areas. Compatible with the Protomaps Basemap layer schema (earth, water,
/// natural, landuse, roads, buildings, boundaries, places).
vtr.Theme protomapsLightTheme() {
  return vtr.ThemeReader().read(_lightStyleJson);
}

/// Dark theme variant.
vtr.Theme protomapsDarkTheme() {
  return vtr.ThemeReader().read(_darkStyleJson);
}

const _lightStyleJson = {
  'version': 8,
  'name': 'Galapagos Light',
  'sources': {
    'protomaps': {
      'type': 'vector',
      'url': 'pmtiles://local',
    }
  },
  'layers': [
    // Background (ocean default)
    {
      'id': 'background',
      'type': 'background',
      'paint': {'background-color': '#aad3df'},
    },
    // Earth / land mass
    {
      'id': 'earth',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'earth',
      'paint': {'fill-color': '#e8e0d8'},
    },
    // Natural areas (parks, forests, wetlands)
    {
      'id': 'natural',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'natural',
      'paint': {
        'fill-color': '#c8d7ab',
        'fill-opacity': 0.6,
      },
    },
    // Land use (residential, commercial)
    {
      'id': 'landuse',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'landuse',
      'paint': {
        'fill-color': '#d9d0c9',
        'fill-opacity': 0.5,
      },
    },
    // Water bodies (lakes, rivers)
    {
      'id': 'water',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'water',
      'paint': {'fill-color': '#aad3df'},
    },
    // Boundaries (country, region)
    {
      'id': 'boundaries',
      'type': 'line',
      'source': 'protomaps',
      'source-layer': 'boundaries',
      'paint': {
        'line-color': '#9e9cab',
        'line-width': 1.0,
        'line-dasharray': [3, 2],
      },
    },
    // Roads — casing
    {
      'id': 'roads-casing',
      'type': 'line',
      'source': 'protomaps',
      'source-layer': 'roads',
      'minzoom': 10,
      'paint': {
        'line-color': '#c8c4c0',
        'line-width': {
          'stops': [
            [10, 2],
            [14, 6],
          ],
        },
      },
    },
    // Roads — fill
    {
      'id': 'roads-fill',
      'type': 'line',
      'source': 'protomaps',
      'source-layer': 'roads',
      'minzoom': 10,
      'paint': {
        'line-color': '#ffffff',
        'line-width': {
          'stops': [
            [10, 1],
            [14, 4],
          ],
        },
      },
    },
    // Buildings
    {
      'id': 'buildings',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'buildings',
      'minzoom': 13,
      'paint': {
        'fill-color': '#d9d0c9',
        'fill-opacity': 0.7,
      },
    },
    // Physical lines (coastlines)
    {
      'id': 'physical-line',
      'type': 'line',
      'source': 'protomaps',
      'source-layer': 'physical_line',
      'paint': {
        'line-color': '#9dbdca',
        'line-width': 0.5,
      },
    },
    // Place labels
    {
      'id': 'places',
      'type': 'symbol',
      'source': 'protomaps',
      'source-layer': 'places',
      'layout': {
        'text-field': '{name}',
        'text-size': {
          'stops': [
            [6, 10],
            [10, 14],
          ],
        },
      },
      'paint': {
        'text-color': '#333333',
        'text-halo-color': '#ffffff',
        'text-halo-width': 1.5,
      },
    },
    // POI labels (only at high zoom)
    {
      'id': 'pois',
      'type': 'symbol',
      'source': 'protomaps',
      'source-layer': 'pois',
      'minzoom': 13,
      'layout': {
        'text-field': '{name}',
        'text-size': 11,
      },
      'paint': {
        'text-color': '#666666',
        'text-halo-color': '#ffffff',
        'text-halo-width': 1.0,
      },
    },
  ],
};

const _darkStyleJson = {
  'version': 8,
  'name': 'Galapagos Dark',
  'sources': {
    'protomaps': {
      'type': 'vector',
      'url': 'pmtiles://local',
    }
  },
  'layers': [
    // Background (dark ocean)
    {
      'id': 'background',
      'type': 'background',
      'paint': {'background-color': '#1a2634'},
    },
    // Earth
    {
      'id': 'earth',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'earth',
      'paint': {'fill-color': '#2b2d31'},
    },
    // Natural
    {
      'id': 'natural',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'natural',
      'paint': {
        'fill-color': '#2a3a2a',
        'fill-opacity': 0.6,
      },
    },
    // Land use
    {
      'id': 'landuse',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'landuse',
      'paint': {
        'fill-color': '#333438',
        'fill-opacity': 0.5,
      },
    },
    // Water
    {
      'id': 'water',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'water',
      'paint': {'fill-color': '#1a2634'},
    },
    // Boundaries
    {
      'id': 'boundaries',
      'type': 'line',
      'source': 'protomaps',
      'source-layer': 'boundaries',
      'paint': {
        'line-color': '#555566',
        'line-width': 1.0,
        'line-dasharray': [3, 2],
      },
    },
    // Roads casing
    {
      'id': 'roads-casing',
      'type': 'line',
      'source': 'protomaps',
      'source-layer': 'roads',
      'minzoom': 10,
      'paint': {
        'line-color': '#1e1e22',
        'line-width': {
          'stops': [
            [10, 2],
            [14, 6],
          ],
        },
      },
    },
    // Roads fill
    {
      'id': 'roads-fill',
      'type': 'line',
      'source': 'protomaps',
      'source-layer': 'roads',
      'minzoom': 10,
      'paint': {
        'line-color': '#3a3a40',
        'line-width': {
          'stops': [
            [10, 1],
            [14, 4],
          ],
        },
      },
    },
    // Buildings
    {
      'id': 'buildings',
      'type': 'fill',
      'source': 'protomaps',
      'source-layer': 'buildings',
      'minzoom': 13,
      'paint': {
        'fill-color': '#333438',
        'fill-opacity': 0.7,
      },
    },
    // Physical lines
    {
      'id': 'physical-line',
      'type': 'line',
      'source': 'protomaps',
      'source-layer': 'physical_line',
      'paint': {
        'line-color': '#2a3a4a',
        'line-width': 0.5,
      },
    },
    // Place labels
    {
      'id': 'places',
      'type': 'symbol',
      'source': 'protomaps',
      'source-layer': 'places',
      'layout': {
        'text-field': '{name}',
        'text-size': {
          'stops': [
            [6, 10],
            [10, 14],
          ],
        },
      },
      'paint': {
        'text-color': '#cccccc',
        'text-halo-color': '#1a1a1e',
        'text-halo-width': 1.5,
      },
    },
    // POI labels
    {
      'id': 'pois',
      'type': 'symbol',
      'source': 'protomaps',
      'source-layer': 'pois',
      'minzoom': 13,
      'layout': {
        'text-field': '{name}',
        'text-size': 11,
      },
      'paint': {
        'text-color': '#999999',
        'text-halo-color': '#1a1a1e',
        'text-halo-width': 1.0,
      },
    },
  ],
};
