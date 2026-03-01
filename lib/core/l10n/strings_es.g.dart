///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEs with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppEs app = _TranslationsAppEs._(_root);
	@override late final _TranslationsNavEs nav = _TranslationsNavEs._(_root);
	@override late final _TranslationsHomeEs home = _TranslationsHomeEs._(_root);
	@override late final _TranslationsSpeciesEs species = _TranslationsSpeciesEs._(_root);
	@override late final _TranslationsConservationEs conservation = _TranslationsConservationEs._(_root);
	@override late final _TranslationsMapEs map = _TranslationsMapEs._(_root);
	@override late final _TranslationsFavoritesEs favorites = _TranslationsFavoritesEs._(_root);
	@override late final _TranslationsSightingsEs sightings = _TranslationsSightingsEs._(_root);
	@override late final _TranslationsAuthEs auth = _TranslationsAuthEs._(_root);
	@override late final _TranslationsSettingsEs settings = _TranslationsSettingsEs._(_root);
	@override late final _TranslationsAdminEs admin = _TranslationsAdminEs._(_root);
	@override late final _TranslationsBadgesEs badges = _TranslationsBadgesEs._(_root);
	@override late final _TranslationsOfflineEs offline = _TranslationsOfflineEs._(_root);
	@override late final _TranslationsCommonEs common = _TranslationsCommonEs._(_root);
	@override late final _TranslationsErrorEs error = _TranslationsErrorEs._(_root);
	@override late final _TranslationsSyncEs sync = _TranslationsSyncEs._(_root);
	@override late final _TranslationsLocationEs location = _TranslationsLocationEs._(_root);
	@override late final _TranslationsOnboardingEs onboarding = _TranslationsOnboardingEs._(_root);
	@override late final _TranslationsSearchEs search = _TranslationsSearchEs._(_root);
	@override late final _TranslationsLeaderboardEs leaderboard = _TranslationsLeaderboardEs._(_root);
	@override late final _TranslationsShareEs share = _TranslationsShareEs._(_root);
	@override late final _TranslationsCelebrationsEs celebrations = _TranslationsCelebrationsEs._(_root);
	@override late final _TranslationsErrorsEs errors = _TranslationsErrorsEs._(_root);
	@override late final _TranslationsFieldEditEs fieldEdit = _TranslationsFieldEditEs._(_root);
}

// Path: app
class _TranslationsAppEs implements TranslationsAppEn {
	_TranslationsAppEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Fauna de Galápagos';
	@override String get subtitle => 'Explora las islas encantadas';
}

// Path: nav
class _TranslationsNavEs implements TranslationsNavEn {
	_TranslationsNavEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get home => 'Inicio';
	@override String get species => 'Especies';
	@override String get map => 'Mapa';
	@override String get favorites => 'Favoritos';
	@override String get sightings => 'Avistamientos';
}

// Path: home
class _TranslationsHomeEs implements TranslationsHomeEn {
	_TranslationsHomeEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Bienvenido a Galápagos';
	@override String get explore => 'Explorar Fauna';
	@override String get categories => 'Categorías';
	@override String get featured => 'Especies Destacadas';
	@override String get quickLinks => 'Accesos Rápidos';
	@override String get viewAll => 'Ver Todo';
	@override String get discoverSpecies => 'Descubrir Especies';
	@override String get exploreMap => 'Explorar el Mapa';
	@override String get recentSightings => 'Avistamientos Recientes';
	@override String get browseWildlife => 'Explorar toda la fauna';
	@override String get findSites => 'Encontrar sitios de visita e islas';
	@override String get logEncounters => 'Registra tus encuentros con la fauna';
}

// Path: species
class _TranslationsSpeciesEs implements TranslationsSpeciesEn {
	_TranslationsSpeciesEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Especies';
	@override String get search => 'Buscar especies...';
	@override String get all => 'Todas';
	@override String get endemic => 'Endémica';
	@override String get conservationStatus => 'Estado de Conservación';
	@override String get scientificName => 'Nombre Científico';
	@override String get weight => 'Peso';
	@override String get size => 'Tamaño';
	@override String get population => 'Población';
	@override String get lifespan => 'Esperanza de Vida';
	@override String get habitat => 'Hábitat';
	@override String get description => 'Descripción';
	@override String get whereToSee => 'Dónde Verla';
	@override String get gallery => 'Galería';
	@override String get quickFacts => 'Datos Rápidos';
	@override String conservationStatusLabel({required Object status}) => 'Estado de conservación: ${status}';
	@override String get years => 'años';
	@override String get kg => 'kg';
	@override String get cm => 'cm';
	@override String get individuals => 'individuos';
	@override String get taxonomy => 'Taxonomía';
	@override String get kingdom => 'Reino';
	@override String get phylum => 'Filo';
	@override String get classLabel => 'Clase';
	@override String get order => 'Orden';
	@override String get family => 'Familia';
	@override String get genus => 'Género';
	@override String get noResults => 'No se encontraron especies';
	@override String get noResultsSubtitle => 'Intenta con un término diferente';
	@override String get noImages => 'Sin imágenes adicionales';
	@override String get addToFavorites => 'Agregar a favoritos';
	@override String get removeFromFavorites => 'Quitar de favoritos';
	@override String get notFound => 'Especie no encontrada';
	@override String get clearFilters => 'Limpiar';
	@override String get categoryFilter => 'Categoría';
	@override String get conservationFilter => 'Conservación y Endémica';
	@override String get filterHelp => 'Cómo funcionan los filtros';
	@override String get filterHelpText => 'Los filtros se combinan para refinar resultados. Selecciona una categoría, estado de conservación o endémica para filtrar especies.';
	@override String get compare => 'Comparar';
	@override String get compareSpecies => 'Comparar Especies';
	@override String get selectTwoSpecies => 'Selecciona dos especies para comparar';
	@override String get vsLabel => 'VS';
	@override String featuredImageLabel({required Object name}) => 'Destacada: ${name}, toca para ver detalles';
	@override String galleryImageLabel({required Object index, required Object total}) => 'Imagen de galería ${index} de ${total}';
	@override String fullscreenImageLabel({required Object index, required Object total}) => 'Imagen ${index} de ${total}';
	@override String thumbnailLabel({required Object index}) => 'Miniatura ${index}, toca para ver imagen completa';
	@override late final _TranslationsSpeciesFrequencyEs frequency = _TranslationsSpeciesFrequencyEs._(_root);
}

// Path: conservation
class _TranslationsConservationEs implements TranslationsConservationEn {
	_TranslationsConservationEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get EX => 'Extinta';
	@override String get EW => 'Extinta en Estado Silvestre';
	@override String get CR => 'En Peligro Crítico';
	@override String get EN => 'En Peligro';
	@override String get VU => 'Vulnerable';
	@override String get NT => 'Casi Amenazada';
	@override String get LC => 'Preocupación Menor';
	@override String get DD => 'Datos Insuficientes';
	@override String get NE => 'No Evaluada';
}

// Path: map
class _TranslationsMapEs implements TranslationsMapEn {
	_TranslationsMapEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mapa de Galápagos';
	@override String get islands => 'Islas';
	@override String get visitSites => 'Sitios de Visita';
	@override String get speciesHere => 'Especies aquí';
	@override String get directions => 'Cómo Llegar';
	@override String get offlineTiles => 'Mapa Offline';
	@override String get downloadTiles => 'Descargar Mapa';
	@override String get downloading => 'Descargando mapa...';
	@override String get downloadComplete => 'Mapa descargado';
	@override String get downloadInProgress => 'Descarga en progreso...';
	@override String get tilesInfo => 'Descarga el mapa para uso sin conexión';
	@override String get toggleSites => 'Mostrar/ocultar sitios de visita';
	@override String get goToMyLocation => 'Ir a mi ubicación';
	@override String get locatingDevice => 'Localizando dispositivo...';
	@override String get centerOnGalapagos => 'Centrar en Galápagos';
	@override String get cachedTiles => 'Tiles en caché';
	@override String get cacheSize => 'Tamaño de caché';
	@override String get mb => 'MB';
	@override String get downloadForOffline => 'Descargar para uso offline';
	@override String estimatedTiles({required Object count}) => 'Tiles estimados: ${count}';
	@override String get downloadCancelled => 'Descarga cancelada';
	@override String islandArea({required Object area}) => 'Área: ${area} km²';
	@override String get yourLocation => 'Tu ubicación actual';
	@override String islandLabel({required Object name}) => 'Isla: ${name}';
	@override String visitSiteLabel({required Object name}) => 'Sitio de visita: ${name}';
	@override String get sightings => 'Avistamientos';
	@override String get toggleSightings => 'Mostrar/ocultar avistamientos';
	@override String sightingLabel({required Object species}) => 'Avistamiento: ${species}';
	@override String get trails => 'Senderos';
	@override String get toggleTrails => 'Mostrar/ocultar senderos';
	@override String trailLabel({required Object name}) => 'Sendero: ${name}';
	@override String get trailDifficulty => 'Dificultad';
	@override String trailDistance({required Object km}) => '${km} km';
	@override String trailDuration({required Object min}) => '${min} min';
	@override String get difficultyEasy => 'Fácil';
	@override String get difficultyModerate => 'Moderado';
	@override String get difficultyHard => 'Difícil';
	@override String get downloadByIsland => 'Descargar por Isla';
	@override String get downloadAll => 'Descargar Todo Galápagos';
	@override String get selectIslands => 'Selecciona islas para descargar';
	@override String get downloadSelected => 'Descargar Seleccionadas';
	@override String get zoomLevel => 'Nivel de detalle';
	@override String get zoomBasic => 'Básico (menos datos)';
	@override String get zoomDetailed => 'Detallado (más datos)';
	@override String get deleteTiles => 'Eliminar Tiles';
	@override String get tilesDeleted => 'Tiles eliminados';
	@override String get tracking => 'Seguimiento';
	@override String get startTracking => 'Iniciar Seguimiento';
	@override String get stopTracking => 'Detener Seguimiento';
	@override String get trackRecorded => 'Recorrido grabado';
	@override String get offRoute => '¡Te has salido del sendero!';
	@override String get backOnRoute => 'De vuelta en el sendero';
	@override String distanceFromTrail({required Object meters}) => '${meters}m del sendero';
	@override String trackDistance({required Object km}) => 'Distancia: ${km} km';
	@override String trackDuration({required Object duration}) => 'Duración: ${duration}';
	@override String get noTrails => 'No hay senderos disponibles';
	@override String get baseMap => 'Mapa Base';
	@override String get baseMapVector => 'Vectorial (3 MB)';
	@override String get baseMapRaster => 'Ráster HD';
	@override String get downloadBaseMap => 'Descargar Mapa Base';
	@override String get downloadingBaseMap => 'Descargando mapa base...';
	@override String get baseMapReady => 'Mapa base listo';
	@override String get baseMapNotDownloaded => 'Mapa base no descargado';
	@override String get deleteBaseMap => 'Eliminar Mapa Base';
	@override String get baseMapDeleted => 'Mapa base eliminado';
	@override String get switchToVector => 'Cambiar a Vectorial';
	@override String get switchToRaster => 'Cambiar a Ráster HD';
	@override String get hdTiles => 'Tiles Ráster HD';
	@override String get downloadHdArea => 'Descargar HD para esta zona';
	@override String get downloadingHdArea => 'Descargando tiles HD...';
	@override String get hdAreaDownloaded => 'Tiles HD descargados para esta zona';
	@override String get mapMode => 'Modo de Mapa';
	@override String get vectorOffline => 'Vectorial Offline';
	@override String get rasterOnline => 'Ráster HD';
	@override String get switchMapMode => 'Cambiar modo de mapa';
	@override String get mapModes => 'Modos de Mapa';
	@override String get modeStreet => 'Mapa Callejero';
	@override String get modeStreetDesc => 'OpenStreetMap con caché offline';
	@override String get modeVector => 'Mapa Vectorial';
	@override String get modeVectorDesc => 'Tiles vectoriales offline ligeros (3 MB)';
	@override String get modeSatellite => 'Satélite';
	@override String get modeSatelliteDesc => 'Imágenes satelitales de alta resolución (ESRI)';
	@override String get modeHybrid => 'Híbrido';
	@override String get modeHybridDesc => 'Imágenes satelitales con etiquetas';
	@override String get loginRequiredForSatellite => 'Requiere iniciar sesión para vista satelital';
	@override String get filterSites => 'Filtrar sitios';
	@override String get filterVisitSites => 'Filtrar sitios de visita';
}

// Path: favorites
class _TranslationsFavoritesEs implements TranslationsFavoritesEn {
	_TranslationsFavoritesEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Favoritos';
	@override String get empty => 'Sin favoritos aún';
	@override String get emptySubtitle => 'Toca el corazón en cualquier especie para agregarla aquí';
	@override String get added => 'Agregado a favoritos';
	@override String get removed => 'Eliminado de favoritos';
	@override String get loginRequired => 'Inicia sesión para guardar favoritos';
}

// Path: sightings
class _TranslationsSightingsEs implements TranslationsSightingsEn {
	_TranslationsSightingsEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get sightingPhoto => 'Foto del avistamiento';
	@override String get title => 'Mis Avistamientos';
	@override String get add => 'Agregar Avistamiento';
	@override String get empty => 'Sin avistamientos aún';
	@override String get emptySubtitle => 'Registra tus encuentros con la fauna';
	@override String get selectSpecies => 'Seleccionar Especie';
	@override String get selectSite => 'Seleccionar Sitio de Visita';
	@override String get date => 'Fecha';
	@override String get notes => 'Notas';
	@override String get notesHint => '¿Qué observaste?';
	@override String get photo => 'Foto';
	@override String get addPhoto => 'Agregar Foto';
	@override String get location => 'Ubicación';
	@override String get useCurrentLocation => 'Usar Ubicación Actual';
	@override String get save => 'Guardar Avistamiento';
	@override String get saved => 'Avistamiento guardado';
	@override String get delete => 'Eliminar Avistamiento';
	@override String get deleteConfirm => '¿Estás seguro de que quieres eliminar este avistamiento?';
	@override String get loginRequired => 'Inicia sesión para registrar avistamientos';
	@override String get pendingSync => 'Pendiente de sincronizar';
	@override String get takePhoto => 'Tomar Foto';
	@override String get fromGallery => 'Elegir de Galería';
	@override String get changePhoto => 'Cambiar Foto';
	@override String get removePhoto => 'Eliminar Foto';
	@override String get photoAdded => 'Foto agregada';
	@override String get processingPhoto => 'Procesando foto...';
	@override String get deleted => 'Avistamiento eliminado';
	@override String get selectDetail => 'Selecciona un avistamiento para ver detalles';
	@override String get export => 'Exportar CSV';
	@override String get exported => 'Avistamientos exportados';
	@override String get noSightingsToExport => 'No hay avistamientos para exportar';
	@override String get filters => 'Filtros';
	@override String get allSpecies => 'Todas las Especies';
	@override String get dateRange => 'Rango de Fechas';
	@override String get from => 'Desde';
	@override String get to => 'Hasta';
	@override String get clearFilters => 'Limpiar Filtros';
	@override String get statistics => 'Estadísticas';
	@override String get totalSightings => 'Total de Avistamientos';
	@override String get uniqueSpecies => 'Especies Únicas';
	@override String get thisMonth => 'Este Mes';
	@override String get withPhotos => 'Con Fotos';
	@override String get calendarView => 'Calendario';
	@override String get listView => 'Lista';
	@override String get noSightingsInMonth => 'Sin avistamientos este mes';
}

// Path: auth
class _TranslationsAuthEs implements TranslationsAuthEn {
	_TranslationsAuthEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get signIn => 'Iniciar Sesión';
	@override String get signUp => 'Registrarse';
	@override String get signOut => 'Cerrar Sesión';
	@override String get email => 'Correo Electrónico';
	@override String get password => 'Contraseña';
	@override String get forgotPassword => '¿Olvidaste tu Contraseña?';
	@override String get noAccount => '¿No tienes cuenta?';
	@override String get hasAccount => '¿Ya tienes cuenta?';
	@override String get continueAsGuest => 'Continuar como Invitado';
	@override String get signInToAccess => 'Inicia sesión para acceder a esta función';
	@override String get profile => 'Mi Perfil';
	@override String memberSince({required Object date}) => 'Miembro desde ${date}';
	@override String get speciesSeen => 'Especies Vistas';
	@override String get islandsVisited => 'Islas Visitadas';
	@override String get photosTaken => 'Fotos Tomadas';
	@override String get level => 'Nivel';
	@override String get beginner => 'Principiante';
	@override String get intermediate => 'Explorador';
	@override String get advanced => 'Naturalista';
	@override String get expert => 'Naturalista Experto';
	@override String get signInSubtitle => 'Guarda favoritos y registra avistamientos';
	@override String get recentActivity => 'Actividad Reciente';
	@override String get signInToViewProfile => 'Inicia sesion para ver tu perfil de exploracion';
	@override String badgesUnlocked({required Object count, required Object total}) => '${count} / ${total} logros desbloqueados';
	@override String get noBadgesYet => 'Sin logros aun';
	@override String get viewAllBadges => 'Ver Todos los Logros';
	@override String get noRecentSightings => 'Sin avistamientos recientes';
	@override String get displayName => 'Nombre';
	@override String get bio => 'Biografía';
	@override String get birthday => 'Cumpleaños';
	@override String get selectBirthday => 'Selecciona tu cumpleaños';
	@override String get selectCountry => 'Buscar país...';
	@override String get country => 'País';
	@override String get editProfile => 'Editar Perfil';
	@override String get saveProfile => 'Guardar Perfil';
	@override String get profileUpdated => 'Perfil actualizado';
	@override String get avatarUpdated => 'Foto de perfil actualizada';
	@override String get tapToChangePhoto => 'Toca para cambiar foto';
	@override String get happyBirthday => '¡Feliz Cumpleaños!';
	@override String get happyBirthdayMessage => '¡Te deseamos un increíble día explorando Galápagos!';
	@override String get signUpPrompt => '¿No tienes cuenta? Regístrate';
}

// Path: settings
class _TranslationsSettingsEs implements TranslationsSettingsEn {
	_TranslationsSettingsEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configuración';
	@override String get language => 'Idioma';
	@override String get english => 'English';
	@override String get spanish => 'Español';
	@override String get offlineData => 'Datos Offline';
	@override String get downloadData => 'Descargar Todos los Datos';
	@override String get clearCache => 'Limpiar Caché';
	@override String get cacheCleared => 'Caché limpiada';
	@override String get about => 'Acerca de';
	@override String get version => 'Versión';
	@override String get credits => 'Créditos';
	@override String get privacyPolicy => 'Política de Privacidad';
	@override String get termsOfService => 'Términos de Servicio';
	@override String get theme => 'Tema';
	@override String get system => 'Sistema';
	@override String get light => 'Claro';
	@override String get dark => 'Oscuro';
	@override String get signedIn => 'Sesión iniciada';
	@override String get lastSynced => 'Última Sincronización';
	@override String get neverSynced => 'Nunca sincronizado';
	@override String get justNow => 'Ahora mismo';
	@override String minutesAgo({required Object minutes}) => 'Hace ${minutes} min';
	@override String hoursAgo({required Object hours}) => 'Hace ${hours}h';
	@override String daysAgo({required Object days}) => 'Hace ${days}d';
	@override String get notifications => 'Notificaciones';
	@override String get badgeNotifications => 'Notificaciones de Logros';
	@override String get badgeNotificationsDesc => 'Mostrar alertas al obtener nuevos logros';
	@override String get sightingReminders => 'Recordatorios de Avistamientos';
	@override String get sightingRemindersDesc => 'Recordatorios para registrar avistamientos';
	@override String get syncAlerts => 'Alertas de Sincronización';
	@override String get syncAlertsDesc => 'Notificar cuando los datos se sincronizan';
	@override String get offlineImages => 'Imágenes Offline';
	@override String get downloadAllImages => 'Descargar Todas las Imágenes';
	@override String get downloadImagesDesc => 'Descargar todas las imágenes de especies para uso offline';
	@override String downloadingImages({required Object current, required Object total}) => 'Descargando imágenes: ${current}/${total}';
	@override String get imagesDownloaded => 'Todas las imágenes descargadas';
	@override String get imageDownloadFailed => 'Error al descargar imágenes';
	@override String estimatedSize({required Object size}) => 'Tamaño estimado: ~${size} MB';
	@override String get imagesAlreadyCached => 'Imágenes ya descargadas';
	@override String get textSize => 'Tamaño de texto';
	@override String get textSizeDesc => 'Ajusta el tamaño del texto en toda la aplicación';
	@override String textSizeCurrent({required Object percent}) => 'Actual: ${percent}%';
	@override String get textSizeSmall => 'Pequeño';
	@override String get textSizeNormal => 'Normal';
	@override String get textSizeLarge => 'Grande';
}

// Path: admin
class _TranslationsAdminEs implements TranslationsAdminEn {
	_TranslationsAdminEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Administración';
	@override String get panel => 'Panel de Admin';
	@override String get panelSubtitle => 'Gestionar especies, islas y contenido';
	@override String get dashboard => 'Panel';
	@override String get species => 'Especies';
	@override String get categories => 'Categorías';
	@override String get islands => 'Islas';
	@override String get visitSites => 'Sitios de Visita';
	@override String get images => 'Imágenes';
	@override String get speciesSites => 'Especies-Sitios';
	@override String get sites => 'Sitios';
	@override String get exitAdmin => 'Salir Admin';
	@override String get newItem => 'Nuevo';
	@override String get editItem => 'Editar';
	@override String get deleteConfirm => '¿Estás seguro de que quieres eliminar este elemento?';
	@override String get deleteWarning => 'Esta acción no se puede deshacer.';
	@override String get saved => 'Guardado exitosamente';
	@override String get deleted => 'Eliminado exitosamente';
	@override String get required => 'Requerido';
	@override String get selectCategory => 'Selecciona una categoría';
	@override String get selectIsland => 'Selecciona una isla';
	@override String get uploadImage => 'Subir Imagen';
	@override String get processing => 'Procesando imagen...';
	@override String get manageContent => 'Gestionar entradas de fauna';
	@override String get manageCategories => 'Categorías de especies';
	@override String get manageIslands => 'Islas de Galápagos';
	@override String get manageSites => 'Ubicaciones de visitantes';
	@override String get manageImages => 'Fotos de especies';
	@override String get manageRelationships => 'Mapeo de ubicaciones';
	@override String get backToHome => 'Volver al inicio';
	@override String get hideMenu => 'Ocultar menú';
	@override String get showMenu => 'Mostrar menú';
	@override String get searchSpecies => 'Buscar por nombre (EN/ES) o nombre científico...';
	@override String noResultsFor({required Object query}) => 'Sin resultados para "${query}"';
	@override String get noSpeciesYet => 'Sin especies aún';
	@override String get noCategoriesYet => 'Sin categorías aún';
	@override String get noIslandsYet => 'Sin islas aún';
	@override String get noVisitSitesYet => 'Sin sitios de visita aún';
	@override String get noImagesYet => 'Sin imágenes aún';
	@override String get noRelationshipsYet => 'Sin relaciones aún';
	@override String get tapAddImages => 'Toca + para agregar imágenes de galería';
	@override String get addRelationship => 'Agregar Relación';
	@override String get selectBothRequired => 'Selecciona especie y sitio';
	@override String get relationshipAdded => 'Relación agregada';
	@override String get imageAdded => 'Imagen agregada';
	@override String get cropImage => 'Recortar Imagen (16:9)';
	@override String get tapToAddImage => 'Toca para agregar imagen (16:9)';
	@override String get changeImage => 'Cambiar';
	@override String get speciesUpdated => 'Especie actualizada';
	@override String get speciesCreated => 'Especie creada';
	@override String get categoryUpdated => 'Categoría actualizada';
	@override String get categoryCreated => 'Categoría creada';
	@override String get islandUpdated => 'Isla actualizada';
	@override String get islandCreated => 'Isla creada';
	@override String get visitSiteUpdated => 'Sitio de visita actualizado';
	@override String get visitSiteCreated => 'Sitio de visita creado';
	@override String get selectIslandRequired => 'Selecciona una isla';
	@override String get selectCategoryRequired => 'Selecciona una categoría';
	@override String get heroImage => 'Imagen Principal';
	@override String get basicInfo => 'Información Básica';
	@override String get commonName => 'Nombre Común';
	@override String get categoryConservation => 'Categoría y Conservación';
	@override String get category => 'Categoría';
	@override String get conservation => 'Conservación';
	@override String get endemic => 'Endémica';
	@override String get physicalChars => 'Características Físicas';
	@override String get weightKg => 'Peso (kg)';
	@override String get sizeCm => 'Tamaño (cm)';
	@override String get populationField => 'Población';
	@override String get lifespanYears => 'Esperanza de Vida (años)';
	@override String get name => 'Nombre';
	@override String get slug => 'Slug';
	@override String get iconName => 'Nombre del Icono';
	@override String get sortOrder => 'Orden';
	@override String get latitude => 'Latitud';
	@override String get longitude => 'Longitud';
	@override String get areaKm2 => 'Área (km²)';
	@override String get island => 'Isla';
	@override String get siteType => 'Tipo de Sitio';
	@override String get frequency => 'Frecuencia';
	@override String get speciesImages => 'Imágenes de Especie';
	@override String get primaryImage => 'Principal';
	@override String get setPrimary => 'Marcar como principal';
	@override String get primarySet => 'Imagen principal establecida';
	@override String get manageImagesBtn => 'Gestionar Imágenes';
	@override String get saveFirstToManageImages => 'Guarda la especie primero, luego gestiona imágenes';
	@override String confirmDeleteNamed({required Object name}) => '¿Estás seguro de que quieres eliminar "${name}"?\n\nEsta acción no se puede deshacer.';
	@override String get unsavedChangesTitle => '¿Descartar cambios?';
	@override String get unsavedChangesMessage => 'Tienes cambios sin guardar. ¿Deseas descartarlos?';
	@override String get discard => 'Descartar';
	@override String get active => 'Activos';
	@override String get trash => 'Papelera';
	@override String get deletePermanently => 'Eliminar permanentemente';
	@override String confirmDeletePermanently({required Object name}) => '¿Eliminar permanentemente "${name}"?\n\nEsta acción no se puede deshacer.';
	@override String get restoreToEdit => 'Restaura el elemento para editarlo';
	@override String itemsSelected({required Object count}) => '${count} seleccionados';
	@override String get restore => 'Restaurar';
	@override String get restored => 'Restaurado exitosamente';
	@override String get deleteSpeciesFromSite => 'Eliminar especie del sitio';
	@override String confirmDeleteSpeciesFromSite({required Object name}) => '¿Eliminar "${name}" de este sitio?';
	@override String get speciesRemovedFromSite => 'Especie eliminada del sitio';
	@override String get speciesAddedToSite => 'Especie agregada al sitio';
	@override String get selectSpeciesRequired => 'Selecciona una especie';
	@override String get speciesAlreadyAssociated => 'Esta especie ya está asociada a este sitio';
	@override String get relationshipAlreadyExists => 'Esta relación especie-sitio ya existe';
	@override String get manageTaxonomy => 'Gestión de Taxonomía';
	@override String get search => 'Buscar...';
	@override String get confirmDeleteTitle => 'Confirmar eliminación';
	@override String confirmDeleteCount({required Object count}) => '¿Eliminar ${count} elementos?';
	@override String confirmDeletePermanentlyCount({required Object count}) => '¿Eliminar permanentemente ${count} elementos? Esta acción no se puede deshacer.';
	@override String inTrash({required Object count}) => '${count} en papelera';
	@override String get emptyTrash => 'La papelera está vacía';
	@override String get deletedLabel => 'Eliminado';
	@override String deletedOn({required Object date}) => 'Eliminado: ${date}';
	@override String get taxonomyClasses => 'Clases';
	@override String get taxonomyOrders => 'Órdenes';
	@override String get taxonomyFamilies => 'Familias';
	@override String get taxonomyGenera => 'Géneros';
	@override String get taxonomySubtitle => 'Clases, órdenes, familias, géneros';
	@override String errorLoadingStats({required Object error}) => 'Error cargando estadísticas: ${error}';
	@override String get sitesWithoutSpecies => 'Sitios sin especies asociadas';
	@override String get speciesWithoutImages => 'Especies sin imágenes';
	@override String get statistics => 'Estadísticas';
	@override String get speciesByCategory => 'Especies por Categoría';
	@override String get noData => 'Sin datos';
	@override String get dataCoverage => 'Cobertura de Datos';
	@override String get visitSitesSection => 'Sitios de Visita';
	@override String get noVisitSitesForIsland => 'No hay sitios de visita para esta isla. Usa la sección "Sitios de Visita" para crear nuevos.';
	@override String get saveIslandFirst => 'Guarda la isla primero para ver sus sitios de visita';
	@override String get unnamed => 'Sin nombre';
	@override String get speciesSection => 'Especies';
	@override String errorLoadingIslands({required Object error}) => 'Error cargando islas: ${error}';
	@override String errorLoadingSpecies({required Object error}) => 'Error cargando especies: ${error}';
	@override String errorLoadingSites({required Object error}) => 'Error cargando sitios: ${error}';
	@override String get tabGeneral => 'General';
	@override String get tabDescription => 'Descripción';
	@override String get location => 'Ubicación';
	@override String get addSpecies => 'Agregar Especie';
	@override String get adding => 'Agregando...';
	@override String get saveSiteFirst => 'Guarda el sitio primero para agregar especies';
	@override String get noSpeciesForSite => 'No hay especies asociadas a este sitio';
	@override String get noTaxonomyClasses => 'Sin clases taxonómicas aún';
	@override String get noOrdersInClass => 'Sin órdenes en esta clase';
	@override String get noFamiliesInOrder => 'Sin familias en este orden';
	@override String get noGeneraInFamily => 'Sin géneros en esta familia';
	@override String get deleteChildrenWarning => 'Esto también eliminará todos los elementos hijos.';
	@override String get siteTypeTrail => 'Sendero';
	@override String get siteTypeBeach => 'Playa';
	@override String get siteTypeSnorkeling => 'Snorkeling';
	@override String get siteTypeDiving => 'Buceo';
	@override String get siteTypeViewpoint => 'Mirador';
	@override String get siteTypeDock => 'Muelle';
	@override String get uploadPicking => 'Seleccionando imagen...';
	@override String get uploadCropping => 'Recortando imagen...';
	@override String get uploadCompressing => 'Comprimiendo imagen...';
	@override String get uploadUploading => 'Subiendo imagen...';
	@override String get uploadGeneratingThumbnail => 'Generando miniatura...';
	@override String get uploadDone => '¡Imagen subida!';
	@override String get uploadError => 'Error al subir imagen';
	@override String get siteCatalogs => 'Clasificaciones';
	@override String get manageCatalogs => 'Tipos, modalidades y actividades';
	@override String get users => 'Usuarios';
	@override String get manageUsers => 'Gestionar acceso y roles';
	@override String get tabDetails => 'Detalles';
	@override String get populationTrend => 'Tendencia Poblacional';
	@override String get trendIncreasing => 'En Aumento';
	@override String get trendStable => 'Estable';
	@override String get trendDecreasing => 'En Descenso';
	@override String get trendUnknown => 'Desconocida';
	@override String get native => 'Nativa';
	@override String get introduced => 'Introducida';
	@override String get endemismLevel => 'Nivel de Endemismo';
	@override String get endemismArchipelago => 'Endémica del Archipiélago';
	@override String get endemismIslandSpecific => 'Endémica de Isla Específica';
	@override String get behavior => 'Comportamiento';
	@override String get socialStructure => 'Estructura Social';
	@override String get socialSolitary => 'Solitario';
	@override String get socialPair => 'Pareja';
	@override String get socialSmallGroup => 'Grupo Pequeño';
	@override String get socialColony => 'Colonia';
	@override String get socialHarem => 'Harén';
	@override String get activityPattern => 'Patrón de Actividad';
	@override String get activityDiurnal => 'Diurno';
	@override String get activityNocturnal => 'Nocturno';
	@override String get activityCrepuscular => 'Crepuscular';
	@override String get dietType => 'Tipo de Dieta';
	@override String get dietCarnivore => 'Carnívoro';
	@override String get dietHerbivore => 'Herbívoro';
	@override String get dietOmnivore => 'Omnívoro';
	@override String get dietInsectivore => 'Insectívoro';
	@override String get dietPiscivore => 'Piscívoro';
	@override String get dietFrugivore => 'Frugívoro';
	@override String get dietNectarivore => 'Nectarívoro';
	@override String get primaryFoodSources => 'Fuentes Principales de Alimento';
	@override String get reproduction => 'Reproducción';
	@override String get breedingSeason => 'Temporada de Cría';
	@override String get clutchSize => 'Tamaño de Postura';
	@override String get reproductiveFrequency => 'Frecuencia Reproductiva';
	@override String get distinguishingFeatures => 'Características Distintivas';
	@override String get distinguishingFeaturesEs => 'Características Distintivas (ES)';
	@override String get distinguishingFeaturesEn => 'Características Distintivas (EN)';
	@override String get sexualDimorphism => 'Dimorfismo Sexual';
	@override String get geographicRanges => 'Rangos Geográficos';
	@override String get altitudeMinM => 'Altitud Mínima (m)';
	@override String get altitudeMaxM => 'Altitud Máxima (m)';
	@override String get depthMinM => 'Profundidad Mínima (m)';
	@override String get depthMaxM => 'Profundidad Máxima (m)';
}

// Path: badges
class _TranslationsBadgesEs implements TranslationsBadgesEn {
	_TranslationsBadgesEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Logros';
	@override String get empty => 'Sin logros aún';
	@override String get emptySubtitle => '¡Empieza a explorar para ganar logros!';
	@override String get unlocked => '¡Desbloqueado!';
	@override String get locked => 'Bloqueado';
	@override String progress({required Object current, required Object target}) => '${current} / ${target}';
	@override String get firstSighting => 'Primer Avistamiento';
	@override String get firstSightingDesc => 'Registra tu primer avistamiento';
	@override String get explorer => 'Explorador';
	@override String get explorerDesc => 'Registra 10 avistamientos';
	@override String get fieldResearcher => 'Investigador de Campo';
	@override String get fieldResearcherDesc => 'Registra 50 avistamientos';
	@override String get naturalist => 'Naturalista';
	@override String get naturalistDesc => 'Avista 5 especies diferentes';
	@override String get biologist => 'Biólogo';
	@override String get biologistDesc => 'Avista 20 especies diferentes';
	@override String get endemicExplorer => 'Explorador Endémico';
	@override String get endemicExplorerDesc => 'Avista 5 especies endémicas';
	@override String get islandHopper => 'Saltaislas';
	@override String get islandHopperDesc => 'Visita 3 islas diferentes';
	@override String get photographer => 'Fotógrafo';
	@override String get photographerDesc => 'Toma 10 fotos de avistamientos';
	@override String get curator => 'Curador';
	@override String get curatorDesc => 'Agrega 10 especies a favoritos';
	@override String get conservationist => 'Conservacionista';
	@override String get conservationistDesc => 'Avista 3 especies amenazadas (CR/EN/VU)';
	@override String get badgeUnlocked => '¡Logro Desbloqueado!';
	@override String youEarned({required Object name}) => 'Has ganado: ${name}';
	@override String get congratulations => '¡Felicidades!';
}

// Path: offline
class _TranslationsOfflineEs implements TranslationsOfflineEn {
	_TranslationsOfflineEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get downloadPacks => 'Paquetes de Descarga por Isla';
	@override String get downloadPack => 'Descargar Paquete de Isla';
	@override String get packageDownloaded => 'Descargado';
	@override String get packages => 'paquetes';
	@override String get downloaded => 'Descargados';
	@override String get available => 'Disponibles para Descargar';
	@override String get packagesInfo => 'Paquetes de Isla';
	@override String get packagesDescription => 'Descarga paquetes completos de isla incluyendo mapas, datos de especies, sitios de visita e imágenes para uso sin conexión.';
	@override String get noPackages => 'No hay paquetes disponibles';
	@override String get downloadConfirmation => '¿Descargar el paquete completo para esta isla?';
	@override String get downloadWarning => 'Esto descargará mapas e imágenes. Asegúrate de tener una conexión estable a internet.';
	@override String get download => 'Descargar';
	@override String get downloading => 'Descargando';
	@override String get syncStatus => 'Estado de Sincronización';
	@override String get online => 'En línea';
	@override String get offline => 'Sin conexión';
	@override String get lastSynced => 'Última sincronización';
	@override String get pending => 'Pendientes';
	@override String get allSynced => 'Todo sincronizado';
	@override String get syncNow => 'Sincronizar Ahora';
}

// Path: common
class _TranslationsCommonEs implements TranslationsCommonEn {
	_TranslationsCommonEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Cargando...';
	@override String get error => 'Algo salió mal';
	@override String get retry => 'Reintentar';
	@override String get cancel => 'Cancelar';
	@override String get confirm => 'Confirmar';
	@override String get delete => 'Eliminar';
	@override String get save => 'Guardar';
	@override String get edit => 'Editar';
	@override String get close => 'Cerrar';
	@override String get ok => 'OK';
	@override String get yes => 'Sí';
	@override String get no => 'No';
	@override String get add => 'Agregar';
	@override String get clearSearch => 'Limpiar búsqueda';
	@override String items({required Object count}) => '${count} elementos';
	@override String get unsavedChangesTitle => 'Cambios sin guardar';
	@override String get unsavedChangesMessage => 'Tienes cambios sin guardar. ¿Descartarlos?';
	@override String get discard => 'Descartar';
	@override String get refresh => 'Actualizar';
	@override String get images => 'imágenes';
	@override String get offline => 'Estás sin conexión';
	@override String get offlineSubtitle => 'Algunas funciones pueden estar limitadas';
	@override String get offlineMode => 'Modo Sin Conexión';
	@override String get offlineMessage => 'Trabajando con datos en caché';
	@override String get details => 'Detalles Técnicos';
}

// Path: error
class _TranslationsErrorEs implements TranslationsErrorEn {
	_TranslationsErrorEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get network => 'Sin Conexión a Internet';
	@override String get networkDesc => 'Por favor verifica tu conexión a internet e intenta nuevamente.';
	@override String get timeout => 'Tiempo de Espera Agotado';
	@override String get timeoutDesc => 'La solicitud tomó demasiado tiempo. Por favor intenta más tarde.';
	@override String get parsing => 'Error de Datos';
	@override String get parsingDesc => 'No se pueden procesar los datos. Por favor intenta nuevamente o contacta soporte.';
	@override String get authentication => 'Error de Autenticación';
	@override String get authenticationDesc => 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.';
	@override String get notFound => 'No Encontrado';
	@override String get notFoundDesc => 'El recurso solicitado no fue encontrado.';
	@override String get serverError => 'Error del Servidor';
	@override String get serverErrorDesc => 'El servidor está experimentando problemas. Por favor intenta más tarde.';
	@override String get unknownDesc => 'Ocurrió un error inesperado. Por favor intenta nuevamente.';
}

// Path: sync
class _TranslationsSyncEs implements TranslationsSyncEn {
	_TranslationsSyncEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Fauna de Galápagos';
	@override String downloading({required Object table}) => 'Descargando ${table}...';
	@override String get preparing => 'Preparando...';
	@override String get errorTitle => 'No se pudieron descargar los datos.';
	@override String get errorSubtitle => 'Por favor verifica tu conexión a internet.';
	@override String get retry => 'Reintentar';
}

// Path: location
class _TranslationsLocationEs implements TranslationsLocationEn {
	_TranslationsLocationEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get servicesDisabled => 'Los servicios de ubicación están desactivados';
	@override String get permissionDenied => 'Permiso de ubicación denegado';
	@override String get locationObtained => 'Ubicación obtenida';
}

// Path: onboarding
class _TranslationsOnboardingEs implements TranslationsOnboardingEn {
	_TranslationsOnboardingEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Bienvenido a Fauna de Galápagos';
	@override String get discoverTitle => 'Descubre la Fauna';
	@override String get discoverDesc => 'Explora más de 40 especies de aves, reptiles, mamíferos y vida marina únicas de las islas';
	@override String get mapTitle => 'Explora las Islas';
	@override String get mapDesc => 'Mapa interactivo con islas, sitios de visita y soporte para mapas offline';
	@override String get sightingsTitle => 'Registra Avistamientos';
	@override String get sightingsDesc => 'Registra tus encuentros con la fauna con fotos, ubicación y notas';
	@override String get badgesTitle => 'Gana Logros';
	@override String get badgesDesc => 'Sigue tu progreso y desbloquea logros mientras exploras';
	@override String get getStarted => 'Comenzar';
	@override String get next => 'Siguiente';
	@override String get skip => 'Omitir';
}

// Path: search
class _TranslationsSearchEs implements TranslationsSearchEn {
	_TranslationsSearchEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Buscar';
	@override String get hint => 'Buscar especies, islas, sitios...';
	@override String get noResults => 'Sin resultados';
	@override String get noResultsSubtitle => 'Intenta con otro término de búsqueda';
	@override String get speciesSection => 'Especies';
	@override String get islandsSection => 'Islas';
	@override String get sitesSection => 'Sitios de Visita';
}

// Path: leaderboard
class _TranslationsLeaderboardEs implements TranslationsLeaderboardEn {
	_TranslationsLeaderboardEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tabla de Posiciones';
	@override String get rank => 'Posicion';
	@override String get sightings => 'Avistamientos';
	@override String get species => 'Especies';
	@override String get photos => 'Fotos';
	@override String get you => 'Tu';
	@override String get empty => 'Sin avistamientos registrados aun. Se el primero!';
	@override String get topExplorer => 'Explorador Principal';
}

// Path: share
class _TranslationsShareEs implements TranslationsShareEn {
	_TranslationsShareEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get species => 'Compartir especie';
	@override String shareText({required Object name, required Object scientificName}) => '¡Mira ${name} (${scientificName}) en Fauna de Galápagos!';
	@override String get copiedToClipboard => 'Copiado al portapapeles';
}

// Path: celebrations
class _TranslationsCelebrationsEs implements TranslationsCelebrationsEn {
	_TranslationsCelebrationsEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Celebraciones';
	@override String todayEvent({required Object event}) => 'Hoy: ${event}';
	@override String get birthdayOverlay => '¡Es tu cumpleaños!';
}

// Path: errors
class _TranslationsErrorsEs implements TranslationsErrorsEn {
	_TranslationsErrorsEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get network => 'Sin conexión a internet. Revisa tu red.';
	@override String get timeout => 'La solicitud ha caducado. Intenta de nuevo.';
	@override String get auth => 'Error de autenticación. Inicia sesión nuevamente.';
	@override String get storage => 'Error de almacenamiento. Intenta de nuevo.';
	@override String get validation => 'Revisa los datos ingresados.';
	@override String get unknown => 'Ocurrió un error inesperado.';
	@override String get tryAgain => 'Reintentar';
}

// Path: fieldEdit
class _TranslationsFieldEditEs implements TranslationsFieldEditEn {
	_TranslationsFieldEditEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edición de Campo';
	@override String get mode => 'Modo de Edición de Campo';
	@override String get moveVisitSite => 'Mover Sitio de Visita';
	@override String get editTrail => 'Editar Sendero';
	@override String get createNewTrail => 'Crear Nuevo Sendero';
	@override String get howToMoveSite => '¿Cómo mover el sitio?';
	@override String get dragOnMap => 'Arrastrar en el Mapa';
	@override String get dragOnMapDesc => 'Todos los marcadores se vuelven arrastrables — arrastra cualquiera a su posición correcta';
	@override String get useCurrentGps => 'Usar Ubicación GPS Actual';
	@override String get useCurrentGpsDesc => 'Toca un marcador de sitio para moverlo a tu posición actual';
	@override String get howToEditTrail => '¿Cómo editar el sendero?';
	@override String get editOnMap => 'Editar en el Mapa';
	@override String get editOnMapDesc => 'Toca un sendero, luego agrega/elimina puntos';
	@override String get walkRecordGps => 'Caminar y Grabar GPS';
	@override String get walkRecordGpsDesc => 'Re-grabar el sendero caminando la ruta';
	@override String get howToCreateTrail => '¿Cómo crear el sendero?';
	@override String get drawOnMap => 'Dibujar en el Mapa';
	@override String get drawOnMapDesc => 'Toca el mapa para agregar puntos, arrastra para ajustar';
	@override String get walkRecordGpsNewDesc => 'Seguimiento GPS mientras caminas la ruta';
	@override String get correctSiteLocation => 'Corregir ubicación del sitio';
	@override String get correctTrailPath => 'Corregir trazado del sendero';
	@override String get drawOnMapOrGps => 'Dibujar en mapa o seguimiento GPS';
	@override String get dragAnySiteToMove => 'Arrastra cualquier marcador de sitio para moverlo';
	@override String get tapSiteToMoveToCurrentLocation => 'Toca un marcador de sitio para moverlo a tu ubicación actual';
	@override String get tapTrailToStartEditing => 'Toca un sendero para empezar a editarlo';
	@override String get tapTrailThenWalk => 'Toca un sendero, luego camina para re-grabar';
	@override String get tapMapToAddPoints => 'Toca el mapa para agregar puntos al sendero';
	@override String get discardChanges => '¿Descartar cambios?';
	@override String get discardChangesMessage => 'Tienes cambios sin guardar. ¿Descartarlos?';
	@override String get keepEditing => 'Seguir editando';
	@override String get discard => 'Descartar';
	@override String get doneEditing => '¿Finalizar edición?';
	@override String get sitesSaved => 'Las posiciones de los sitios han sido guardadas en el servidor.';
	@override String get saveNewTrail => 'Guardar Nuevo Sendero';
	@override String get trailNameEn => 'Nombre del Sendero (Inglés)';
	@override String get trailNameEnHint => 'ej., Tortuga Bay Trail';
	@override String get trailNameEs => 'Nombre del Sendero (Español)';
	@override String get trailNameEsHint => 'ej., Sendero Bahía Tortuga';
	@override String get continueRecording => 'Continuar Grabando';
	@override String get saveTrail => 'Guardar';
	@override String get needTwoPoints => 'Se necesitan al menos 2 puntos para guardar el sendero';
	@override String get enterBothTrailNames => 'Por favor ingresa los nombres del sendero en ambos idiomas';
	@override String get saveTrailChanges => 'Guardar Cambios del Sendero';
	@override String get saveTrailChangesDesc => 'Esto reemplazará el trazado existente del sendero con las coordenadas editadas.';
	@override String get continueEditing => 'Continuar Editando';
	@override String get saveChanges => 'Guardar Cambios';
	@override String get movingSitesDrag => 'Moviendo Sitios — arrastra cualquier marcador';
	@override String get movingSiteManual => 'Moviendo Sitio (Arrastrar)';
	@override String get movingSiteGps => 'Moviendo Sitio (GPS)';
	@override String get tapTrailToEdit => 'Toca un sendero para editar';
	@override String get editingTrail => 'Editando Sendero';
	@override String get recordingTrailGps => 'Grabando Sendero (GPS)';
	@override String get creatingTrail => 'Creando Sendero';
	@override String get recordingNewTrailGps => 'Grabando Nuevo Sendero (GPS)';
	@override String get pauseRecording => 'Pausar';
	@override String get resumeRecording => 'Reanudar';
	@override String get stopAndSave => 'Detener y Guardar';
	@override String get editTrailInfo => 'Editar información';
	@override String get undo => 'Deshacer';
	@override String get cancel => 'Cancelar';
	@override String get save => 'Guardar';
	@override String deletePoint({required Object number}) => 'Borrar punto ${number}';
	@override String deletePoints({required Object count}) => 'Borrar ${count} puntos';
	@override String get tapPointsDragToMove => 'Toca punto(s) • arrastrar mueve selección';
	@override String get subModePoints => 'Puntos';
	@override String get subModeMove => 'Mover';
	@override String get subModeRotate => 'Rotar';
}

// Path: species.frequency
class _TranslationsSpeciesFrequencyEs implements TranslationsSpeciesFrequencyEn {
	_TranslationsSpeciesFrequencyEs._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get common => 'Común';
	@override String get uncommon => 'Poco común';
	@override String get rare => 'Rara';
	@override String get occasional => 'Ocasional';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Fauna de Galápagos',
			'app.subtitle' => 'Explora las islas encantadas',
			'nav.home' => 'Inicio',
			'nav.species' => 'Especies',
			'nav.map' => 'Mapa',
			'nav.favorites' => 'Favoritos',
			'nav.sightings' => 'Avistamientos',
			'home.welcome' => 'Bienvenido a Galápagos',
			'home.explore' => 'Explorar Fauna',
			'home.categories' => 'Categorías',
			'home.featured' => 'Especies Destacadas',
			'home.quickLinks' => 'Accesos Rápidos',
			'home.viewAll' => 'Ver Todo',
			'home.discoverSpecies' => 'Descubrir Especies',
			'home.exploreMap' => 'Explorar el Mapa',
			'home.recentSightings' => 'Avistamientos Recientes',
			'home.browseWildlife' => 'Explorar toda la fauna',
			'home.findSites' => 'Encontrar sitios de visita e islas',
			'home.logEncounters' => 'Registra tus encuentros con la fauna',
			'species.title' => 'Especies',
			'species.search' => 'Buscar especies...',
			'species.all' => 'Todas',
			'species.endemic' => 'Endémica',
			'species.conservationStatus' => 'Estado de Conservación',
			'species.scientificName' => 'Nombre Científico',
			'species.weight' => 'Peso',
			'species.size' => 'Tamaño',
			'species.population' => 'Población',
			'species.lifespan' => 'Esperanza de Vida',
			'species.habitat' => 'Hábitat',
			'species.description' => 'Descripción',
			'species.whereToSee' => 'Dónde Verla',
			'species.gallery' => 'Galería',
			'species.quickFacts' => 'Datos Rápidos',
			'species.conservationStatusLabel' => ({required Object status}) => 'Estado de conservación: ${status}',
			'species.years' => 'años',
			'species.kg' => 'kg',
			'species.cm' => 'cm',
			'species.individuals' => 'individuos',
			'species.taxonomy' => 'Taxonomía',
			'species.kingdom' => 'Reino',
			'species.phylum' => 'Filo',
			'species.classLabel' => 'Clase',
			'species.order' => 'Orden',
			'species.family' => 'Familia',
			'species.genus' => 'Género',
			'species.noResults' => 'No se encontraron especies',
			'species.noResultsSubtitle' => 'Intenta con un término diferente',
			'species.noImages' => 'Sin imágenes adicionales',
			'species.addToFavorites' => 'Agregar a favoritos',
			'species.removeFromFavorites' => 'Quitar de favoritos',
			'species.notFound' => 'Especie no encontrada',
			'species.clearFilters' => 'Limpiar',
			'species.categoryFilter' => 'Categoría',
			'species.conservationFilter' => 'Conservación y Endémica',
			'species.filterHelp' => 'Cómo funcionan los filtros',
			'species.filterHelpText' => 'Los filtros se combinan para refinar resultados. Selecciona una categoría, estado de conservación o endémica para filtrar especies.',
			'species.compare' => 'Comparar',
			'species.compareSpecies' => 'Comparar Especies',
			'species.selectTwoSpecies' => 'Selecciona dos especies para comparar',
			'species.vsLabel' => 'VS',
			'species.featuredImageLabel' => ({required Object name}) => 'Destacada: ${name}, toca para ver detalles',
			'species.galleryImageLabel' => ({required Object index, required Object total}) => 'Imagen de galería ${index} de ${total}',
			'species.fullscreenImageLabel' => ({required Object index, required Object total}) => 'Imagen ${index} de ${total}',
			'species.thumbnailLabel' => ({required Object index}) => 'Miniatura ${index}, toca para ver imagen completa',
			'species.frequency.common' => 'Común',
			'species.frequency.uncommon' => 'Poco común',
			'species.frequency.rare' => 'Rara',
			'species.frequency.occasional' => 'Ocasional',
			'conservation.EX' => 'Extinta',
			'conservation.EW' => 'Extinta en Estado Silvestre',
			'conservation.CR' => 'En Peligro Crítico',
			'conservation.EN' => 'En Peligro',
			'conservation.VU' => 'Vulnerable',
			'conservation.NT' => 'Casi Amenazada',
			'conservation.LC' => 'Preocupación Menor',
			'conservation.DD' => 'Datos Insuficientes',
			'conservation.NE' => 'No Evaluada',
			'map.title' => 'Mapa de Galápagos',
			'map.islands' => 'Islas',
			'map.visitSites' => 'Sitios de Visita',
			'map.speciesHere' => 'Especies aquí',
			'map.directions' => 'Cómo Llegar',
			'map.offlineTiles' => 'Mapa Offline',
			'map.downloadTiles' => 'Descargar Mapa',
			'map.downloading' => 'Descargando mapa...',
			'map.downloadComplete' => 'Mapa descargado',
			'map.downloadInProgress' => 'Descarga en progreso...',
			'map.tilesInfo' => 'Descarga el mapa para uso sin conexión',
			'map.toggleSites' => 'Mostrar/ocultar sitios de visita',
			'map.goToMyLocation' => 'Ir a mi ubicación',
			'map.locatingDevice' => 'Localizando dispositivo...',
			'map.centerOnGalapagos' => 'Centrar en Galápagos',
			'map.cachedTiles' => 'Tiles en caché',
			'map.cacheSize' => 'Tamaño de caché',
			'map.mb' => 'MB',
			'map.downloadForOffline' => 'Descargar para uso offline',
			'map.estimatedTiles' => ({required Object count}) => 'Tiles estimados: ${count}',
			'map.downloadCancelled' => 'Descarga cancelada',
			'map.islandArea' => ({required Object area}) => 'Área: ${area} km²',
			'map.yourLocation' => 'Tu ubicación actual',
			'map.islandLabel' => ({required Object name}) => 'Isla: ${name}',
			'map.visitSiteLabel' => ({required Object name}) => 'Sitio de visita: ${name}',
			'map.sightings' => 'Avistamientos',
			'map.toggleSightings' => 'Mostrar/ocultar avistamientos',
			'map.sightingLabel' => ({required Object species}) => 'Avistamiento: ${species}',
			'map.trails' => 'Senderos',
			'map.toggleTrails' => 'Mostrar/ocultar senderos',
			'map.trailLabel' => ({required Object name}) => 'Sendero: ${name}',
			'map.trailDifficulty' => 'Dificultad',
			'map.trailDistance' => ({required Object km}) => '${km} km',
			'map.trailDuration' => ({required Object min}) => '${min} min',
			'map.difficultyEasy' => 'Fácil',
			'map.difficultyModerate' => 'Moderado',
			'map.difficultyHard' => 'Difícil',
			'map.downloadByIsland' => 'Descargar por Isla',
			'map.downloadAll' => 'Descargar Todo Galápagos',
			'map.selectIslands' => 'Selecciona islas para descargar',
			'map.downloadSelected' => 'Descargar Seleccionadas',
			'map.zoomLevel' => 'Nivel de detalle',
			'map.zoomBasic' => 'Básico (menos datos)',
			'map.zoomDetailed' => 'Detallado (más datos)',
			'map.deleteTiles' => 'Eliminar Tiles',
			'map.tilesDeleted' => 'Tiles eliminados',
			'map.tracking' => 'Seguimiento',
			'map.startTracking' => 'Iniciar Seguimiento',
			'map.stopTracking' => 'Detener Seguimiento',
			'map.trackRecorded' => 'Recorrido grabado',
			'map.offRoute' => '¡Te has salido del sendero!',
			'map.backOnRoute' => 'De vuelta en el sendero',
			'map.distanceFromTrail' => ({required Object meters}) => '${meters}m del sendero',
			'map.trackDistance' => ({required Object km}) => 'Distancia: ${km} km',
			'map.trackDuration' => ({required Object duration}) => 'Duración: ${duration}',
			'map.noTrails' => 'No hay senderos disponibles',
			'map.baseMap' => 'Mapa Base',
			'map.baseMapVector' => 'Vectorial (3 MB)',
			'map.baseMapRaster' => 'Ráster HD',
			'map.downloadBaseMap' => 'Descargar Mapa Base',
			'map.downloadingBaseMap' => 'Descargando mapa base...',
			'map.baseMapReady' => 'Mapa base listo',
			'map.baseMapNotDownloaded' => 'Mapa base no descargado',
			'map.deleteBaseMap' => 'Eliminar Mapa Base',
			'map.baseMapDeleted' => 'Mapa base eliminado',
			'map.switchToVector' => 'Cambiar a Vectorial',
			'map.switchToRaster' => 'Cambiar a Ráster HD',
			'map.hdTiles' => 'Tiles Ráster HD',
			'map.downloadHdArea' => 'Descargar HD para esta zona',
			'map.downloadingHdArea' => 'Descargando tiles HD...',
			'map.hdAreaDownloaded' => 'Tiles HD descargados para esta zona',
			'map.mapMode' => 'Modo de Mapa',
			'map.vectorOffline' => 'Vectorial Offline',
			'map.rasterOnline' => 'Ráster HD',
			'map.switchMapMode' => 'Cambiar modo de mapa',
			'map.mapModes' => 'Modos de Mapa',
			'map.modeStreet' => 'Mapa Callejero',
			'map.modeStreetDesc' => 'OpenStreetMap con caché offline',
			'map.modeVector' => 'Mapa Vectorial',
			'map.modeVectorDesc' => 'Tiles vectoriales offline ligeros (3 MB)',
			'map.modeSatellite' => 'Satélite',
			'map.modeSatelliteDesc' => 'Imágenes satelitales de alta resolución (ESRI)',
			'map.modeHybrid' => 'Híbrido',
			'map.modeHybridDesc' => 'Imágenes satelitales con etiquetas',
			'map.loginRequiredForSatellite' => 'Requiere iniciar sesión para vista satelital',
			'map.filterSites' => 'Filtrar sitios',
			'map.filterVisitSites' => 'Filtrar sitios de visita',
			'favorites.title' => 'Favoritos',
			'favorites.empty' => 'Sin favoritos aún',
			'favorites.emptySubtitle' => 'Toca el corazón en cualquier especie para agregarla aquí',
			'favorites.added' => 'Agregado a favoritos',
			'favorites.removed' => 'Eliminado de favoritos',
			'favorites.loginRequired' => 'Inicia sesión para guardar favoritos',
			'sightings.sightingPhoto' => 'Foto del avistamiento',
			'sightings.title' => 'Mis Avistamientos',
			'sightings.add' => 'Agregar Avistamiento',
			'sightings.empty' => 'Sin avistamientos aún',
			'sightings.emptySubtitle' => 'Registra tus encuentros con la fauna',
			'sightings.selectSpecies' => 'Seleccionar Especie',
			'sightings.selectSite' => 'Seleccionar Sitio de Visita',
			'sightings.date' => 'Fecha',
			'sightings.notes' => 'Notas',
			'sightings.notesHint' => '¿Qué observaste?',
			'sightings.photo' => 'Foto',
			'sightings.addPhoto' => 'Agregar Foto',
			'sightings.location' => 'Ubicación',
			'sightings.useCurrentLocation' => 'Usar Ubicación Actual',
			'sightings.save' => 'Guardar Avistamiento',
			'sightings.saved' => 'Avistamiento guardado',
			'sightings.delete' => 'Eliminar Avistamiento',
			'sightings.deleteConfirm' => '¿Estás seguro de que quieres eliminar este avistamiento?',
			'sightings.loginRequired' => 'Inicia sesión para registrar avistamientos',
			'sightings.pendingSync' => 'Pendiente de sincronizar',
			'sightings.takePhoto' => 'Tomar Foto',
			'sightings.fromGallery' => 'Elegir de Galería',
			'sightings.changePhoto' => 'Cambiar Foto',
			'sightings.removePhoto' => 'Eliminar Foto',
			'sightings.photoAdded' => 'Foto agregada',
			'sightings.processingPhoto' => 'Procesando foto...',
			'sightings.deleted' => 'Avistamiento eliminado',
			'sightings.selectDetail' => 'Selecciona un avistamiento para ver detalles',
			'sightings.export' => 'Exportar CSV',
			'sightings.exported' => 'Avistamientos exportados',
			'sightings.noSightingsToExport' => 'No hay avistamientos para exportar',
			'sightings.filters' => 'Filtros',
			'sightings.allSpecies' => 'Todas las Especies',
			'sightings.dateRange' => 'Rango de Fechas',
			'sightings.from' => 'Desde',
			'sightings.to' => 'Hasta',
			'sightings.clearFilters' => 'Limpiar Filtros',
			'sightings.statistics' => 'Estadísticas',
			'sightings.totalSightings' => 'Total de Avistamientos',
			'sightings.uniqueSpecies' => 'Especies Únicas',
			'sightings.thisMonth' => 'Este Mes',
			'sightings.withPhotos' => 'Con Fotos',
			'sightings.calendarView' => 'Calendario',
			'sightings.listView' => 'Lista',
			'sightings.noSightingsInMonth' => 'Sin avistamientos este mes',
			'auth.signIn' => 'Iniciar Sesión',
			'auth.signUp' => 'Registrarse',
			'auth.signOut' => 'Cerrar Sesión',
			'auth.email' => 'Correo Electrónico',
			'auth.password' => 'Contraseña',
			'auth.forgotPassword' => '¿Olvidaste tu Contraseña?',
			'auth.noAccount' => '¿No tienes cuenta?',
			'auth.hasAccount' => '¿Ya tienes cuenta?',
			'auth.continueAsGuest' => 'Continuar como Invitado',
			'auth.signInToAccess' => 'Inicia sesión para acceder a esta función',
			'auth.profile' => 'Mi Perfil',
			'auth.memberSince' => ({required Object date}) => 'Miembro desde ${date}',
			'auth.speciesSeen' => 'Especies Vistas',
			'auth.islandsVisited' => 'Islas Visitadas',
			'auth.photosTaken' => 'Fotos Tomadas',
			'auth.level' => 'Nivel',
			'auth.beginner' => 'Principiante',
			'auth.intermediate' => 'Explorador',
			'auth.advanced' => 'Naturalista',
			'auth.expert' => 'Naturalista Experto',
			'auth.signInSubtitle' => 'Guarda favoritos y registra avistamientos',
			'auth.recentActivity' => 'Actividad Reciente',
			'auth.signInToViewProfile' => 'Inicia sesion para ver tu perfil de exploracion',
			'auth.badgesUnlocked' => ({required Object count, required Object total}) => '${count} / ${total} logros desbloqueados',
			'auth.noBadgesYet' => 'Sin logros aun',
			'auth.viewAllBadges' => 'Ver Todos los Logros',
			'auth.noRecentSightings' => 'Sin avistamientos recientes',
			'auth.displayName' => 'Nombre',
			'auth.bio' => 'Biografía',
			'auth.birthday' => 'Cumpleaños',
			'auth.selectBirthday' => 'Selecciona tu cumpleaños',
			'auth.selectCountry' => 'Buscar país...',
			'auth.country' => 'País',
			'auth.editProfile' => 'Editar Perfil',
			'auth.saveProfile' => 'Guardar Perfil',
			'auth.profileUpdated' => 'Perfil actualizado',
			'auth.avatarUpdated' => 'Foto de perfil actualizada',
			'auth.tapToChangePhoto' => 'Toca para cambiar foto',
			'auth.happyBirthday' => '¡Feliz Cumpleaños!',
			'auth.happyBirthdayMessage' => '¡Te deseamos un increíble día explorando Galápagos!',
			'auth.signUpPrompt' => '¿No tienes cuenta? Regístrate',
			'settings.title' => 'Configuración',
			'settings.language' => 'Idioma',
			'settings.english' => 'English',
			'settings.spanish' => 'Español',
			'settings.offlineData' => 'Datos Offline',
			'settings.downloadData' => 'Descargar Todos los Datos',
			'settings.clearCache' => 'Limpiar Caché',
			'settings.cacheCleared' => 'Caché limpiada',
			'settings.about' => 'Acerca de',
			'settings.version' => 'Versión',
			'settings.credits' => 'Créditos',
			'settings.privacyPolicy' => 'Política de Privacidad',
			'settings.termsOfService' => 'Términos de Servicio',
			'settings.theme' => 'Tema',
			'settings.system' => 'Sistema',
			'settings.light' => 'Claro',
			'settings.dark' => 'Oscuro',
			'settings.signedIn' => 'Sesión iniciada',
			'settings.lastSynced' => 'Última Sincronización',
			'settings.neverSynced' => 'Nunca sincronizado',
			'settings.justNow' => 'Ahora mismo',
			'settings.minutesAgo' => ({required Object minutes}) => 'Hace ${minutes} min',
			'settings.hoursAgo' => ({required Object hours}) => 'Hace ${hours}h',
			'settings.daysAgo' => ({required Object days}) => 'Hace ${days}d',
			'settings.notifications' => 'Notificaciones',
			'settings.badgeNotifications' => 'Notificaciones de Logros',
			'settings.badgeNotificationsDesc' => 'Mostrar alertas al obtener nuevos logros',
			'settings.sightingReminders' => 'Recordatorios de Avistamientos',
			'settings.sightingRemindersDesc' => 'Recordatorios para registrar avistamientos',
			'settings.syncAlerts' => 'Alertas de Sincronización',
			'settings.syncAlertsDesc' => 'Notificar cuando los datos se sincronizan',
			'settings.offlineImages' => 'Imágenes Offline',
			'settings.downloadAllImages' => 'Descargar Todas las Imágenes',
			'settings.downloadImagesDesc' => 'Descargar todas las imágenes de especies para uso offline',
			'settings.downloadingImages' => ({required Object current, required Object total}) => 'Descargando imágenes: ${current}/${total}',
			'settings.imagesDownloaded' => 'Todas las imágenes descargadas',
			'settings.imageDownloadFailed' => 'Error al descargar imágenes',
			'settings.estimatedSize' => ({required Object size}) => 'Tamaño estimado: ~${size} MB',
			'settings.imagesAlreadyCached' => 'Imágenes ya descargadas',
			'settings.textSize' => 'Tamaño de texto',
			'settings.textSizeDesc' => 'Ajusta el tamaño del texto en toda la aplicación',
			'settings.textSizeCurrent' => ({required Object percent}) => 'Actual: ${percent}%',
			'settings.textSizeSmall' => 'Pequeño',
			'settings.textSizeNormal' => 'Normal',
			'settings.textSizeLarge' => 'Grande',
			'admin.title' => 'Administración',
			'admin.panel' => 'Panel de Admin',
			'admin.panelSubtitle' => 'Gestionar especies, islas y contenido',
			'admin.dashboard' => 'Panel',
			'admin.species' => 'Especies',
			'admin.categories' => 'Categorías',
			'admin.islands' => 'Islas',
			'admin.visitSites' => 'Sitios de Visita',
			'admin.images' => 'Imágenes',
			'admin.speciesSites' => 'Especies-Sitios',
			'admin.sites' => 'Sitios',
			'admin.exitAdmin' => 'Salir Admin',
			'admin.newItem' => 'Nuevo',
			'admin.editItem' => 'Editar',
			'admin.deleteConfirm' => '¿Estás seguro de que quieres eliminar este elemento?',
			'admin.deleteWarning' => 'Esta acción no se puede deshacer.',
			'admin.saved' => 'Guardado exitosamente',
			'admin.deleted' => 'Eliminado exitosamente',
			'admin.required' => 'Requerido',
			'admin.selectCategory' => 'Selecciona una categoría',
			'admin.selectIsland' => 'Selecciona una isla',
			'admin.uploadImage' => 'Subir Imagen',
			'admin.processing' => 'Procesando imagen...',
			'admin.manageContent' => 'Gestionar entradas de fauna',
			'admin.manageCategories' => 'Categorías de especies',
			'admin.manageIslands' => 'Islas de Galápagos',
			'admin.manageSites' => 'Ubicaciones de visitantes',
			'admin.manageImages' => 'Fotos de especies',
			'admin.manageRelationships' => 'Mapeo de ubicaciones',
			'admin.backToHome' => 'Volver al inicio',
			'admin.hideMenu' => 'Ocultar menú',
			'admin.showMenu' => 'Mostrar menú',
			'admin.searchSpecies' => 'Buscar por nombre (EN/ES) o nombre científico...',
			'admin.noResultsFor' => ({required Object query}) => 'Sin resultados para "${query}"',
			'admin.noSpeciesYet' => 'Sin especies aún',
			'admin.noCategoriesYet' => 'Sin categorías aún',
			'admin.noIslandsYet' => 'Sin islas aún',
			'admin.noVisitSitesYet' => 'Sin sitios de visita aún',
			'admin.noImagesYet' => 'Sin imágenes aún',
			'admin.noRelationshipsYet' => 'Sin relaciones aún',
			'admin.tapAddImages' => 'Toca + para agregar imágenes de galería',
			'admin.addRelationship' => 'Agregar Relación',
			'admin.selectBothRequired' => 'Selecciona especie y sitio',
			'admin.relationshipAdded' => 'Relación agregada',
			'admin.imageAdded' => 'Imagen agregada',
			'admin.cropImage' => 'Recortar Imagen (16:9)',
			'admin.tapToAddImage' => 'Toca para agregar imagen (16:9)',
			'admin.changeImage' => 'Cambiar',
			'admin.speciesUpdated' => 'Especie actualizada',
			'admin.speciesCreated' => 'Especie creada',
			'admin.categoryUpdated' => 'Categoría actualizada',
			'admin.categoryCreated' => 'Categoría creada',
			'admin.islandUpdated' => 'Isla actualizada',
			'admin.islandCreated' => 'Isla creada',
			'admin.visitSiteUpdated' => 'Sitio de visita actualizado',
			'admin.visitSiteCreated' => 'Sitio de visita creado',
			'admin.selectIslandRequired' => 'Selecciona una isla',
			'admin.selectCategoryRequired' => 'Selecciona una categoría',
			'admin.heroImage' => 'Imagen Principal',
			'admin.basicInfo' => 'Información Básica',
			'admin.commonName' => 'Nombre Común',
			'admin.categoryConservation' => 'Categoría y Conservación',
			'admin.category' => 'Categoría',
			'admin.conservation' => 'Conservación',
			'admin.endemic' => 'Endémica',
			'admin.physicalChars' => 'Características Físicas',
			'admin.weightKg' => 'Peso (kg)',
			'admin.sizeCm' => 'Tamaño (cm)',
			'admin.populationField' => 'Población',
			'admin.lifespanYears' => 'Esperanza de Vida (años)',
			'admin.name' => 'Nombre',
			'admin.slug' => 'Slug',
			'admin.iconName' => 'Nombre del Icono',
			'admin.sortOrder' => 'Orden',
			'admin.latitude' => 'Latitud',
			'admin.longitude' => 'Longitud',
			'admin.areaKm2' => 'Área (km²)',
			'admin.island' => 'Isla',
			'admin.siteType' => 'Tipo de Sitio',
			'admin.frequency' => 'Frecuencia',
			'admin.speciesImages' => 'Imágenes de Especie',
			'admin.primaryImage' => 'Principal',
			'admin.setPrimary' => 'Marcar como principal',
			'admin.primarySet' => 'Imagen principal establecida',
			'admin.manageImagesBtn' => 'Gestionar Imágenes',
			'admin.saveFirstToManageImages' => 'Guarda la especie primero, luego gestiona imágenes',
			'admin.confirmDeleteNamed' => ({required Object name}) => '¿Estás seguro de que quieres eliminar "${name}"?\n\nEsta acción no se puede deshacer.',
			'admin.unsavedChangesTitle' => '¿Descartar cambios?',
			'admin.unsavedChangesMessage' => 'Tienes cambios sin guardar. ¿Deseas descartarlos?',
			'admin.discard' => 'Descartar',
			'admin.active' => 'Activos',
			'admin.trash' => 'Papelera',
			'admin.deletePermanently' => 'Eliminar permanentemente',
			'admin.confirmDeletePermanently' => ({required Object name}) => '¿Eliminar permanentemente "${name}"?\n\nEsta acción no se puede deshacer.',
			'admin.restoreToEdit' => 'Restaura el elemento para editarlo',
			'admin.itemsSelected' => ({required Object count}) => '${count} seleccionados',
			'admin.restore' => 'Restaurar',
			'admin.restored' => 'Restaurado exitosamente',
			'admin.deleteSpeciesFromSite' => 'Eliminar especie del sitio',
			'admin.confirmDeleteSpeciesFromSite' => ({required Object name}) => '¿Eliminar "${name}" de este sitio?',
			'admin.speciesRemovedFromSite' => 'Especie eliminada del sitio',
			'admin.speciesAddedToSite' => 'Especie agregada al sitio',
			'admin.selectSpeciesRequired' => 'Selecciona una especie',
			'admin.speciesAlreadyAssociated' => 'Esta especie ya está asociada a este sitio',
			'admin.relationshipAlreadyExists' => 'Esta relación especie-sitio ya existe',
			'admin.manageTaxonomy' => 'Gestión de Taxonomía',
			'admin.search' => 'Buscar...',
			'admin.confirmDeleteTitle' => 'Confirmar eliminación',
			'admin.confirmDeleteCount' => ({required Object count}) => '¿Eliminar ${count} elementos?',
			'admin.confirmDeletePermanentlyCount' => ({required Object count}) => '¿Eliminar permanentemente ${count} elementos? Esta acción no se puede deshacer.',
			'admin.inTrash' => ({required Object count}) => '${count} en papelera',
			'admin.emptyTrash' => 'La papelera está vacía',
			'admin.deletedLabel' => 'Eliminado',
			'admin.deletedOn' => ({required Object date}) => 'Eliminado: ${date}',
			'admin.taxonomyClasses' => 'Clases',
			'admin.taxonomyOrders' => 'Órdenes',
			'admin.taxonomyFamilies' => 'Familias',
			'admin.taxonomyGenera' => 'Géneros',
			'admin.taxonomySubtitle' => 'Clases, órdenes, familias, géneros',
			'admin.errorLoadingStats' => ({required Object error}) => 'Error cargando estadísticas: ${error}',
			'admin.sitesWithoutSpecies' => 'Sitios sin especies asociadas',
			'admin.speciesWithoutImages' => 'Especies sin imágenes',
			'admin.statistics' => 'Estadísticas',
			'admin.speciesByCategory' => 'Especies por Categoría',
			'admin.noData' => 'Sin datos',
			'admin.dataCoverage' => 'Cobertura de Datos',
			'admin.visitSitesSection' => 'Sitios de Visita',
			'admin.noVisitSitesForIsland' => 'No hay sitios de visita para esta isla. Usa la sección "Sitios de Visita" para crear nuevos.',
			'admin.saveIslandFirst' => 'Guarda la isla primero para ver sus sitios de visita',
			'admin.unnamed' => 'Sin nombre',
			'admin.speciesSection' => 'Especies',
			'admin.errorLoadingIslands' => ({required Object error}) => 'Error cargando islas: ${error}',
			'admin.errorLoadingSpecies' => ({required Object error}) => 'Error cargando especies: ${error}',
			'admin.errorLoadingSites' => ({required Object error}) => 'Error cargando sitios: ${error}',
			'admin.tabGeneral' => 'General',
			'admin.tabDescription' => 'Descripción',
			'admin.location' => 'Ubicación',
			'admin.addSpecies' => 'Agregar Especie',
			'admin.adding' => 'Agregando...',
			'admin.saveSiteFirst' => 'Guarda el sitio primero para agregar especies',
			'admin.noSpeciesForSite' => 'No hay especies asociadas a este sitio',
			'admin.noTaxonomyClasses' => 'Sin clases taxonómicas aún',
			'admin.noOrdersInClass' => 'Sin órdenes en esta clase',
			'admin.noFamiliesInOrder' => 'Sin familias en este orden',
			'admin.noGeneraInFamily' => 'Sin géneros en esta familia',
			'admin.deleteChildrenWarning' => 'Esto también eliminará todos los elementos hijos.',
			'admin.siteTypeTrail' => 'Sendero',
			'admin.siteTypeBeach' => 'Playa',
			'admin.siteTypeSnorkeling' => 'Snorkeling',
			'admin.siteTypeDiving' => 'Buceo',
			'admin.siteTypeViewpoint' => 'Mirador',
			'admin.siteTypeDock' => 'Muelle',
			'admin.uploadPicking' => 'Seleccionando imagen...',
			'admin.uploadCropping' => 'Recortando imagen...',
			'admin.uploadCompressing' => 'Comprimiendo imagen...',
			'admin.uploadUploading' => 'Subiendo imagen...',
			'admin.uploadGeneratingThumbnail' => 'Generando miniatura...',
			'admin.uploadDone' => '¡Imagen subida!',
			'admin.uploadError' => 'Error al subir imagen',
			'admin.siteCatalogs' => 'Clasificaciones',
			'admin.manageCatalogs' => 'Tipos, modalidades y actividades',
			'admin.users' => 'Usuarios',
			'admin.manageUsers' => 'Gestionar acceso y roles',
			'admin.tabDetails' => 'Detalles',
			'admin.populationTrend' => 'Tendencia Poblacional',
			'admin.trendIncreasing' => 'En Aumento',
			'admin.trendStable' => 'Estable',
			'admin.trendDecreasing' => 'En Descenso',
			'admin.trendUnknown' => 'Desconocida',
			'admin.native' => 'Nativa',
			'admin.introduced' => 'Introducida',
			'admin.endemismLevel' => 'Nivel de Endemismo',
			'admin.endemismArchipelago' => 'Endémica del Archipiélago',
			'admin.endemismIslandSpecific' => 'Endémica de Isla Específica',
			'admin.behavior' => 'Comportamiento',
			'admin.socialStructure' => 'Estructura Social',
			'admin.socialSolitary' => 'Solitario',
			'admin.socialPair' => 'Pareja',
			'admin.socialSmallGroup' => 'Grupo Pequeño',
			'admin.socialColony' => 'Colonia',
			'admin.socialHarem' => 'Harén',
			'admin.activityPattern' => 'Patrón de Actividad',
			'admin.activityDiurnal' => 'Diurno',
			'admin.activityNocturnal' => 'Nocturno',
			'admin.activityCrepuscular' => 'Crepuscular',
			'admin.dietType' => 'Tipo de Dieta',
			'admin.dietCarnivore' => 'Carnívoro',
			'admin.dietHerbivore' => 'Herbívoro',
			'admin.dietOmnivore' => 'Omnívoro',
			'admin.dietInsectivore' => 'Insectívoro',
			'admin.dietPiscivore' => 'Piscívoro',
			'admin.dietFrugivore' => 'Frugívoro',
			'admin.dietNectarivore' => 'Nectarívoro',
			'admin.primaryFoodSources' => 'Fuentes Principales de Alimento',
			'admin.reproduction' => 'Reproducción',
			'admin.breedingSeason' => 'Temporada de Cría',
			'admin.clutchSize' => 'Tamaño de Postura',
			'admin.reproductiveFrequency' => 'Frecuencia Reproductiva',
			'admin.distinguishingFeatures' => 'Características Distintivas',
			'admin.distinguishingFeaturesEs' => 'Características Distintivas (ES)',
			'admin.distinguishingFeaturesEn' => 'Características Distintivas (EN)',
			'admin.sexualDimorphism' => 'Dimorfismo Sexual',
			'admin.geographicRanges' => 'Rangos Geográficos',
			'admin.altitudeMinM' => 'Altitud Mínima (m)',
			'admin.altitudeMaxM' => 'Altitud Máxima (m)',
			'admin.depthMinM' => 'Profundidad Mínima (m)',
			'admin.depthMaxM' => 'Profundidad Máxima (m)',
			'badges.title' => 'Logros',
			'badges.empty' => 'Sin logros aún',
			'badges.emptySubtitle' => '¡Empieza a explorar para ganar logros!',
			_ => null,
		} ?? switch (path) {
			'badges.unlocked' => '¡Desbloqueado!',
			'badges.locked' => 'Bloqueado',
			'badges.progress' => ({required Object current, required Object target}) => '${current} / ${target}',
			'badges.firstSighting' => 'Primer Avistamiento',
			'badges.firstSightingDesc' => 'Registra tu primer avistamiento',
			'badges.explorer' => 'Explorador',
			'badges.explorerDesc' => 'Registra 10 avistamientos',
			'badges.fieldResearcher' => 'Investigador de Campo',
			'badges.fieldResearcherDesc' => 'Registra 50 avistamientos',
			'badges.naturalist' => 'Naturalista',
			'badges.naturalistDesc' => 'Avista 5 especies diferentes',
			'badges.biologist' => 'Biólogo',
			'badges.biologistDesc' => 'Avista 20 especies diferentes',
			'badges.endemicExplorer' => 'Explorador Endémico',
			'badges.endemicExplorerDesc' => 'Avista 5 especies endémicas',
			'badges.islandHopper' => 'Saltaislas',
			'badges.islandHopperDesc' => 'Visita 3 islas diferentes',
			'badges.photographer' => 'Fotógrafo',
			'badges.photographerDesc' => 'Toma 10 fotos de avistamientos',
			'badges.curator' => 'Curador',
			'badges.curatorDesc' => 'Agrega 10 especies a favoritos',
			'badges.conservationist' => 'Conservacionista',
			'badges.conservationistDesc' => 'Avista 3 especies amenazadas (CR/EN/VU)',
			'badges.badgeUnlocked' => '¡Logro Desbloqueado!',
			'badges.youEarned' => ({required Object name}) => 'Has ganado: ${name}',
			'badges.congratulations' => '¡Felicidades!',
			'offline.downloadPacks' => 'Paquetes de Descarga por Isla',
			'offline.downloadPack' => 'Descargar Paquete de Isla',
			'offline.packageDownloaded' => 'Descargado',
			'offline.packages' => 'paquetes',
			'offline.downloaded' => 'Descargados',
			'offline.available' => 'Disponibles para Descargar',
			'offline.packagesInfo' => 'Paquetes de Isla',
			'offline.packagesDescription' => 'Descarga paquetes completos de isla incluyendo mapas, datos de especies, sitios de visita e imágenes para uso sin conexión.',
			'offline.noPackages' => 'No hay paquetes disponibles',
			'offline.downloadConfirmation' => '¿Descargar el paquete completo para esta isla?',
			'offline.downloadWarning' => 'Esto descargará mapas e imágenes. Asegúrate de tener una conexión estable a internet.',
			'offline.download' => 'Descargar',
			'offline.downloading' => 'Descargando',
			'offline.syncStatus' => 'Estado de Sincronización',
			'offline.online' => 'En línea',
			'offline.offline' => 'Sin conexión',
			'offline.lastSynced' => 'Última sincronización',
			'offline.pending' => 'Pendientes',
			'offline.allSynced' => 'Todo sincronizado',
			'offline.syncNow' => 'Sincronizar Ahora',
			'common.loading' => 'Cargando...',
			'common.error' => 'Algo salió mal',
			'common.retry' => 'Reintentar',
			'common.cancel' => 'Cancelar',
			'common.confirm' => 'Confirmar',
			'common.delete' => 'Eliminar',
			'common.save' => 'Guardar',
			'common.edit' => 'Editar',
			'common.close' => 'Cerrar',
			'common.ok' => 'OK',
			'common.yes' => 'Sí',
			'common.no' => 'No',
			'common.add' => 'Agregar',
			'common.clearSearch' => 'Limpiar búsqueda',
			'common.items' => ({required Object count}) => '${count} elementos',
			'common.unsavedChangesTitle' => 'Cambios sin guardar',
			'common.unsavedChangesMessage' => 'Tienes cambios sin guardar. ¿Descartarlos?',
			'common.discard' => 'Descartar',
			'common.refresh' => 'Actualizar',
			'common.images' => 'imágenes',
			'common.offline' => 'Estás sin conexión',
			'common.offlineSubtitle' => 'Algunas funciones pueden estar limitadas',
			'common.offlineMode' => 'Modo Sin Conexión',
			'common.offlineMessage' => 'Trabajando con datos en caché',
			'common.details' => 'Detalles Técnicos',
			'error.network' => 'Sin Conexión a Internet',
			'error.networkDesc' => 'Por favor verifica tu conexión a internet e intenta nuevamente.',
			'error.timeout' => 'Tiempo de Espera Agotado',
			'error.timeoutDesc' => 'La solicitud tomó demasiado tiempo. Por favor intenta más tarde.',
			'error.parsing' => 'Error de Datos',
			'error.parsingDesc' => 'No se pueden procesar los datos. Por favor intenta nuevamente o contacta soporte.',
			'error.authentication' => 'Error de Autenticación',
			'error.authenticationDesc' => 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.',
			'error.notFound' => 'No Encontrado',
			'error.notFoundDesc' => 'El recurso solicitado no fue encontrado.',
			'error.serverError' => 'Error del Servidor',
			'error.serverErrorDesc' => 'El servidor está experimentando problemas. Por favor intenta más tarde.',
			'error.unknownDesc' => 'Ocurrió un error inesperado. Por favor intenta nuevamente.',
			'sync.appName' => 'Fauna de Galápagos',
			'sync.downloading' => ({required Object table}) => 'Descargando ${table}...',
			'sync.preparing' => 'Preparando...',
			'sync.errorTitle' => 'No se pudieron descargar los datos.',
			'sync.errorSubtitle' => 'Por favor verifica tu conexión a internet.',
			'sync.retry' => 'Reintentar',
			'location.servicesDisabled' => 'Los servicios de ubicación están desactivados',
			'location.permissionDenied' => 'Permiso de ubicación denegado',
			'location.locationObtained' => 'Ubicación obtenida',
			'onboarding.welcome' => 'Bienvenido a Fauna de Galápagos',
			'onboarding.discoverTitle' => 'Descubre la Fauna',
			'onboarding.discoverDesc' => 'Explora más de 40 especies de aves, reptiles, mamíferos y vida marina únicas de las islas',
			'onboarding.mapTitle' => 'Explora las Islas',
			'onboarding.mapDesc' => 'Mapa interactivo con islas, sitios de visita y soporte para mapas offline',
			'onboarding.sightingsTitle' => 'Registra Avistamientos',
			'onboarding.sightingsDesc' => 'Registra tus encuentros con la fauna con fotos, ubicación y notas',
			'onboarding.badgesTitle' => 'Gana Logros',
			'onboarding.badgesDesc' => 'Sigue tu progreso y desbloquea logros mientras exploras',
			'onboarding.getStarted' => 'Comenzar',
			'onboarding.next' => 'Siguiente',
			'onboarding.skip' => 'Omitir',
			'search.title' => 'Buscar',
			'search.hint' => 'Buscar especies, islas, sitios...',
			'search.noResults' => 'Sin resultados',
			'search.noResultsSubtitle' => 'Intenta con otro término de búsqueda',
			'search.speciesSection' => 'Especies',
			'search.islandsSection' => 'Islas',
			'search.sitesSection' => 'Sitios de Visita',
			'leaderboard.title' => 'Tabla de Posiciones',
			'leaderboard.rank' => 'Posicion',
			'leaderboard.sightings' => 'Avistamientos',
			'leaderboard.species' => 'Especies',
			'leaderboard.photos' => 'Fotos',
			'leaderboard.you' => 'Tu',
			'leaderboard.empty' => 'Sin avistamientos registrados aun. Se el primero!',
			'leaderboard.topExplorer' => 'Explorador Principal',
			'share.species' => 'Compartir especie',
			'share.shareText' => ({required Object name, required Object scientificName}) => '¡Mira ${name} (${scientificName}) en Fauna de Galápagos!',
			'share.copiedToClipboard' => 'Copiado al portapapeles',
			'celebrations.title' => 'Celebraciones',
			'celebrations.todayEvent' => ({required Object event}) => 'Hoy: ${event}',
			'celebrations.birthdayOverlay' => '¡Es tu cumpleaños!',
			'errors.network' => 'Sin conexión a internet. Revisa tu red.',
			'errors.timeout' => 'La solicitud ha caducado. Intenta de nuevo.',
			'errors.auth' => 'Error de autenticación. Inicia sesión nuevamente.',
			'errors.storage' => 'Error de almacenamiento. Intenta de nuevo.',
			'errors.validation' => 'Revisa los datos ingresados.',
			'errors.unknown' => 'Ocurrió un error inesperado.',
			'errors.tryAgain' => 'Reintentar',
			'fieldEdit.title' => 'Edición de Campo',
			'fieldEdit.mode' => 'Modo de Edición de Campo',
			'fieldEdit.moveVisitSite' => 'Mover Sitio de Visita',
			'fieldEdit.editTrail' => 'Editar Sendero',
			'fieldEdit.createNewTrail' => 'Crear Nuevo Sendero',
			'fieldEdit.howToMoveSite' => '¿Cómo mover el sitio?',
			'fieldEdit.dragOnMap' => 'Arrastrar en el Mapa',
			'fieldEdit.dragOnMapDesc' => 'Todos los marcadores se vuelven arrastrables — arrastra cualquiera a su posición correcta',
			'fieldEdit.useCurrentGps' => 'Usar Ubicación GPS Actual',
			'fieldEdit.useCurrentGpsDesc' => 'Toca un marcador de sitio para moverlo a tu posición actual',
			'fieldEdit.howToEditTrail' => '¿Cómo editar el sendero?',
			'fieldEdit.editOnMap' => 'Editar en el Mapa',
			'fieldEdit.editOnMapDesc' => 'Toca un sendero, luego agrega/elimina puntos',
			'fieldEdit.walkRecordGps' => 'Caminar y Grabar GPS',
			'fieldEdit.walkRecordGpsDesc' => 'Re-grabar el sendero caminando la ruta',
			'fieldEdit.howToCreateTrail' => '¿Cómo crear el sendero?',
			'fieldEdit.drawOnMap' => 'Dibujar en el Mapa',
			'fieldEdit.drawOnMapDesc' => 'Toca el mapa para agregar puntos, arrastra para ajustar',
			'fieldEdit.walkRecordGpsNewDesc' => 'Seguimiento GPS mientras caminas la ruta',
			'fieldEdit.correctSiteLocation' => 'Corregir ubicación del sitio',
			'fieldEdit.correctTrailPath' => 'Corregir trazado del sendero',
			'fieldEdit.drawOnMapOrGps' => 'Dibujar en mapa o seguimiento GPS',
			'fieldEdit.dragAnySiteToMove' => 'Arrastra cualquier marcador de sitio para moverlo',
			'fieldEdit.tapSiteToMoveToCurrentLocation' => 'Toca un marcador de sitio para moverlo a tu ubicación actual',
			'fieldEdit.tapTrailToStartEditing' => 'Toca un sendero para empezar a editarlo',
			'fieldEdit.tapTrailThenWalk' => 'Toca un sendero, luego camina para re-grabar',
			'fieldEdit.tapMapToAddPoints' => 'Toca el mapa para agregar puntos al sendero',
			'fieldEdit.discardChanges' => '¿Descartar cambios?',
			'fieldEdit.discardChangesMessage' => 'Tienes cambios sin guardar. ¿Descartarlos?',
			'fieldEdit.keepEditing' => 'Seguir editando',
			'fieldEdit.discard' => 'Descartar',
			'fieldEdit.doneEditing' => '¿Finalizar edición?',
			'fieldEdit.sitesSaved' => 'Las posiciones de los sitios han sido guardadas en el servidor.',
			'fieldEdit.saveNewTrail' => 'Guardar Nuevo Sendero',
			'fieldEdit.trailNameEn' => 'Nombre del Sendero (Inglés)',
			'fieldEdit.trailNameEnHint' => 'ej., Tortuga Bay Trail',
			'fieldEdit.trailNameEs' => 'Nombre del Sendero (Español)',
			'fieldEdit.trailNameEsHint' => 'ej., Sendero Bahía Tortuga',
			'fieldEdit.continueRecording' => 'Continuar Grabando',
			'fieldEdit.saveTrail' => 'Guardar',
			'fieldEdit.needTwoPoints' => 'Se necesitan al menos 2 puntos para guardar el sendero',
			'fieldEdit.enterBothTrailNames' => 'Por favor ingresa los nombres del sendero en ambos idiomas',
			'fieldEdit.saveTrailChanges' => 'Guardar Cambios del Sendero',
			'fieldEdit.saveTrailChangesDesc' => 'Esto reemplazará el trazado existente del sendero con las coordenadas editadas.',
			'fieldEdit.continueEditing' => 'Continuar Editando',
			'fieldEdit.saveChanges' => 'Guardar Cambios',
			'fieldEdit.movingSitesDrag' => 'Moviendo Sitios — arrastra cualquier marcador',
			'fieldEdit.movingSiteManual' => 'Moviendo Sitio (Arrastrar)',
			'fieldEdit.movingSiteGps' => 'Moviendo Sitio (GPS)',
			'fieldEdit.tapTrailToEdit' => 'Toca un sendero para editar',
			'fieldEdit.editingTrail' => 'Editando Sendero',
			'fieldEdit.recordingTrailGps' => 'Grabando Sendero (GPS)',
			'fieldEdit.creatingTrail' => 'Creando Sendero',
			'fieldEdit.recordingNewTrailGps' => 'Grabando Nuevo Sendero (GPS)',
			'fieldEdit.pauseRecording' => 'Pausar',
			'fieldEdit.resumeRecording' => 'Reanudar',
			'fieldEdit.stopAndSave' => 'Detener y Guardar',
			'fieldEdit.editTrailInfo' => 'Editar información',
			'fieldEdit.undo' => 'Deshacer',
			'fieldEdit.cancel' => 'Cancelar',
			'fieldEdit.save' => 'Guardar',
			'fieldEdit.deletePoint' => ({required Object number}) => 'Borrar punto ${number}',
			'fieldEdit.deletePoints' => ({required Object count}) => 'Borrar ${count} puntos',
			'fieldEdit.tapPointsDragToMove' => 'Toca punto(s) • arrastrar mueve selección',
			'fieldEdit.subModePoints' => 'Puntos',
			'fieldEdit.subModeMove' => 'Mover',
			'fieldEdit.subModeRotate' => 'Rotar',
			_ => null,
		};
	}
}
