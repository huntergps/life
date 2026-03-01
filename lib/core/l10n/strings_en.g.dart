///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAppEn app = TranslationsAppEn._(_root);
	late final TranslationsNavEn nav = TranslationsNavEn._(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn._(_root);
	late final TranslationsSpeciesEn species = TranslationsSpeciesEn._(_root);
	late final TranslationsConservationEn conservation = TranslationsConservationEn._(_root);
	late final TranslationsMapEn map = TranslationsMapEn._(_root);
	late final TranslationsFavoritesEn favorites = TranslationsFavoritesEn._(_root);
	late final TranslationsSightingsEn sightings = TranslationsSightingsEn._(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn._(_root);
	late final TranslationsAdminEn admin = TranslationsAdminEn._(_root);
	late final TranslationsBadgesEn badges = TranslationsBadgesEn._(_root);
	late final TranslationsOfflineEn offline = TranslationsOfflineEn._(_root);
	late final TranslationsCommonEn common = TranslationsCommonEn._(_root);
	late final TranslationsErrorEn error = TranslationsErrorEn._(_root);
	late final TranslationsSyncEn sync = TranslationsSyncEn._(_root);
	late final TranslationsLocationEn location = TranslationsLocationEn._(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn._(_root);
	late final TranslationsSearchEn search = TranslationsSearchEn._(_root);
	late final TranslationsLeaderboardEn leaderboard = TranslationsLeaderboardEn._(_root);
	late final TranslationsShareEn share = TranslationsShareEn._(_root);
	late final TranslationsCelebrationsEn celebrations = TranslationsCelebrationsEn._(_root);
	late final TranslationsErrorsEn errors = TranslationsErrorsEn._(_root);
	late final TranslationsFieldEditEn fieldEdit = TranslationsFieldEditEn._(_root);
}

// Path: app
class TranslationsAppEn {
	TranslationsAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Galápagos Wildlife'
	String get name => 'Galápagos Wildlife';

	/// en: 'Explore the enchanted islands'
	String get subtitle => 'Explore the enchanted islands';
}

// Path: nav
class TranslationsNavEn {
	TranslationsNavEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Species'
	String get species => 'Species';

	/// en: 'Map'
	String get map => 'Map';

	/// en: 'Favorites'
	String get favorites => 'Favorites';

	/// en: 'Sightings'
	String get sightings => 'Sightings';
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome to Galápagos'
	String get welcome => 'Welcome to Galápagos';

	/// en: 'Explore Wildlife'
	String get explore => 'Explore Wildlife';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Featured Species'
	String get featured => 'Featured Species';

	/// en: 'Quick Links'
	String get quickLinks => 'Quick Links';

	/// en: 'View All'
	String get viewAll => 'View All';

	/// en: 'Discover Species'
	String get discoverSpecies => 'Discover Species';

	/// en: 'Explore the Map'
	String get exploreMap => 'Explore the Map';

	/// en: 'Recent Sightings'
	String get recentSightings => 'Recent Sightings';

	/// en: 'Browse all wildlife'
	String get browseWildlife => 'Browse all wildlife';

	/// en: 'Find visit sites and islands'
	String get findSites => 'Find visit sites and islands';

	/// en: 'Log your wildlife encounters'
	String get logEncounters => 'Log your wildlife encounters';
}

// Path: species
class TranslationsSpeciesEn {
	TranslationsSpeciesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Species'
	String get title => 'Species';

	/// en: 'Search species...'
	String get search => 'Search species...';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Endemic'
	String get endemic => 'Endemic';

	/// en: 'Conservation Status'
	String get conservationStatus => 'Conservation Status';

	/// en: 'Scientific Name'
	String get scientificName => 'Scientific Name';

	/// en: 'Weight'
	String get weight => 'Weight';

	/// en: 'Size'
	String get size => 'Size';

	/// en: 'Population'
	String get population => 'Population';

	/// en: 'Lifespan'
	String get lifespan => 'Lifespan';

	/// en: 'Habitat'
	String get habitat => 'Habitat';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Where to See'
	String get whereToSee => 'Where to See';

	/// en: 'Gallery'
	String get gallery => 'Gallery';

	/// en: 'Quick Facts'
	String get quickFacts => 'Quick Facts';

	/// en: 'Conservation status: ${status}'
	String conservationStatusLabel({required Object status}) => 'Conservation status: ${status}';

	/// en: 'years'
	String get years => 'years';

	/// en: 'kg'
	String get kg => 'kg';

	/// en: 'cm'
	String get cm => 'cm';

	/// en: 'individuals'
	String get individuals => 'individuals';

	/// en: 'Taxonomy'
	String get taxonomy => 'Taxonomy';

	/// en: 'Kingdom'
	String get kingdom => 'Kingdom';

	/// en: 'Phylum'
	String get phylum => 'Phylum';

	/// en: 'Class'
	String get classLabel => 'Class';

	/// en: 'Order'
	String get order => 'Order';

	/// en: 'Family'
	String get family => 'Family';

	/// en: 'Genus'
	String get genus => 'Genus';

	/// en: 'No species found'
	String get noResults => 'No species found';

	/// en: 'Try a different search term'
	String get noResultsSubtitle => 'Try a different search term';

	/// en: 'No additional images'
	String get noImages => 'No additional images';

	/// en: 'Add to favorites'
	String get addToFavorites => 'Add to favorites';

	/// en: 'Remove from favorites'
	String get removeFromFavorites => 'Remove from favorites';

	/// en: 'Species not found'
	String get notFound => 'Species not found';

	/// en: 'Clear'
	String get clearFilters => 'Clear';

	/// en: 'Category'
	String get categoryFilter => 'Category';

	/// en: 'Conservation & Endemic'
	String get conservationFilter => 'Conservation & Endemic';

	/// en: 'How filters work'
	String get filterHelp => 'How filters work';

	/// en: 'Filters combine to narrow results. Select a category, conservation status, or endemic to filter species.'
	String get filterHelpText => 'Filters combine to narrow results. Select a category, conservation status, or endemic to filter species.';

	/// en: 'Compare'
	String get compare => 'Compare';

	/// en: 'Compare Species'
	String get compareSpecies => 'Compare Species';

	/// en: 'Select two species to compare'
	String get selectTwoSpecies => 'Select two species to compare';

	/// en: 'VS'
	String get vsLabel => 'VS';

	/// en: 'Featured: ${name}, tap to view details'
	String featuredImageLabel({required Object name}) => 'Featured: ${name}, tap to view details';

	/// en: 'Gallery image ${index} of ${total}'
	String galleryImageLabel({required Object index, required Object total}) => 'Gallery image ${index} of ${total}';

	/// en: 'Image ${index} of ${total}'
	String fullscreenImageLabel({required Object index, required Object total}) => 'Image ${index} of ${total}';

	/// en: 'Thumbnail ${index}, tap to view full image'
	String thumbnailLabel({required Object index}) => 'Thumbnail ${index}, tap to view full image';

	late final TranslationsSpeciesFrequencyEn frequency = TranslationsSpeciesFrequencyEn._(_root);
}

// Path: conservation
class TranslationsConservationEn {
	TranslationsConservationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Extinct'
	String get EX => 'Extinct';

	/// en: 'Extinct in Wild'
	String get EW => 'Extinct in Wild';

	/// en: 'Critically Endangered'
	String get CR => 'Critically Endangered';

	/// en: 'Endangered'
	String get EN => 'Endangered';

	/// en: 'Vulnerable'
	String get VU => 'Vulnerable';

	/// en: 'Near Threatened'
	String get NT => 'Near Threatened';

	/// en: 'Least Concern'
	String get LC => 'Least Concern';

	/// en: 'Data Deficient'
	String get DD => 'Data Deficient';

	/// en: 'Not Evaluated'
	String get NE => 'Not Evaluated';
}

// Path: map
class TranslationsMapEn {
	TranslationsMapEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Galápagos Map'
	String get title => 'Galápagos Map';

	/// en: 'Islands'
	String get islands => 'Islands';

	/// en: 'Visit Sites'
	String get visitSites => 'Visit Sites';

	/// en: 'Species here'
	String get speciesHere => 'Species here';

	/// en: 'Get Directions'
	String get directions => 'Get Directions';

	/// en: 'Offline Tiles'
	String get offlineTiles => 'Offline Tiles';

	/// en: 'Download Map Tiles'
	String get downloadTiles => 'Download Map Tiles';

	/// en: 'Downloading tiles...'
	String get downloading => 'Downloading tiles...';

	/// en: 'Tiles downloaded'
	String get downloadComplete => 'Tiles downloaded';

	/// en: 'Download in progress...'
	String get downloadInProgress => 'Download in progress...';

	/// en: 'Download map tiles for offline use'
	String get tilesInfo => 'Download map tiles for offline use';

	/// en: 'Toggle visit sites'
	String get toggleSites => 'Toggle visit sites';

	/// en: 'Go to my location'
	String get goToMyLocation => 'Go to my location';

	/// en: 'Locating device...'
	String get locatingDevice => 'Locating device...';

	/// en: 'Center on Galápagos'
	String get centerOnGalapagos => 'Center on Galápagos';

	/// en: 'Cached tiles'
	String get cachedTiles => 'Cached tiles';

	/// en: 'Cache size'
	String get cacheSize => 'Cache size';

	/// en: 'MB'
	String get mb => 'MB';

	/// en: 'Download for offline use'
	String get downloadForOffline => 'Download for offline use';

	/// en: 'Estimated tiles: ${count}'
	String estimatedTiles({required Object count}) => 'Estimated tiles: ${count}';

	/// en: 'Download cancelled'
	String get downloadCancelled => 'Download cancelled';

	/// en: 'Area: ${area} km²'
	String islandArea({required Object area}) => 'Area: ${area} km²';

	/// en: 'Your current location'
	String get yourLocation => 'Your current location';

	/// en: 'Island: ${name}'
	String islandLabel({required Object name}) => 'Island: ${name}';

	/// en: 'Visit site: ${name}'
	String visitSiteLabel({required Object name}) => 'Visit site: ${name}';

	/// en: 'Sightings'
	String get sightings => 'Sightings';

	/// en: 'Toggle sightings'
	String get toggleSightings => 'Toggle sightings';

	/// en: 'Sighting: ${species}'
	String sightingLabel({required Object species}) => 'Sighting: ${species}';

	/// en: 'Trails'
	String get trails => 'Trails';

	/// en: 'Toggle trails'
	String get toggleTrails => 'Toggle trails';

	/// en: 'Trail: ${name}'
	String trailLabel({required Object name}) => 'Trail: ${name}';

	/// en: 'Difficulty'
	String get trailDifficulty => 'Difficulty';

	/// en: '${km} km'
	String trailDistance({required Object km}) => '${km} km';

	/// en: '${min} min'
	String trailDuration({required Object min}) => '${min} min';

	/// en: 'Easy'
	String get difficultyEasy => 'Easy';

	/// en: 'Moderate'
	String get difficultyModerate => 'Moderate';

	/// en: 'Hard'
	String get difficultyHard => 'Hard';

	/// en: 'Download by Island'
	String get downloadByIsland => 'Download by Island';

	/// en: 'Download All Galápagos'
	String get downloadAll => 'Download All Galápagos';

	/// en: 'Select islands to download'
	String get selectIslands => 'Select islands to download';

	/// en: 'Download Selected'
	String get downloadSelected => 'Download Selected';

	/// en: 'Detail level'
	String get zoomLevel => 'Detail level';

	/// en: 'Basic (less data)'
	String get zoomBasic => 'Basic (less data)';

	/// en: 'Detailed (more data)'
	String get zoomDetailed => 'Detailed (more data)';

	/// en: 'Delete Tiles'
	String get deleteTiles => 'Delete Tiles';

	/// en: 'Tiles deleted'
	String get tilesDeleted => 'Tiles deleted';

	/// en: 'Tracking'
	String get tracking => 'Tracking';

	/// en: 'Start Tracking'
	String get startTracking => 'Start Tracking';

	/// en: 'Stop Tracking'
	String get stopTracking => 'Stop Tracking';

	/// en: 'Track recorded'
	String get trackRecorded => 'Track recorded';

	/// en: 'You are off the trail!'
	String get offRoute => 'You are off the trail!';

	/// en: 'Back on trail'
	String get backOnRoute => 'Back on trail';

	/// en: '${meters}m from trail'
	String distanceFromTrail({required Object meters}) => '${meters}m from trail';

	/// en: 'Distance: ${km} km'
	String trackDistance({required Object km}) => 'Distance: ${km} km';

	/// en: 'Duration: ${duration}'
	String trackDuration({required Object duration}) => 'Duration: ${duration}';

	/// en: 'No trails available'
	String get noTrails => 'No trails available';

	/// en: 'Base Map'
	String get baseMap => 'Base Map';

	/// en: 'Vector (3 MB)'
	String get baseMapVector => 'Vector (3 MB)';

	/// en: 'Raster HD'
	String get baseMapRaster => 'Raster HD';

	/// en: 'Download Base Map'
	String get downloadBaseMap => 'Download Base Map';

	/// en: 'Downloading base map...'
	String get downloadingBaseMap => 'Downloading base map...';

	/// en: 'Base map ready'
	String get baseMapReady => 'Base map ready';

	/// en: 'Base map not downloaded'
	String get baseMapNotDownloaded => 'Base map not downloaded';

	/// en: 'Delete Base Map'
	String get deleteBaseMap => 'Delete Base Map';

	/// en: 'Base map deleted'
	String get baseMapDeleted => 'Base map deleted';

	/// en: 'Switch to Vector'
	String get switchToVector => 'Switch to Vector';

	/// en: 'Switch to HD Raster'
	String get switchToRaster => 'Switch to HD Raster';

	/// en: 'HD Raster Tiles'
	String get hdTiles => 'HD Raster Tiles';

	/// en: 'Download HD for this area'
	String get downloadHdArea => 'Download HD for this area';

	/// en: 'Downloading HD tiles...'
	String get downloadingHdArea => 'Downloading HD tiles...';

	/// en: 'HD tiles downloaded for this area'
	String get hdAreaDownloaded => 'HD tiles downloaded for this area';

	/// en: 'Map Mode'
	String get mapMode => 'Map Mode';

	/// en: 'Vector Offline'
	String get vectorOffline => 'Vector Offline';

	/// en: 'Raster HD'
	String get rasterOnline => 'Raster HD';

	/// en: 'Switch map mode'
	String get switchMapMode => 'Switch map mode';

	/// en: 'Map Modes'
	String get mapModes => 'Map Modes';

	/// en: 'Street Map'
	String get modeStreet => 'Street Map';

	/// en: 'OpenStreetMap with offline caching'
	String get modeStreetDesc => 'OpenStreetMap with offline caching';

	/// en: 'Vector Map'
	String get modeVector => 'Vector Map';

	/// en: 'Lightweight offline vector tiles (3 MB)'
	String get modeVectorDesc => 'Lightweight offline vector tiles (3 MB)';

	/// en: 'Satellite'
	String get modeSatellite => 'Satellite';

	/// en: 'High-resolution satellite imagery (ESRI)'
	String get modeSatelliteDesc => 'High-resolution satellite imagery (ESRI)';

	/// en: 'Hybrid'
	String get modeHybrid => 'Hybrid';

	/// en: 'Satellite imagery with labels'
	String get modeHybridDesc => 'Satellite imagery with labels';

	/// en: 'Login required for satellite view'
	String get loginRequiredForSatellite => 'Login required for satellite view';

	/// en: 'Filter sites'
	String get filterSites => 'Filter sites';

	/// en: 'Filter visit sites'
	String get filterVisitSites => 'Filter visit sites';
}

// Path: favorites
class TranslationsFavoritesEn {
	TranslationsFavoritesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Favorites'
	String get title => 'Favorites';

	/// en: 'No favorites yet'
	String get empty => 'No favorites yet';

	/// en: 'Tap the heart icon on any species to add it here'
	String get emptySubtitle => 'Tap the heart icon on any species to add it here';

	/// en: 'Added to favorites'
	String get added => 'Added to favorites';

	/// en: 'Removed from favorites'
	String get removed => 'Removed from favorites';

	/// en: 'Sign in to save favorites'
	String get loginRequired => 'Sign in to save favorites';
}

// Path: sightings
class TranslationsSightingsEn {
	TranslationsSightingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sighting photo'
	String get sightingPhoto => 'Sighting photo';

	/// en: 'My Sightings'
	String get title => 'My Sightings';

	/// en: 'Add Sighting'
	String get add => 'Add Sighting';

	/// en: 'No sightings yet'
	String get empty => 'No sightings yet';

	/// en: 'Record your wildlife encounters'
	String get emptySubtitle => 'Record your wildlife encounters';

	/// en: 'Select Species'
	String get selectSpecies => 'Select Species';

	/// en: 'Select Visit Site'
	String get selectSite => 'Select Visit Site';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Notes'
	String get notes => 'Notes';

	/// en: 'What did you observe?'
	String get notesHint => 'What did you observe?';

	/// en: 'Photo'
	String get photo => 'Photo';

	/// en: 'Add Photo'
	String get addPhoto => 'Add Photo';

	/// en: 'Location'
	String get location => 'Location';

	/// en: 'Use Current Location'
	String get useCurrentLocation => 'Use Current Location';

	/// en: 'Save Sighting'
	String get save => 'Save Sighting';

	/// en: 'Sighting saved'
	String get saved => 'Sighting saved';

	/// en: 'Delete Sighting'
	String get delete => 'Delete Sighting';

	/// en: 'Are you sure you want to delete this sighting?'
	String get deleteConfirm => 'Are you sure you want to delete this sighting?';

	/// en: 'Sign in to record sightings'
	String get loginRequired => 'Sign in to record sightings';

	/// en: 'Pending sync'
	String get pendingSync => 'Pending sync';

	/// en: 'Take Photo'
	String get takePhoto => 'Take Photo';

	/// en: 'Choose from Gallery'
	String get fromGallery => 'Choose from Gallery';

	/// en: 'Change Photo'
	String get changePhoto => 'Change Photo';

	/// en: 'Remove Photo'
	String get removePhoto => 'Remove Photo';

	/// en: 'Photo added'
	String get photoAdded => 'Photo added';

	/// en: 'Processing photo...'
	String get processingPhoto => 'Processing photo...';

	/// en: 'Sighting deleted'
	String get deleted => 'Sighting deleted';

	/// en: 'Select a sighting to view details'
	String get selectDetail => 'Select a sighting to view details';

	/// en: 'Export CSV'
	String get export => 'Export CSV';

	/// en: 'Sightings exported'
	String get exported => 'Sightings exported';

	/// en: 'No sightings to export'
	String get noSightingsToExport => 'No sightings to export';

	/// en: 'Filters'
	String get filters => 'Filters';

	/// en: 'All Species'
	String get allSpecies => 'All Species';

	/// en: 'Date Range'
	String get dateRange => 'Date Range';

	/// en: 'From'
	String get from => 'From';

	/// en: 'To'
	String get to => 'To';

	/// en: 'Clear Filters'
	String get clearFilters => 'Clear Filters';

	/// en: 'Statistics'
	String get statistics => 'Statistics';

	/// en: 'Total Sightings'
	String get totalSightings => 'Total Sightings';

	/// en: 'Unique Species'
	String get uniqueSpecies => 'Unique Species';

	/// en: 'This Month'
	String get thisMonth => 'This Month';

	/// en: 'With Photos'
	String get withPhotos => 'With Photos';

	/// en: 'Calendar'
	String get calendarView => 'Calendar';

	/// en: 'List'
	String get listView => 'List';

	/// en: 'No sightings this month'
	String get noSightingsInMonth => 'No sightings this month';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign In'
	String get signIn => 'Sign In';

	/// en: 'Sign Up'
	String get signUp => 'Sign Up';

	/// en: 'Sign Out'
	String get signOut => 'Sign Out';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Forgot Password?'
	String get forgotPassword => 'Forgot Password?';

	/// en: 'Don't have an account?'
	String get noAccount => 'Don\'t have an account?';

	/// en: 'Already have an account?'
	String get hasAccount => 'Already have an account?';

	/// en: 'Continue as Guest'
	String get continueAsGuest => 'Continue as Guest';

	/// en: 'Sign in to access this feature'
	String get signInToAccess => 'Sign in to access this feature';

	/// en: 'My Profile'
	String get profile => 'My Profile';

	/// en: 'Member since ${date}'
	String memberSince({required Object date}) => 'Member since ${date}';

	/// en: 'Species Seen'
	String get speciesSeen => 'Species Seen';

	/// en: 'Islands Visited'
	String get islandsVisited => 'Islands Visited';

	/// en: 'Photos Taken'
	String get photosTaken => 'Photos Taken';

	/// en: 'Level'
	String get level => 'Level';

	/// en: 'Beginner'
	String get beginner => 'Beginner';

	/// en: 'Explorer'
	String get intermediate => 'Explorer';

	/// en: 'Naturalist'
	String get advanced => 'Naturalist';

	/// en: 'Master Naturalist'
	String get expert => 'Master Naturalist';

	/// en: 'Save favorites and record sightings'
	String get signInSubtitle => 'Save favorites and record sightings';

	/// en: 'Recent Activity'
	String get recentActivity => 'Recent Activity';

	/// en: 'Sign in to view your exploration profile'
	String get signInToViewProfile => 'Sign in to view your exploration profile';

	/// en: '${count} / ${total} badges unlocked'
	String badgesUnlocked({required Object count, required Object total}) => '${count} / ${total} badges unlocked';

	/// en: 'No badges yet'
	String get noBadgesYet => 'No badges yet';

	/// en: 'View All Badges'
	String get viewAllBadges => 'View All Badges';

	/// en: 'No recent sightings'
	String get noRecentSightings => 'No recent sightings';

	/// en: 'Display Name'
	String get displayName => 'Display Name';

	/// en: 'Bio'
	String get bio => 'Bio';

	/// en: 'Birthday'
	String get birthday => 'Birthday';

	/// en: 'Select your birthday'
	String get selectBirthday => 'Select your birthday';

	/// en: 'Search country...'
	String get selectCountry => 'Search country...';

	/// en: 'Country'
	String get country => 'Country';

	/// en: 'Edit Profile'
	String get editProfile => 'Edit Profile';

	/// en: 'Save Profile'
	String get saveProfile => 'Save Profile';

	/// en: 'Profile updated'
	String get profileUpdated => 'Profile updated';

	/// en: 'Profile photo updated'
	String get avatarUpdated => 'Profile photo updated';

	/// en: 'Tap to change photo'
	String get tapToChangePhoto => 'Tap to change photo';

	/// en: 'Happy Birthday!'
	String get happyBirthday => 'Happy Birthday!';

	/// en: 'Wishing you an amazing day exploring the Galápagos!'
	String get happyBirthdayMessage => 'Wishing you an amazing day exploring the Galápagos!';

	/// en: 'Don't have an account? Sign up'
	String get signUpPrompt => 'Don\'t have an account? Sign up';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'English'
	String get english => 'English';

	/// en: 'Español'
	String get spanish => 'Español';

	/// en: 'Offline Data'
	String get offlineData => 'Offline Data';

	/// en: 'Download All Data'
	String get downloadData => 'Download All Data';

	/// en: 'Clear Cache'
	String get clearCache => 'Clear Cache';

	/// en: 'Cache cleared'
	String get cacheCleared => 'Cache cleared';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Version'
	String get version => 'Version';

	/// en: 'Credits'
	String get credits => 'Credits';

	/// en: 'Privacy Policy'
	String get privacyPolicy => 'Privacy Policy';

	/// en: 'Terms of Service'
	String get termsOfService => 'Terms of Service';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'System'
	String get system => 'System';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';

	/// en: 'Signed in'
	String get signedIn => 'Signed in';

	/// en: 'Last Synced'
	String get lastSynced => 'Last Synced';

	/// en: 'Never synced'
	String get neverSynced => 'Never synced';

	/// en: 'Just now'
	String get justNow => 'Just now';

	/// en: '${minutes} min ago'
	String minutesAgo({required Object minutes}) => '${minutes} min ago';

	/// en: '${hours}h ago'
	String hoursAgo({required Object hours}) => '${hours}h ago';

	/// en: '${days}d ago'
	String daysAgo({required Object days}) => '${days}d ago';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Badge Notifications'
	String get badgeNotifications => 'Badge Notifications';

	/// en: 'Show alerts when you earn new badges'
	String get badgeNotificationsDesc => 'Show alerts when you earn new badges';

	/// en: 'Sighting Reminders'
	String get sightingReminders => 'Sighting Reminders';

	/// en: 'Reminders to log your wildlife sightings'
	String get sightingRemindersDesc => 'Reminders to log your wildlife sightings';

	/// en: 'Sync Alerts'
	String get syncAlerts => 'Sync Alerts';

	/// en: 'Notify when data syncs with server'
	String get syncAlertsDesc => 'Notify when data syncs with server';

	/// en: 'Offline Images'
	String get offlineImages => 'Offline Images';

	/// en: 'Download All Images'
	String get downloadAllImages => 'Download All Images';

	/// en: 'Download all species images for offline viewing'
	String get downloadImagesDesc => 'Download all species images for offline viewing';

	/// en: 'Downloading images: ${current}/${total}'
	String downloadingImages({required Object current, required Object total}) => 'Downloading images: ${current}/${total}';

	/// en: 'All images downloaded'
	String get imagesDownloaded => 'All images downloaded';

	/// en: 'Image download failed'
	String get imageDownloadFailed => 'Image download failed';

	/// en: 'Estimated size: ~${size} MB'
	String estimatedSize({required Object size}) => 'Estimated size: ~${size} MB';

	/// en: 'Images already downloaded'
	String get imagesAlreadyCached => 'Images already downloaded';

	/// en: 'Text Size'
	String get textSize => 'Text Size';

	/// en: 'Adjust text size across the entire app'
	String get textSizeDesc => 'Adjust text size across the entire app';

	/// en: 'Current: ${percent}%'
	String textSizeCurrent({required Object percent}) => 'Current: ${percent}%';

	/// en: 'Small'
	String get textSizeSmall => 'Small';

	/// en: 'Normal'
	String get textSizeNormal => 'Normal';

	/// en: 'Large'
	String get textSizeLarge => 'Large';
}

// Path: admin
class TranslationsAdminEn {
	TranslationsAdminEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Administration'
	String get title => 'Administration';

	/// en: 'Admin Panel'
	String get panel => 'Admin Panel';

	/// en: 'Manage species, islands, and content'
	String get panelSubtitle => 'Manage species, islands, and content';

	/// en: 'Dashboard'
	String get dashboard => 'Dashboard';

	/// en: 'Species'
	String get species => 'Species';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Islands'
	String get islands => 'Islands';

	/// en: 'Visit Sites'
	String get visitSites => 'Visit Sites';

	/// en: 'Images'
	String get images => 'Images';

	/// en: 'Species-Sites'
	String get speciesSites => 'Species-Sites';

	/// en: 'Sites'
	String get sites => 'Sites';

	/// en: 'Exit Admin'
	String get exitAdmin => 'Exit Admin';

	/// en: 'New'
	String get newItem => 'New';

	/// en: 'Edit'
	String get editItem => 'Edit';

	/// en: 'Are you sure you want to delete this item?'
	String get deleteConfirm => 'Are you sure you want to delete this item?';

	/// en: 'This action cannot be undone.'
	String get deleteWarning => 'This action cannot be undone.';

	/// en: 'Saved successfully'
	String get saved => 'Saved successfully';

	/// en: 'Deleted successfully'
	String get deleted => 'Deleted successfully';

	/// en: 'Required'
	String get required => 'Required';

	/// en: 'Select a category'
	String get selectCategory => 'Select a category';

	/// en: 'Select an island'
	String get selectIsland => 'Select an island';

	/// en: 'Upload Image'
	String get uploadImage => 'Upload Image';

	/// en: 'Processing image...'
	String get processing => 'Processing image...';

	/// en: 'Manage wildlife entries'
	String get manageContent => 'Manage wildlife entries';

	/// en: 'Species categories'
	String get manageCategories => 'Species categories';

	/// en: 'Galápagos islands'
	String get manageIslands => 'Galápagos islands';

	/// en: 'Visitor locations'
	String get manageSites => 'Visitor locations';

	/// en: 'Species photos'
	String get manageImages => 'Species photos';

	/// en: 'Location mappings'
	String get manageRelationships => 'Location mappings';

	/// en: 'Back to home'
	String get backToHome => 'Back to home';

	/// en: 'Hide menu'
	String get hideMenu => 'Hide menu';

	/// en: 'Show menu'
	String get showMenu => 'Show menu';

	/// en: 'Search by name (EN/ES) or scientific name...'
	String get searchSpecies => 'Search by name (EN/ES) or scientific name...';

	/// en: 'No results for "${query}"'
	String noResultsFor({required Object query}) => 'No results for "${query}"';

	/// en: 'No species yet'
	String get noSpeciesYet => 'No species yet';

	/// en: 'No categories yet'
	String get noCategoriesYet => 'No categories yet';

	/// en: 'No islands yet'
	String get noIslandsYet => 'No islands yet';

	/// en: 'No visit sites yet'
	String get noVisitSitesYet => 'No visit sites yet';

	/// en: 'No images yet'
	String get noImagesYet => 'No images yet';

	/// en: 'No relationships yet'
	String get noRelationshipsYet => 'No relationships yet';

	/// en: 'Tap + to add gallery images'
	String get tapAddImages => 'Tap + to add gallery images';

	/// en: 'Add Relationship'
	String get addRelationship => 'Add Relationship';

	/// en: 'Please select both species and site'
	String get selectBothRequired => 'Please select both species and site';

	/// en: 'Relationship added'
	String get relationshipAdded => 'Relationship added';

	/// en: 'Image added'
	String get imageAdded => 'Image added';

	/// en: 'Crop Image (16:9)'
	String get cropImage => 'Crop Image (16:9)';

	/// en: 'Tap to add image (16:9)'
	String get tapToAddImage => 'Tap to add image (16:9)';

	/// en: 'Change'
	String get changeImage => 'Change';

	/// en: 'Species updated'
	String get speciesUpdated => 'Species updated';

	/// en: 'Species created'
	String get speciesCreated => 'Species created';

	/// en: 'Category updated'
	String get categoryUpdated => 'Category updated';

	/// en: 'Category created'
	String get categoryCreated => 'Category created';

	/// en: 'Island updated'
	String get islandUpdated => 'Island updated';

	/// en: 'Island created'
	String get islandCreated => 'Island created';

	/// en: 'Visit site updated'
	String get visitSiteUpdated => 'Visit site updated';

	/// en: 'Visit site created'
	String get visitSiteCreated => 'Visit site created';

	/// en: 'Please select an island'
	String get selectIslandRequired => 'Please select an island';

	/// en: 'Please select a category'
	String get selectCategoryRequired => 'Please select a category';

	/// en: 'Hero Image'
	String get heroImage => 'Hero Image';

	/// en: 'Basic Info'
	String get basicInfo => 'Basic Info';

	/// en: 'Common Name'
	String get commonName => 'Common Name';

	/// en: 'Category & Conservation'
	String get categoryConservation => 'Category & Conservation';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Conservation'
	String get conservation => 'Conservation';

	/// en: 'Endemic'
	String get endemic => 'Endemic';

	/// en: 'Physical Characteristics'
	String get physicalChars => 'Physical Characteristics';

	/// en: 'Weight (kg)'
	String get weightKg => 'Weight (kg)';

	/// en: 'Size (cm)'
	String get sizeCm => 'Size (cm)';

	/// en: 'Population'
	String get populationField => 'Population';

	/// en: 'Lifespan (years)'
	String get lifespanYears => 'Lifespan (years)';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Slug'
	String get slug => 'Slug';

	/// en: 'Icon Name'
	String get iconName => 'Icon Name';

	/// en: 'Sort Order'
	String get sortOrder => 'Sort Order';

	/// en: 'Latitude'
	String get latitude => 'Latitude';

	/// en: 'Longitude'
	String get longitude => 'Longitude';

	/// en: 'Area (km²)'
	String get areaKm2 => 'Area (km²)';

	/// en: 'Island'
	String get island => 'Island';

	/// en: 'Site Type'
	String get siteType => 'Site Type';

	/// en: 'Frequency'
	String get frequency => 'Frequency';

	/// en: 'Species Images'
	String get speciesImages => 'Species Images';

	/// en: 'Primary'
	String get primaryImage => 'Primary';

	/// en: 'Set as primary'
	String get setPrimary => 'Set as primary';

	/// en: 'Primary image set'
	String get primarySet => 'Primary image set';

	/// en: 'Manage Images'
	String get manageImagesBtn => 'Manage Images';

	/// en: 'Save the species first, then manage images'
	String get saveFirstToManageImages => 'Save the species first, then manage images';

	/// en: 'Are you sure you want to delete "${name}"? This action cannot be undone.'
	String confirmDeleteNamed({required Object name}) => 'Are you sure you want to delete "${name}"?\n\nThis action cannot be undone.';

	/// en: 'Unsaved Changes'
	String get unsavedChangesTitle => 'Unsaved Changes';

	/// en: 'You have unsaved changes. Discard them?'
	String get unsavedChangesMessage => 'You have unsaved changes. Discard them?';

	/// en: 'Discard'
	String get discard => 'Discard';

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'Trash'
	String get trash => 'Trash';

	/// en: 'Delete Permanently'
	String get deletePermanently => 'Delete Permanently';

	/// en: 'Permanently delete "${name}"? This action cannot be undone.'
	String confirmDeletePermanently({required Object name}) => 'Permanently delete "${name}"?\n\nThis action cannot be undone.';

	/// en: 'Restore the item to edit it'
	String get restoreToEdit => 'Restore the item to edit it';

	/// en: '${count} selected'
	String itemsSelected({required Object count}) => '${count} selected';

	/// en: 'Restore'
	String get restore => 'Restore';

	/// en: 'Restored successfully'
	String get restored => 'Restored successfully';

	/// en: 'Remove Species from Site'
	String get deleteSpeciesFromSite => 'Remove Species from Site';

	/// en: 'Remove "${name}" from this site?'
	String confirmDeleteSpeciesFromSite({required Object name}) => 'Remove "${name}" from this site?';

	/// en: 'Species removed from site'
	String get speciesRemovedFromSite => 'Species removed from site';

	/// en: 'Species added to site'
	String get speciesAddedToSite => 'Species added to site';

	/// en: 'Select a species'
	String get selectSpeciesRequired => 'Select a species';

	/// en: 'This species is already associated with this site'
	String get speciesAlreadyAssociated => 'This species is already associated with this site';

	/// en: 'This species-site relationship already exists'
	String get relationshipAlreadyExists => 'This species-site relationship already exists';

	/// en: 'Taxonomy Management'
	String get manageTaxonomy => 'Taxonomy Management';

	/// en: 'Search...'
	String get search => 'Search...';

	/// en: 'Confirm Deletion'
	String get confirmDeleteTitle => 'Confirm Deletion';

	/// en: 'Delete ${count} items?'
	String confirmDeleteCount({required Object count}) => 'Delete ${count} items?';

	/// en: 'Permanently delete ${count} items? This action cannot be undone.'
	String confirmDeletePermanentlyCount({required Object count}) => 'Permanently delete ${count} items? This action cannot be undone.';

	/// en: '${count} in trash'
	String inTrash({required Object count}) => '${count} in trash';

	/// en: 'Trash is empty'
	String get emptyTrash => 'Trash is empty';

	/// en: 'Deleted'
	String get deletedLabel => 'Deleted';

	/// en: 'Deleted: ${date}'
	String deletedOn({required Object date}) => 'Deleted: ${date}';

	/// en: 'Classes'
	String get taxonomyClasses => 'Classes';

	/// en: 'Orders'
	String get taxonomyOrders => 'Orders';

	/// en: 'Families'
	String get taxonomyFamilies => 'Families';

	/// en: 'Genera'
	String get taxonomyGenera => 'Genera';

	/// en: 'Classes, orders, families, genera'
	String get taxonomySubtitle => 'Classes, orders, families, genera';

	/// en: 'Error loading statistics: ${error}'
	String errorLoadingStats({required Object error}) => 'Error loading statistics: ${error}';

	/// en: 'Sites without associated species'
	String get sitesWithoutSpecies => 'Sites without associated species';

	/// en: 'Species without images'
	String get speciesWithoutImages => 'Species without images';

	/// en: 'Statistics'
	String get statistics => 'Statistics';

	/// en: 'Species by Category'
	String get speciesByCategory => 'Species by Category';

	/// en: 'No data'
	String get noData => 'No data';

	/// en: 'Data Coverage'
	String get dataCoverage => 'Data Coverage';

	/// en: 'Visit Sites'
	String get visitSitesSection => 'Visit Sites';

	/// en: 'No visit sites for this island. Use the "Visit Sites" section to create new ones.'
	String get noVisitSitesForIsland => 'No visit sites for this island. Use the "Visit Sites" section to create new ones.';

	/// en: 'Save the island first to see its visit sites'
	String get saveIslandFirst => 'Save the island first to see its visit sites';

	/// en: 'Unnamed'
	String get unnamed => 'Unnamed';

	/// en: 'Species'
	String get speciesSection => 'Species';

	/// en: 'Error loading islands: ${error}'
	String errorLoadingIslands({required Object error}) => 'Error loading islands: ${error}';

	/// en: 'Error loading species: ${error}'
	String errorLoadingSpecies({required Object error}) => 'Error loading species: ${error}';

	/// en: 'Error loading sites: ${error}'
	String errorLoadingSites({required Object error}) => 'Error loading sites: ${error}';

	/// en: 'General'
	String get tabGeneral => 'General';

	/// en: 'Description'
	String get tabDescription => 'Description';

	/// en: 'Location'
	String get location => 'Location';

	/// en: 'Add Species'
	String get addSpecies => 'Add Species';

	/// en: 'Adding...'
	String get adding => 'Adding...';

	/// en: 'Save the site first to add species'
	String get saveSiteFirst => 'Save the site first to add species';

	/// en: 'No species associated with this site'
	String get noSpeciesForSite => 'No species associated with this site';

	/// en: 'No taxonomy classes yet'
	String get noTaxonomyClasses => 'No taxonomy classes yet';

	/// en: 'No orders in this class'
	String get noOrdersInClass => 'No orders in this class';

	/// en: 'No families in this order'
	String get noFamiliesInOrder => 'No families in this order';

	/// en: 'No genera in this family'
	String get noGeneraInFamily => 'No genera in this family';

	/// en: 'This will also delete all child items.'
	String get deleteChildrenWarning => 'This will also delete all child items.';

	/// en: 'Trail'
	String get siteTypeTrail => 'Trail';

	/// en: 'Beach'
	String get siteTypeBeach => 'Beach';

	/// en: 'Snorkeling'
	String get siteTypeSnorkeling => 'Snorkeling';

	/// en: 'Diving'
	String get siteTypeDiving => 'Diving';

	/// en: 'Viewpoint'
	String get siteTypeViewpoint => 'Viewpoint';

	/// en: 'Dock'
	String get siteTypeDock => 'Dock';

	/// en: 'Selecting image...'
	String get uploadPicking => 'Selecting image...';

	/// en: 'Cropping image...'
	String get uploadCropping => 'Cropping image...';

	/// en: 'Compressing image...'
	String get uploadCompressing => 'Compressing image...';

	/// en: 'Uploading image...'
	String get uploadUploading => 'Uploading image...';

	/// en: 'Generating thumbnail...'
	String get uploadGeneratingThumbnail => 'Generating thumbnail...';

	/// en: 'Image uploaded!'
	String get uploadDone => 'Image uploaded!';

	/// en: 'Error uploading image'
	String get uploadError => 'Error uploading image';

	/// en: 'Classifications'
	String get siteCatalogs => 'Classifications';

	/// en: 'Types, modalities & activities'
	String get manageCatalogs => 'Types, modalities & activities';

	/// en: 'Users'
	String get users => 'Users';

	/// en: 'Manage access and roles'
	String get manageUsers => 'Manage access and roles';

	/// en: 'Details'
	String get tabDetails => 'Details';

	/// en: 'Population Trend'
	String get populationTrend => 'Population Trend';

	/// en: 'Increasing'
	String get trendIncreasing => 'Increasing';

	/// en: 'Stable'
	String get trendStable => 'Stable';

	/// en: 'Decreasing'
	String get trendDecreasing => 'Decreasing';

	/// en: 'Unknown'
	String get trendUnknown => 'Unknown';

	/// en: 'Native'
	String get native => 'Native';

	/// en: 'Introduced'
	String get introduced => 'Introduced';

	/// en: 'Endemism Level'
	String get endemismLevel => 'Endemism Level';

	/// en: 'Archipelago Endemic'
	String get endemismArchipelago => 'Archipelago Endemic';

	/// en: 'Island-Specific Endemic'
	String get endemismIslandSpecific => 'Island-Specific Endemic';

	/// en: 'Behavior'
	String get behavior => 'Behavior';

	/// en: 'Social Structure'
	String get socialStructure => 'Social Structure';

	/// en: 'Solitary'
	String get socialSolitary => 'Solitary';

	/// en: 'Pair'
	String get socialPair => 'Pair';

	/// en: 'Small Group'
	String get socialSmallGroup => 'Small Group';

	/// en: 'Colony'
	String get socialColony => 'Colony';

	/// en: 'Harem'
	String get socialHarem => 'Harem';

	/// en: 'Activity Pattern'
	String get activityPattern => 'Activity Pattern';

	/// en: 'Diurnal'
	String get activityDiurnal => 'Diurnal';

	/// en: 'Nocturnal'
	String get activityNocturnal => 'Nocturnal';

	/// en: 'Crepuscular'
	String get activityCrepuscular => 'Crepuscular';

	/// en: 'Diet Type'
	String get dietType => 'Diet Type';

	/// en: 'Carnivore'
	String get dietCarnivore => 'Carnivore';

	/// en: 'Herbivore'
	String get dietHerbivore => 'Herbivore';

	/// en: 'Omnivore'
	String get dietOmnivore => 'Omnivore';

	/// en: 'Insectivore'
	String get dietInsectivore => 'Insectivore';

	/// en: 'Piscivore'
	String get dietPiscivore => 'Piscivore';

	/// en: 'Frugivore'
	String get dietFrugivore => 'Frugivore';

	/// en: 'Nectarivore'
	String get dietNectarivore => 'Nectarivore';

	/// en: 'Primary Food Sources'
	String get primaryFoodSources => 'Primary Food Sources';

	/// en: 'Reproduction'
	String get reproduction => 'Reproduction';

	/// en: 'Breeding Season'
	String get breedingSeason => 'Breeding Season';

	/// en: 'Clutch Size'
	String get clutchSize => 'Clutch Size';

	/// en: 'Reproductive Frequency'
	String get reproductiveFrequency => 'Reproductive Frequency';

	/// en: 'Distinguishing Features'
	String get distinguishingFeatures => 'Distinguishing Features';

	/// en: 'Distinguishing Features (ES)'
	String get distinguishingFeaturesEs => 'Distinguishing Features (ES)';

	/// en: 'Distinguishing Features (EN)'
	String get distinguishingFeaturesEn => 'Distinguishing Features (EN)';

	/// en: 'Sexual Dimorphism'
	String get sexualDimorphism => 'Sexual Dimorphism';

	/// en: 'Geographic Ranges'
	String get geographicRanges => 'Geographic Ranges';

	/// en: 'Altitude Min (m)'
	String get altitudeMinM => 'Altitude Min (m)';

	/// en: 'Altitude Max (m)'
	String get altitudeMaxM => 'Altitude Max (m)';

	/// en: 'Depth Min (m)'
	String get depthMinM => 'Depth Min (m)';

	/// en: 'Depth Max (m)'
	String get depthMaxM => 'Depth Max (m)';
}

// Path: badges
class TranslationsBadgesEn {
	TranslationsBadgesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Achievements'
	String get title => 'Achievements';

	/// en: 'No badges yet'
	String get empty => 'No badges yet';

	/// en: 'Start exploring to earn badges!'
	String get emptySubtitle => 'Start exploring to earn badges!';

	/// en: 'Unlocked!'
	String get unlocked => 'Unlocked!';

	/// en: 'Locked'
	String get locked => 'Locked';

	/// en: '${current} / ${target}'
	String progress({required Object current, required Object target}) => '${current} / ${target}';

	/// en: 'First Sighting'
	String get firstSighting => 'First Sighting';

	/// en: 'Record your first wildlife sighting'
	String get firstSightingDesc => 'Record your first wildlife sighting';

	/// en: 'Explorer'
	String get explorer => 'Explorer';

	/// en: 'Record 10 sightings'
	String get explorerDesc => 'Record 10 sightings';

	/// en: 'Field Researcher'
	String get fieldResearcher => 'Field Researcher';

	/// en: 'Record 50 sightings'
	String get fieldResearcherDesc => 'Record 50 sightings';

	/// en: 'Naturalist'
	String get naturalist => 'Naturalist';

	/// en: 'Spot 5 different species'
	String get naturalistDesc => 'Spot 5 different species';

	/// en: 'Biologist'
	String get biologist => 'Biologist';

	/// en: 'Spot 20 different species'
	String get biologistDesc => 'Spot 20 different species';

	/// en: 'Endemic Explorer'
	String get endemicExplorer => 'Endemic Explorer';

	/// en: 'Spot 5 endemic species'
	String get endemicExplorerDesc => 'Spot 5 endemic species';

	/// en: 'Island Hopper'
	String get islandHopper => 'Island Hopper';

	/// en: 'Visit 3 different islands'
	String get islandHopperDesc => 'Visit 3 different islands';

	/// en: 'Photographer'
	String get photographer => 'Photographer';

	/// en: 'Take 10 sighting photos'
	String get photographerDesc => 'Take 10 sighting photos';

	/// en: 'Curator'
	String get curator => 'Curator';

	/// en: 'Add 10 species to favorites'
	String get curatorDesc => 'Add 10 species to favorites';

	/// en: 'Conservationist'
	String get conservationist => 'Conservationist';

	/// en: 'Spot 3 threatened species (CR/EN/VU)'
	String get conservationistDesc => 'Spot 3 threatened species (CR/EN/VU)';

	/// en: 'Badge Unlocked!'
	String get badgeUnlocked => 'Badge Unlocked!';

	/// en: 'You earned: ${name}'
	String youEarned({required Object name}) => 'You earned: ${name}';

	/// en: 'Congratulations!'
	String get congratulations => 'Congratulations!';
}

// Path: offline
class TranslationsOfflineEn {
	TranslationsOfflineEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Island Download Packs'
	String get downloadPacks => 'Island Download Packs';

	/// en: 'Download Island Pack'
	String get downloadPack => 'Download Island Pack';

	/// en: 'Downloaded'
	String get packageDownloaded => 'Downloaded';

	/// en: 'packages'
	String get packages => 'packages';

	/// en: 'Downloaded'
	String get downloaded => 'Downloaded';

	/// en: 'Available to Download'
	String get available => 'Available to Download';

	/// en: 'Island Packages'
	String get packagesInfo => 'Island Packages';

	/// en: 'Download complete island packages including map tiles, species data, visit sites, and images for offline use.'
	String get packagesDescription => 'Download complete island packages including map tiles, species data, visit sites, and images for offline use.';

	/// en: 'No packages available'
	String get noPackages => 'No packages available';

	/// en: 'Download the complete package for this island?'
	String get downloadConfirmation => 'Download the complete package for this island?';

	/// en: 'This will download map tiles and images. Make sure you have a stable internet connection.'
	String get downloadWarning => 'This will download map tiles and images. Make sure you have a stable internet connection.';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Downloading'
	String get downloading => 'Downloading';

	/// en: 'Sync Status'
	String get syncStatus => 'Sync Status';

	/// en: 'Online'
	String get online => 'Online';

	/// en: 'Offline'
	String get offline => 'Offline';

	/// en: 'Last synced'
	String get lastSynced => 'Last synced';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'All synced'
	String get allSynced => 'All synced';

	/// en: 'Sync Now'
	String get syncNow => 'Sync Now';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Something went wrong'
	String get error => 'Something went wrong';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'No'
	String get no => 'No';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Clear search'
	String get clearSearch => 'Clear search';

	/// en: '${count} items'
	String items({required Object count}) => '${count} items';

	/// en: 'Unsaved Changes'
	String get unsavedChangesTitle => 'Unsaved Changes';

	/// en: 'You have unsaved changes. Discard them?'
	String get unsavedChangesMessage => 'You have unsaved changes. Discard them?';

	/// en: 'Discard'
	String get discard => 'Discard';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'images'
	String get images => 'images';

	/// en: 'You are offline'
	String get offline => 'You are offline';

	/// en: 'Some features may be limited'
	String get offlineSubtitle => 'Some features may be limited';

	/// en: 'Offline Mode'
	String get offlineMode => 'Offline Mode';

	/// en: 'Technical Details'
	String get details => 'Technical Details';
}

// Path: error
class TranslationsErrorEn {
	TranslationsErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No Internet Connection'
	String get network => 'No Internet Connection';

	/// en: 'Please check your internet connection and try again.'
	String get networkDesc => 'Please check your internet connection and try again.';

	/// en: 'Request Timed Out'
	String get timeout => 'Request Timed Out';

	/// en: 'The request took too long. Please try again later.'
	String get timeoutDesc => 'The request took too long. Please try again later.';

	/// en: 'Data Error'
	String get parsing => 'Data Error';

	/// en: 'Unable to process the data. Please try again or contact support.'
	String get parsingDesc => 'Unable to process the data. Please try again or contact support.';

	/// en: 'Authentication Error'
	String get authentication => 'Authentication Error';

	/// en: 'Your session has expired. Please sign in again.'
	String get authenticationDesc => 'Your session has expired. Please sign in again.';

	/// en: 'Not Found'
	String get notFound => 'Not Found';

	/// en: 'The requested resource was not found.'
	String get notFoundDesc => 'The requested resource was not found.';

	/// en: 'Server Error'
	String get serverError => 'Server Error';

	/// en: 'The server is experiencing issues. Please try again later.'
	String get serverErrorDesc => 'The server is experiencing issues. Please try again later.';

	/// en: 'An unexpected error occurred. Please try again.'
	String get unknownDesc => 'An unexpected error occurred. Please try again.';
}

// Path: sync
class TranslationsSyncEn {
	TranslationsSyncEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Galápagos Wildlife'
	String get appName => 'Galápagos Wildlife';

	/// en: 'Downloading ${table}...'
	String downloading({required Object table}) => 'Downloading ${table}...';

	/// en: 'Preparing...'
	String get preparing => 'Preparing...';

	/// en: 'Could not download data.'
	String get errorTitle => 'Could not download data.';

	/// en: 'Please check your internet connection.'
	String get errorSubtitle => 'Please check your internet connection.';

	/// en: 'Retry'
	String get retry => 'Retry';
}

// Path: location
class TranslationsLocationEn {
	TranslationsLocationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Location services are disabled'
	String get servicesDisabled => 'Location services are disabled';

	/// en: 'Location permission denied'
	String get permissionDenied => 'Location permission denied';

	/// en: 'Location obtained'
	String get locationObtained => 'Location obtained';
}

// Path: onboarding
class TranslationsOnboardingEn {
	TranslationsOnboardingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome to Galápagos Wildlife'
	String get welcome => 'Welcome to Galápagos Wildlife';

	/// en: 'Discover Wildlife'
	String get discoverTitle => 'Discover Wildlife';

	/// en: 'Browse 40+ species of birds, reptiles, mammals and marine life unique to the islands'
	String get discoverDesc => 'Browse 40+ species of birds, reptiles, mammals and marine life unique to the islands';

	/// en: 'Explore the Islands'
	String get mapTitle => 'Explore the Islands';

	/// en: 'Interactive map with islands, visit sites, and offline tile support'
	String get mapDesc => 'Interactive map with islands, visit sites, and offline tile support';

	/// en: 'Record Sightings'
	String get sightingsTitle => 'Record Sightings';

	/// en: 'Log your wildlife encounters with photos, location, and notes'
	String get sightingsDesc => 'Log your wildlife encounters with photos, location, and notes';

	/// en: 'Earn Badges'
	String get badgesTitle => 'Earn Badges';

	/// en: 'Track your progress and unlock achievements as you explore'
	String get badgesDesc => 'Track your progress and unlock achievements as you explore';

	/// en: 'Get Started'
	String get getStarted => 'Get Started';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Skip'
	String get skip => 'Skip';
}

// Path: search
class TranslationsSearchEn {
	TranslationsSearchEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search'
	String get title => 'Search';

	/// en: 'Search species, islands, sites...'
	String get hint => 'Search species, islands, sites...';

	/// en: 'No results found'
	String get noResults => 'No results found';

	/// en: 'Try a different search term'
	String get noResultsSubtitle => 'Try a different search term';

	/// en: 'Species'
	String get speciesSection => 'Species';

	/// en: 'Islands'
	String get islandsSection => 'Islands';

	/// en: 'Visit Sites'
	String get sitesSection => 'Visit Sites';
}

// Path: leaderboard
class TranslationsLeaderboardEn {
	TranslationsLeaderboardEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Leaderboard'
	String get title => 'Leaderboard';

	/// en: 'Rank'
	String get rank => 'Rank';

	/// en: 'Sightings'
	String get sightings => 'Sightings';

	/// en: 'Species'
	String get species => 'Species';

	/// en: 'Photos'
	String get photos => 'Photos';

	/// en: 'You'
	String get you => 'You';

	/// en: 'No sightings recorded yet. Be the first!'
	String get empty => 'No sightings recorded yet. Be the first!';

	/// en: 'Top Explorer'
	String get topExplorer => 'Top Explorer';
}

// Path: share
class TranslationsShareEn {
	TranslationsShareEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Share species'
	String get species => 'Share species';

	/// en: 'Check out ${name} (${scientificName}) on Galápagos Wildlife!'
	String shareText({required Object name, required Object scientificName}) => 'Check out ${name} (${scientificName}) on Galápagos Wildlife!';

	/// en: 'Copied to clipboard'
	String get copiedToClipboard => 'Copied to clipboard';
}

// Path: celebrations
class TranslationsCelebrationsEn {
	TranslationsCelebrationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Celebrations'
	String get title => 'Celebrations';

	/// en: 'Today: ${event}'
	String todayEvent({required Object event}) => 'Today: ${event}';

	/// en: 'It's your birthday!'
	String get birthdayOverlay => 'It\'s your birthday!';
}

// Path: errors
class TranslationsErrorsEn {
	TranslationsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No internet connection. Please check your network.'
	String get network => 'No internet connection. Please check your network.';

	/// en: 'Request timed out. Please try again.'
	String get timeout => 'Request timed out. Please try again.';

	/// en: 'Authentication error. Please sign in again.'
	String get auth => 'Authentication error. Please sign in again.';

	/// en: 'Storage error. Please try again.'
	String get storage => 'Storage error. Please try again.';

	/// en: 'Please check your input.'
	String get validation => 'Please check your input.';

	/// en: 'An unexpected error occurred.'
	String get unknown => 'An unexpected error occurred.';

	/// en: 'Try Again'
	String get tryAgain => 'Try Again';
}

// Path: fieldEdit
class TranslationsFieldEditEn {
	TranslationsFieldEditEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Field Edit'
	String get title => 'Field Edit';

	/// en: 'Field Editing Mode'
	String get mode => 'Field Editing Mode';

	/// en: 'Move Visit Site'
	String get moveVisitSite => 'Move Visit Site';

	/// en: 'Edit Trail'
	String get editTrail => 'Edit Trail';

	/// en: 'Create New Trail'
	String get createNewTrail => 'Create New Trail';

	/// en: 'How to Move Site?'
	String get howToMoveSite => 'How to Move Site?';

	/// en: 'Drag on Map'
	String get dragOnMap => 'Drag on Map';

	/// en: 'All markers become draggable — drag any to its correct position'
	String get dragOnMapDesc => 'All markers become draggable — drag any to its correct position';

	/// en: 'Use Current GPS Location'
	String get useCurrentGps => 'Use Current GPS Location';

	/// en: 'Tap a site marker to move it to your current position'
	String get useCurrentGpsDesc => 'Tap a site marker to move it to your current position';

	/// en: 'How to Edit Trail?'
	String get howToEditTrail => 'How to Edit Trail?';

	/// en: 'Edit on Map'
	String get editOnMap => 'Edit on Map';

	/// en: 'Tap a trail, then add/remove points'
	String get editOnMapDesc => 'Tap a trail, then add/remove points';

	/// en: 'Walk & Record GPS'
	String get walkRecordGps => 'Walk & Record GPS';

	/// en: 'Re-record trail by walking the route'
	String get walkRecordGpsDesc => 'Re-record trail by walking the route';

	/// en: 'How to Create Trail?'
	String get howToCreateTrail => 'How to Create Trail?';

	/// en: 'Draw on Map'
	String get drawOnMap => 'Draw on Map';

	/// en: 'Tap map to add points, drag to adjust'
	String get drawOnMapDesc => 'Tap map to add points, drag to adjust';

	/// en: 'GPS tracking while walking the route'
	String get walkRecordGpsNewDesc => 'GPS tracking while walking the route';

	/// en: 'Correct site location'
	String get correctSiteLocation => 'Correct site location';

	/// en: 'Correct trail path'
	String get correctTrailPath => 'Correct trail path';

	/// en: 'Draw on map or GPS tracking'
	String get drawOnMapOrGps => 'Draw on map or GPS tracking';

	/// en: 'Drag any site marker to move it'
	String get dragAnySiteToMove => 'Drag any site marker to move it';

	/// en: 'Tap a site marker to move it to your current location'
	String get tapSiteToMoveToCurrentLocation => 'Tap a site marker to move it to your current location';

	/// en: 'Tap a trail to start editing'
	String get tapTrailToStartEditing => 'Tap a trail to start editing';

	/// en: 'Tap a trail, then start walking to re-record'
	String get tapTrailThenWalk => 'Tap a trail, then start walking to re-record';

	/// en: 'Tap on map to add trail points'
	String get tapMapToAddPoints => 'Tap on map to add trail points';

	/// en: 'Discard Changes?'
	String get discardChanges => 'Discard Changes?';

	/// en: 'You have unsaved changes. Discard them?'
	String get discardChangesMessage => 'You have unsaved changes. Discard them?';

	/// en: 'Keep Editing'
	String get keepEditing => 'Keep Editing';

	/// en: 'Discard'
	String get discard => 'Discard';

	/// en: 'Done Editing?'
	String get doneEditing => 'Done Editing?';

	/// en: 'Site positions have been saved to the server.'
	String get sitesSaved => 'Site positions have been saved to the server.';

	/// en: 'Save New Trail'
	String get saveNewTrail => 'Save New Trail';

	/// en: 'Trail Name (English)'
	String get trailNameEn => 'Trail Name (English)';

	/// en: 'e.g., Tortuga Bay Trail'
	String get trailNameEnHint => 'e.g., Tortuga Bay Trail';

	/// en: 'Trail Name (Spanish)'
	String get trailNameEs => 'Trail Name (Spanish)';

	/// en: 'e.g., Sendero Bahía Tortuga'
	String get trailNameEsHint => 'e.g., Sendero Bahía Tortuga';

	/// en: 'Continue Recording'
	String get continueRecording => 'Continue Recording';

	/// en: 'Save'
	String get saveTrail => 'Save';

	/// en: 'Need at least 2 points to save trail'
	String get needTwoPoints => 'Need at least 2 points to save trail';

	/// en: 'Please enter trail names in both languages'
	String get enterBothTrailNames => 'Please enter trail names in both languages';

	/// en: 'Save Trail Changes'
	String get saveTrailChanges => 'Save Trail Changes';

	/// en: 'This will replace the existing trail path with the edited coordinates.'
	String get saveTrailChangesDesc => 'This will replace the existing trail path with the edited coordinates.';

	/// en: 'Continue Editing'
	String get continueEditing => 'Continue Editing';

	/// en: 'Save Changes'
	String get saveChanges => 'Save Changes';

	/// en: 'Moving Sites — drag any marker'
	String get movingSitesDrag => 'Moving Sites — drag any marker';

	/// en: 'Moving Site (Drag)'
	String get movingSiteManual => 'Moving Site (Drag)';

	/// en: 'Moving Site (GPS)'
	String get movingSiteGps => 'Moving Site (GPS)';

	/// en: 'Tap a trail to edit'
	String get tapTrailToEdit => 'Tap a trail to edit';

	/// en: 'Editing Trail'
	String get editingTrail => 'Editing Trail';

	/// en: 'Recording Trail (GPS)'
	String get recordingTrailGps => 'Recording Trail (GPS)';

	/// en: 'Creating Trail'
	String get creatingTrail => 'Creating Trail';

	/// en: 'Recording New Trail (GPS)'
	String get recordingNewTrailGps => 'Recording New Trail (GPS)';

	/// en: 'Pause'
	String get pauseRecording => 'Pause';

	/// en: 'Resume'
	String get resumeRecording => 'Resume';

	/// en: 'Stop & Save'
	String get stopAndSave => 'Stop & Save';

	/// en: 'Edit info'
	String get editTrailInfo => 'Edit info';

	/// en: 'Undo'
	String get undo => 'Undo';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete point ${number}'
	String deletePoint({required Object number}) => 'Delete point ${number}';

	/// en: 'Delete ${count} points'
	String deletePoints({required Object count}) => 'Delete ${count} points';

	/// en: 'Tap point(s) • drag moves selection'
	String get tapPointsDragToMove => 'Tap point(s) • drag moves selection';

	/// en: 'Points'
	String get subModePoints => 'Points';

	/// en: 'Move'
	String get subModeMove => 'Move';

	/// en: 'Rotate'
	String get subModeRotate => 'Rotate';
}

// Path: species.frequency
class TranslationsSpeciesFrequencyEn {
	TranslationsSpeciesFrequencyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Common'
	String get common => 'Common';

	/// en: 'Uncommon'
	String get uncommon => 'Uncommon';

	/// en: 'Rare'
	String get rare => 'Rare';

	/// en: 'Occasional'
	String get occasional => 'Occasional';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Galápagos Wildlife',
			'app.subtitle' => 'Explore the enchanted islands',
			'nav.home' => 'Home',
			'nav.species' => 'Species',
			'nav.map' => 'Map',
			'nav.favorites' => 'Favorites',
			'nav.sightings' => 'Sightings',
			'home.welcome' => 'Welcome to Galápagos',
			'home.explore' => 'Explore Wildlife',
			'home.categories' => 'Categories',
			'home.featured' => 'Featured Species',
			'home.quickLinks' => 'Quick Links',
			'home.viewAll' => 'View All',
			'home.discoverSpecies' => 'Discover Species',
			'home.exploreMap' => 'Explore the Map',
			'home.recentSightings' => 'Recent Sightings',
			'home.browseWildlife' => 'Browse all wildlife',
			'home.findSites' => 'Find visit sites and islands',
			'home.logEncounters' => 'Log your wildlife encounters',
			'species.title' => 'Species',
			'species.search' => 'Search species...',
			'species.all' => 'All',
			'species.endemic' => 'Endemic',
			'species.conservationStatus' => 'Conservation Status',
			'species.scientificName' => 'Scientific Name',
			'species.weight' => 'Weight',
			'species.size' => 'Size',
			'species.population' => 'Population',
			'species.lifespan' => 'Lifespan',
			'species.habitat' => 'Habitat',
			'species.description' => 'Description',
			'species.whereToSee' => 'Where to See',
			'species.gallery' => 'Gallery',
			'species.quickFacts' => 'Quick Facts',
			'species.conservationStatusLabel' => ({required Object status}) => 'Conservation status: ${status}',
			'species.years' => 'years',
			'species.kg' => 'kg',
			'species.cm' => 'cm',
			'species.individuals' => 'individuals',
			'species.taxonomy' => 'Taxonomy',
			'species.kingdom' => 'Kingdom',
			'species.phylum' => 'Phylum',
			'species.classLabel' => 'Class',
			'species.order' => 'Order',
			'species.family' => 'Family',
			'species.genus' => 'Genus',
			'species.noResults' => 'No species found',
			'species.noResultsSubtitle' => 'Try a different search term',
			'species.noImages' => 'No additional images',
			'species.addToFavorites' => 'Add to favorites',
			'species.removeFromFavorites' => 'Remove from favorites',
			'species.notFound' => 'Species not found',
			'species.clearFilters' => 'Clear',
			'species.categoryFilter' => 'Category',
			'species.conservationFilter' => 'Conservation & Endemic',
			'species.filterHelp' => 'How filters work',
			'species.filterHelpText' => 'Filters combine to narrow results. Select a category, conservation status, or endemic to filter species.',
			'species.compare' => 'Compare',
			'species.compareSpecies' => 'Compare Species',
			'species.selectTwoSpecies' => 'Select two species to compare',
			'species.vsLabel' => 'VS',
			'species.featuredImageLabel' => ({required Object name}) => 'Featured: ${name}, tap to view details',
			'species.galleryImageLabel' => ({required Object index, required Object total}) => 'Gallery image ${index} of ${total}',
			'species.fullscreenImageLabel' => ({required Object index, required Object total}) => 'Image ${index} of ${total}',
			'species.thumbnailLabel' => ({required Object index}) => 'Thumbnail ${index}, tap to view full image',
			'species.frequency.common' => 'Common',
			'species.frequency.uncommon' => 'Uncommon',
			'species.frequency.rare' => 'Rare',
			'species.frequency.occasional' => 'Occasional',
			'conservation.EX' => 'Extinct',
			'conservation.EW' => 'Extinct in Wild',
			'conservation.CR' => 'Critically Endangered',
			'conservation.EN' => 'Endangered',
			'conservation.VU' => 'Vulnerable',
			'conservation.NT' => 'Near Threatened',
			'conservation.LC' => 'Least Concern',
			'conservation.DD' => 'Data Deficient',
			'conservation.NE' => 'Not Evaluated',
			'map.title' => 'Galápagos Map',
			'map.islands' => 'Islands',
			'map.visitSites' => 'Visit Sites',
			'map.speciesHere' => 'Species here',
			'map.directions' => 'Get Directions',
			'map.offlineTiles' => 'Offline Tiles',
			'map.downloadTiles' => 'Download Map Tiles',
			'map.downloading' => 'Downloading tiles...',
			'map.downloadComplete' => 'Tiles downloaded',
			'map.downloadInProgress' => 'Download in progress...',
			'map.tilesInfo' => 'Download map tiles for offline use',
			'map.toggleSites' => 'Toggle visit sites',
			'map.goToMyLocation' => 'Go to my location',
			'map.locatingDevice' => 'Locating device...',
			'map.centerOnGalapagos' => 'Center on Galápagos',
			'map.cachedTiles' => 'Cached tiles',
			'map.cacheSize' => 'Cache size',
			'map.mb' => 'MB',
			'map.downloadForOffline' => 'Download for offline use',
			'map.estimatedTiles' => ({required Object count}) => 'Estimated tiles: ${count}',
			'map.downloadCancelled' => 'Download cancelled',
			'map.islandArea' => ({required Object area}) => 'Area: ${area} km²',
			'map.yourLocation' => 'Your current location',
			'map.islandLabel' => ({required Object name}) => 'Island: ${name}',
			'map.visitSiteLabel' => ({required Object name}) => 'Visit site: ${name}',
			'map.sightings' => 'Sightings',
			'map.toggleSightings' => 'Toggle sightings',
			'map.sightingLabel' => ({required Object species}) => 'Sighting: ${species}',
			'map.trails' => 'Trails',
			'map.toggleTrails' => 'Toggle trails',
			'map.trailLabel' => ({required Object name}) => 'Trail: ${name}',
			'map.trailDifficulty' => 'Difficulty',
			'map.trailDistance' => ({required Object km}) => '${km} km',
			'map.trailDuration' => ({required Object min}) => '${min} min',
			'map.difficultyEasy' => 'Easy',
			'map.difficultyModerate' => 'Moderate',
			'map.difficultyHard' => 'Hard',
			'map.downloadByIsland' => 'Download by Island',
			'map.downloadAll' => 'Download All Galápagos',
			'map.selectIslands' => 'Select islands to download',
			'map.downloadSelected' => 'Download Selected',
			'map.zoomLevel' => 'Detail level',
			'map.zoomBasic' => 'Basic (less data)',
			'map.zoomDetailed' => 'Detailed (more data)',
			'map.deleteTiles' => 'Delete Tiles',
			'map.tilesDeleted' => 'Tiles deleted',
			'map.tracking' => 'Tracking',
			'map.startTracking' => 'Start Tracking',
			'map.stopTracking' => 'Stop Tracking',
			'map.trackRecorded' => 'Track recorded',
			'map.offRoute' => 'You are off the trail!',
			'map.backOnRoute' => 'Back on trail',
			'map.distanceFromTrail' => ({required Object meters}) => '${meters}m from trail',
			'map.trackDistance' => ({required Object km}) => 'Distance: ${km} km',
			'map.trackDuration' => ({required Object duration}) => 'Duration: ${duration}',
			'map.noTrails' => 'No trails available',
			'map.baseMap' => 'Base Map',
			'map.baseMapVector' => 'Vector (3 MB)',
			'map.baseMapRaster' => 'Raster HD',
			'map.downloadBaseMap' => 'Download Base Map',
			'map.downloadingBaseMap' => 'Downloading base map...',
			'map.baseMapReady' => 'Base map ready',
			'map.baseMapNotDownloaded' => 'Base map not downloaded',
			'map.deleteBaseMap' => 'Delete Base Map',
			'map.baseMapDeleted' => 'Base map deleted',
			'map.switchToVector' => 'Switch to Vector',
			'map.switchToRaster' => 'Switch to HD Raster',
			'map.hdTiles' => 'HD Raster Tiles',
			'map.downloadHdArea' => 'Download HD for this area',
			'map.downloadingHdArea' => 'Downloading HD tiles...',
			'map.hdAreaDownloaded' => 'HD tiles downloaded for this area',
			'map.mapMode' => 'Map Mode',
			'map.vectorOffline' => 'Vector Offline',
			'map.rasterOnline' => 'Raster HD',
			'map.switchMapMode' => 'Switch map mode',
			'map.mapModes' => 'Map Modes',
			'map.modeStreet' => 'Street Map',
			'map.modeStreetDesc' => 'OpenStreetMap with offline caching',
			'map.modeVector' => 'Vector Map',
			'map.modeVectorDesc' => 'Lightweight offline vector tiles (3 MB)',
			'map.modeSatellite' => 'Satellite',
			'map.modeSatelliteDesc' => 'High-resolution satellite imagery (ESRI)',
			'map.modeHybrid' => 'Hybrid',
			'map.modeHybridDesc' => 'Satellite imagery with labels',
			'map.loginRequiredForSatellite' => 'Login required for satellite view',
			'map.filterSites' => 'Filter sites',
			'map.filterVisitSites' => 'Filter visit sites',
			'favorites.title' => 'Favorites',
			'favorites.empty' => 'No favorites yet',
			'favorites.emptySubtitle' => 'Tap the heart icon on any species to add it here',
			'favorites.added' => 'Added to favorites',
			'favorites.removed' => 'Removed from favorites',
			'favorites.loginRequired' => 'Sign in to save favorites',
			'sightings.sightingPhoto' => 'Sighting photo',
			'sightings.title' => 'My Sightings',
			'sightings.add' => 'Add Sighting',
			'sightings.empty' => 'No sightings yet',
			'sightings.emptySubtitle' => 'Record your wildlife encounters',
			'sightings.selectSpecies' => 'Select Species',
			'sightings.selectSite' => 'Select Visit Site',
			'sightings.date' => 'Date',
			'sightings.notes' => 'Notes',
			'sightings.notesHint' => 'What did you observe?',
			'sightings.photo' => 'Photo',
			'sightings.addPhoto' => 'Add Photo',
			'sightings.location' => 'Location',
			'sightings.useCurrentLocation' => 'Use Current Location',
			'sightings.save' => 'Save Sighting',
			'sightings.saved' => 'Sighting saved',
			'sightings.delete' => 'Delete Sighting',
			'sightings.deleteConfirm' => 'Are you sure you want to delete this sighting?',
			'sightings.loginRequired' => 'Sign in to record sightings',
			'sightings.pendingSync' => 'Pending sync',
			'sightings.takePhoto' => 'Take Photo',
			'sightings.fromGallery' => 'Choose from Gallery',
			'sightings.changePhoto' => 'Change Photo',
			'sightings.removePhoto' => 'Remove Photo',
			'sightings.photoAdded' => 'Photo added',
			'sightings.processingPhoto' => 'Processing photo...',
			'sightings.deleted' => 'Sighting deleted',
			'sightings.selectDetail' => 'Select a sighting to view details',
			'sightings.export' => 'Export CSV',
			'sightings.exported' => 'Sightings exported',
			'sightings.noSightingsToExport' => 'No sightings to export',
			'sightings.filters' => 'Filters',
			'sightings.allSpecies' => 'All Species',
			'sightings.dateRange' => 'Date Range',
			'sightings.from' => 'From',
			'sightings.to' => 'To',
			'sightings.clearFilters' => 'Clear Filters',
			'sightings.statistics' => 'Statistics',
			'sightings.totalSightings' => 'Total Sightings',
			'sightings.uniqueSpecies' => 'Unique Species',
			'sightings.thisMonth' => 'This Month',
			'sightings.withPhotos' => 'With Photos',
			'sightings.calendarView' => 'Calendar',
			'sightings.listView' => 'List',
			'sightings.noSightingsInMonth' => 'No sightings this month',
			'auth.signIn' => 'Sign In',
			'auth.signUp' => 'Sign Up',
			'auth.signOut' => 'Sign Out',
			'auth.email' => 'Email',
			'auth.password' => 'Password',
			'auth.forgotPassword' => 'Forgot Password?',
			'auth.noAccount' => 'Don\'t have an account?',
			'auth.hasAccount' => 'Already have an account?',
			'auth.continueAsGuest' => 'Continue as Guest',
			'auth.signInToAccess' => 'Sign in to access this feature',
			'auth.profile' => 'My Profile',
			'auth.memberSince' => ({required Object date}) => 'Member since ${date}',
			'auth.speciesSeen' => 'Species Seen',
			'auth.islandsVisited' => 'Islands Visited',
			'auth.photosTaken' => 'Photos Taken',
			'auth.level' => 'Level',
			'auth.beginner' => 'Beginner',
			'auth.intermediate' => 'Explorer',
			'auth.advanced' => 'Naturalist',
			'auth.expert' => 'Master Naturalist',
			'auth.signInSubtitle' => 'Save favorites and record sightings',
			'auth.recentActivity' => 'Recent Activity',
			'auth.signInToViewProfile' => 'Sign in to view your exploration profile',
			'auth.badgesUnlocked' => ({required Object count, required Object total}) => '${count} / ${total} badges unlocked',
			'auth.noBadgesYet' => 'No badges yet',
			'auth.viewAllBadges' => 'View All Badges',
			'auth.noRecentSightings' => 'No recent sightings',
			'auth.displayName' => 'Display Name',
			'auth.bio' => 'Bio',
			'auth.birthday' => 'Birthday',
			'auth.selectBirthday' => 'Select your birthday',
			'auth.selectCountry' => 'Search country...',
			'auth.country' => 'Country',
			'auth.editProfile' => 'Edit Profile',
			'auth.saveProfile' => 'Save Profile',
			'auth.profileUpdated' => 'Profile updated',
			'auth.avatarUpdated' => 'Profile photo updated',
			'auth.tapToChangePhoto' => 'Tap to change photo',
			'auth.happyBirthday' => 'Happy Birthday!',
			'auth.happyBirthdayMessage' => 'Wishing you an amazing day exploring the Galápagos!',
			'auth.signUpPrompt' => 'Don\'t have an account? Sign up',
			'settings.title' => 'Settings',
			'settings.language' => 'Language',
			'settings.english' => 'English',
			'settings.spanish' => 'Español',
			'settings.offlineData' => 'Offline Data',
			'settings.downloadData' => 'Download All Data',
			'settings.clearCache' => 'Clear Cache',
			'settings.cacheCleared' => 'Cache cleared',
			'settings.about' => 'About',
			'settings.version' => 'Version',
			'settings.credits' => 'Credits',
			'settings.privacyPolicy' => 'Privacy Policy',
			'settings.termsOfService' => 'Terms of Service',
			'settings.theme' => 'Theme',
			'settings.system' => 'System',
			'settings.light' => 'Light',
			'settings.dark' => 'Dark',
			'settings.signedIn' => 'Signed in',
			'settings.lastSynced' => 'Last Synced',
			'settings.neverSynced' => 'Never synced',
			'settings.justNow' => 'Just now',
			'settings.minutesAgo' => ({required Object minutes}) => '${minutes} min ago',
			'settings.hoursAgo' => ({required Object hours}) => '${hours}h ago',
			'settings.daysAgo' => ({required Object days}) => '${days}d ago',
			'settings.notifications' => 'Notifications',
			'settings.badgeNotifications' => 'Badge Notifications',
			'settings.badgeNotificationsDesc' => 'Show alerts when you earn new badges',
			'settings.sightingReminders' => 'Sighting Reminders',
			'settings.sightingRemindersDesc' => 'Reminders to log your wildlife sightings',
			'settings.syncAlerts' => 'Sync Alerts',
			'settings.syncAlertsDesc' => 'Notify when data syncs with server',
			'settings.offlineImages' => 'Offline Images',
			'settings.downloadAllImages' => 'Download All Images',
			'settings.downloadImagesDesc' => 'Download all species images for offline viewing',
			'settings.downloadingImages' => ({required Object current, required Object total}) => 'Downloading images: ${current}/${total}',
			'settings.imagesDownloaded' => 'All images downloaded',
			'settings.imageDownloadFailed' => 'Image download failed',
			'settings.estimatedSize' => ({required Object size}) => 'Estimated size: ~${size} MB',
			'settings.imagesAlreadyCached' => 'Images already downloaded',
			'settings.textSize' => 'Text Size',
			'settings.textSizeDesc' => 'Adjust text size across the entire app',
			'settings.textSizeCurrent' => ({required Object percent}) => 'Current: ${percent}%',
			'settings.textSizeSmall' => 'Small',
			'settings.textSizeNormal' => 'Normal',
			'settings.textSizeLarge' => 'Large',
			'admin.title' => 'Administration',
			'admin.panel' => 'Admin Panel',
			'admin.panelSubtitle' => 'Manage species, islands, and content',
			'admin.dashboard' => 'Dashboard',
			'admin.species' => 'Species',
			'admin.categories' => 'Categories',
			'admin.islands' => 'Islands',
			'admin.visitSites' => 'Visit Sites',
			'admin.images' => 'Images',
			'admin.speciesSites' => 'Species-Sites',
			'admin.sites' => 'Sites',
			'admin.exitAdmin' => 'Exit Admin',
			'admin.newItem' => 'New',
			'admin.editItem' => 'Edit',
			'admin.deleteConfirm' => 'Are you sure you want to delete this item?',
			'admin.deleteWarning' => 'This action cannot be undone.',
			'admin.saved' => 'Saved successfully',
			'admin.deleted' => 'Deleted successfully',
			'admin.required' => 'Required',
			'admin.selectCategory' => 'Select a category',
			'admin.selectIsland' => 'Select an island',
			'admin.uploadImage' => 'Upload Image',
			'admin.processing' => 'Processing image...',
			'admin.manageContent' => 'Manage wildlife entries',
			'admin.manageCategories' => 'Species categories',
			'admin.manageIslands' => 'Galápagos islands',
			'admin.manageSites' => 'Visitor locations',
			'admin.manageImages' => 'Species photos',
			'admin.manageRelationships' => 'Location mappings',
			'admin.backToHome' => 'Back to home',
			'admin.hideMenu' => 'Hide menu',
			'admin.showMenu' => 'Show menu',
			'admin.searchSpecies' => 'Search by name (EN/ES) or scientific name...',
			'admin.noResultsFor' => ({required Object query}) => 'No results for "${query}"',
			'admin.noSpeciesYet' => 'No species yet',
			'admin.noCategoriesYet' => 'No categories yet',
			'admin.noIslandsYet' => 'No islands yet',
			'admin.noVisitSitesYet' => 'No visit sites yet',
			'admin.noImagesYet' => 'No images yet',
			'admin.noRelationshipsYet' => 'No relationships yet',
			'admin.tapAddImages' => 'Tap + to add gallery images',
			'admin.addRelationship' => 'Add Relationship',
			'admin.selectBothRequired' => 'Please select both species and site',
			'admin.relationshipAdded' => 'Relationship added',
			'admin.imageAdded' => 'Image added',
			'admin.cropImage' => 'Crop Image (16:9)',
			'admin.tapToAddImage' => 'Tap to add image (16:9)',
			'admin.changeImage' => 'Change',
			'admin.speciesUpdated' => 'Species updated',
			'admin.speciesCreated' => 'Species created',
			'admin.categoryUpdated' => 'Category updated',
			'admin.categoryCreated' => 'Category created',
			'admin.islandUpdated' => 'Island updated',
			'admin.islandCreated' => 'Island created',
			'admin.visitSiteUpdated' => 'Visit site updated',
			'admin.visitSiteCreated' => 'Visit site created',
			'admin.selectIslandRequired' => 'Please select an island',
			'admin.selectCategoryRequired' => 'Please select a category',
			'admin.heroImage' => 'Hero Image',
			'admin.basicInfo' => 'Basic Info',
			'admin.commonName' => 'Common Name',
			'admin.categoryConservation' => 'Category & Conservation',
			'admin.category' => 'Category',
			'admin.conservation' => 'Conservation',
			'admin.endemic' => 'Endemic',
			'admin.physicalChars' => 'Physical Characteristics',
			'admin.weightKg' => 'Weight (kg)',
			'admin.sizeCm' => 'Size (cm)',
			'admin.populationField' => 'Population',
			'admin.lifespanYears' => 'Lifespan (years)',
			'admin.name' => 'Name',
			'admin.slug' => 'Slug',
			'admin.iconName' => 'Icon Name',
			'admin.sortOrder' => 'Sort Order',
			'admin.latitude' => 'Latitude',
			'admin.longitude' => 'Longitude',
			'admin.areaKm2' => 'Area (km²)',
			'admin.island' => 'Island',
			'admin.siteType' => 'Site Type',
			'admin.frequency' => 'Frequency',
			'admin.speciesImages' => 'Species Images',
			'admin.primaryImage' => 'Primary',
			'admin.setPrimary' => 'Set as primary',
			'admin.primarySet' => 'Primary image set',
			'admin.manageImagesBtn' => 'Manage Images',
			'admin.saveFirstToManageImages' => 'Save the species first, then manage images',
			'admin.confirmDeleteNamed' => ({required Object name}) => 'Are you sure you want to delete "${name}"?\n\nThis action cannot be undone.',
			'admin.unsavedChangesTitle' => 'Unsaved Changes',
			'admin.unsavedChangesMessage' => 'You have unsaved changes. Discard them?',
			'admin.discard' => 'Discard',
			'admin.active' => 'Active',
			'admin.trash' => 'Trash',
			'admin.deletePermanently' => 'Delete Permanently',
			'admin.confirmDeletePermanently' => ({required Object name}) => 'Permanently delete "${name}"?\n\nThis action cannot be undone.',
			'admin.restoreToEdit' => 'Restore the item to edit it',
			'admin.itemsSelected' => ({required Object count}) => '${count} selected',
			'admin.restore' => 'Restore',
			'admin.restored' => 'Restored successfully',
			'admin.deleteSpeciesFromSite' => 'Remove Species from Site',
			'admin.confirmDeleteSpeciesFromSite' => ({required Object name}) => 'Remove "${name}" from this site?',
			'admin.speciesRemovedFromSite' => 'Species removed from site',
			'admin.speciesAddedToSite' => 'Species added to site',
			'admin.selectSpeciesRequired' => 'Select a species',
			'admin.speciesAlreadyAssociated' => 'This species is already associated with this site',
			'admin.relationshipAlreadyExists' => 'This species-site relationship already exists',
			'admin.manageTaxonomy' => 'Taxonomy Management',
			'admin.search' => 'Search...',
			'admin.confirmDeleteTitle' => 'Confirm Deletion',
			'admin.confirmDeleteCount' => ({required Object count}) => 'Delete ${count} items?',
			'admin.confirmDeletePermanentlyCount' => ({required Object count}) => 'Permanently delete ${count} items? This action cannot be undone.',
			'admin.inTrash' => ({required Object count}) => '${count} in trash',
			'admin.emptyTrash' => 'Trash is empty',
			'admin.deletedLabel' => 'Deleted',
			'admin.deletedOn' => ({required Object date}) => 'Deleted: ${date}',
			'admin.taxonomyClasses' => 'Classes',
			'admin.taxonomyOrders' => 'Orders',
			'admin.taxonomyFamilies' => 'Families',
			'admin.taxonomyGenera' => 'Genera',
			'admin.taxonomySubtitle' => 'Classes, orders, families, genera',
			'admin.errorLoadingStats' => ({required Object error}) => 'Error loading statistics: ${error}',
			'admin.sitesWithoutSpecies' => 'Sites without associated species',
			'admin.speciesWithoutImages' => 'Species without images',
			'admin.statistics' => 'Statistics',
			'admin.speciesByCategory' => 'Species by Category',
			'admin.noData' => 'No data',
			'admin.dataCoverage' => 'Data Coverage',
			'admin.visitSitesSection' => 'Visit Sites',
			'admin.noVisitSitesForIsland' => 'No visit sites for this island. Use the "Visit Sites" section to create new ones.',
			'admin.saveIslandFirst' => 'Save the island first to see its visit sites',
			'admin.unnamed' => 'Unnamed',
			'admin.speciesSection' => 'Species',
			'admin.errorLoadingIslands' => ({required Object error}) => 'Error loading islands: ${error}',
			'admin.errorLoadingSpecies' => ({required Object error}) => 'Error loading species: ${error}',
			'admin.errorLoadingSites' => ({required Object error}) => 'Error loading sites: ${error}',
			'admin.tabGeneral' => 'General',
			'admin.tabDescription' => 'Description',
			'admin.location' => 'Location',
			'admin.addSpecies' => 'Add Species',
			'admin.adding' => 'Adding...',
			'admin.saveSiteFirst' => 'Save the site first to add species',
			'admin.noSpeciesForSite' => 'No species associated with this site',
			'admin.noTaxonomyClasses' => 'No taxonomy classes yet',
			'admin.noOrdersInClass' => 'No orders in this class',
			'admin.noFamiliesInOrder' => 'No families in this order',
			'admin.noGeneraInFamily' => 'No genera in this family',
			'admin.deleteChildrenWarning' => 'This will also delete all child items.',
			'admin.siteTypeTrail' => 'Trail',
			'admin.siteTypeBeach' => 'Beach',
			'admin.siteTypeSnorkeling' => 'Snorkeling',
			'admin.siteTypeDiving' => 'Diving',
			'admin.siteTypeViewpoint' => 'Viewpoint',
			'admin.siteTypeDock' => 'Dock',
			'admin.uploadPicking' => 'Selecting image...',
			'admin.uploadCropping' => 'Cropping image...',
			'admin.uploadCompressing' => 'Compressing image...',
			'admin.uploadUploading' => 'Uploading image...',
			'admin.uploadGeneratingThumbnail' => 'Generating thumbnail...',
			'admin.uploadDone' => 'Image uploaded!',
			'admin.uploadError' => 'Error uploading image',
			'admin.siteCatalogs' => 'Classifications',
			'admin.manageCatalogs' => 'Types, modalities & activities',
			'admin.users' => 'Users',
			'admin.manageUsers' => 'Manage access and roles',
			'admin.tabDetails' => 'Details',
			'admin.populationTrend' => 'Population Trend',
			'admin.trendIncreasing' => 'Increasing',
			'admin.trendStable' => 'Stable',
			'admin.trendDecreasing' => 'Decreasing',
			'admin.trendUnknown' => 'Unknown',
			'admin.native' => 'Native',
			'admin.introduced' => 'Introduced',
			'admin.endemismLevel' => 'Endemism Level',
			'admin.endemismArchipelago' => 'Archipelago Endemic',
			'admin.endemismIslandSpecific' => 'Island-Specific Endemic',
			'admin.behavior' => 'Behavior',
			'admin.socialStructure' => 'Social Structure',
			'admin.socialSolitary' => 'Solitary',
			'admin.socialPair' => 'Pair',
			'admin.socialSmallGroup' => 'Small Group',
			'admin.socialColony' => 'Colony',
			'admin.socialHarem' => 'Harem',
			'admin.activityPattern' => 'Activity Pattern',
			'admin.activityDiurnal' => 'Diurnal',
			'admin.activityNocturnal' => 'Nocturnal',
			'admin.activityCrepuscular' => 'Crepuscular',
			'admin.dietType' => 'Diet Type',
			'admin.dietCarnivore' => 'Carnivore',
			'admin.dietHerbivore' => 'Herbivore',
			'admin.dietOmnivore' => 'Omnivore',
			'admin.dietInsectivore' => 'Insectivore',
			'admin.dietPiscivore' => 'Piscivore',
			'admin.dietFrugivore' => 'Frugivore',
			'admin.dietNectarivore' => 'Nectarivore',
			'admin.primaryFoodSources' => 'Primary Food Sources',
			'admin.reproduction' => 'Reproduction',
			'admin.breedingSeason' => 'Breeding Season',
			'admin.clutchSize' => 'Clutch Size',
			'admin.reproductiveFrequency' => 'Reproductive Frequency',
			'admin.distinguishingFeatures' => 'Distinguishing Features',
			'admin.distinguishingFeaturesEs' => 'Distinguishing Features (ES)',
			'admin.distinguishingFeaturesEn' => 'Distinguishing Features (EN)',
			'admin.sexualDimorphism' => 'Sexual Dimorphism',
			'admin.geographicRanges' => 'Geographic Ranges',
			'admin.altitudeMinM' => 'Altitude Min (m)',
			'admin.altitudeMaxM' => 'Altitude Max (m)',
			'admin.depthMinM' => 'Depth Min (m)',
			'admin.depthMaxM' => 'Depth Max (m)',
			'badges.title' => 'Achievements',
			'badges.empty' => 'No badges yet',
			'badges.emptySubtitle' => 'Start exploring to earn badges!',
			_ => null,
		} ?? switch (path) {
			'badges.unlocked' => 'Unlocked!',
			'badges.locked' => 'Locked',
			'badges.progress' => ({required Object current, required Object target}) => '${current} / ${target}',
			'badges.firstSighting' => 'First Sighting',
			'badges.firstSightingDesc' => 'Record your first wildlife sighting',
			'badges.explorer' => 'Explorer',
			'badges.explorerDesc' => 'Record 10 sightings',
			'badges.fieldResearcher' => 'Field Researcher',
			'badges.fieldResearcherDesc' => 'Record 50 sightings',
			'badges.naturalist' => 'Naturalist',
			'badges.naturalistDesc' => 'Spot 5 different species',
			'badges.biologist' => 'Biologist',
			'badges.biologistDesc' => 'Spot 20 different species',
			'badges.endemicExplorer' => 'Endemic Explorer',
			'badges.endemicExplorerDesc' => 'Spot 5 endemic species',
			'badges.islandHopper' => 'Island Hopper',
			'badges.islandHopperDesc' => 'Visit 3 different islands',
			'badges.photographer' => 'Photographer',
			'badges.photographerDesc' => 'Take 10 sighting photos',
			'badges.curator' => 'Curator',
			'badges.curatorDesc' => 'Add 10 species to favorites',
			'badges.conservationist' => 'Conservationist',
			'badges.conservationistDesc' => 'Spot 3 threatened species (CR/EN/VU)',
			'badges.badgeUnlocked' => 'Badge Unlocked!',
			'badges.youEarned' => ({required Object name}) => 'You earned: ${name}',
			'badges.congratulations' => 'Congratulations!',
			'offline.downloadPacks' => 'Island Download Packs',
			'offline.downloadPack' => 'Download Island Pack',
			'offline.packageDownloaded' => 'Downloaded',
			'offline.packages' => 'packages',
			'offline.downloaded' => 'Downloaded',
			'offline.available' => 'Available to Download',
			'offline.packagesInfo' => 'Island Packages',
			'offline.packagesDescription' => 'Download complete island packages including map tiles, species data, visit sites, and images for offline use.',
			'offline.noPackages' => 'No packages available',
			'offline.downloadConfirmation' => 'Download the complete package for this island?',
			'offline.downloadWarning' => 'This will download map tiles and images. Make sure you have a stable internet connection.',
			'offline.download' => 'Download',
			'offline.downloading' => 'Downloading',
			'offline.syncStatus' => 'Sync Status',
			'offline.online' => 'Online',
			'offline.offline' => 'Offline',
			'offline.lastSynced' => 'Last synced',
			'offline.pending' => 'Pending',
			'offline.allSynced' => 'All synced',
			'offline.syncNow' => 'Sync Now',
			'common.loading' => 'Loading...',
			'common.error' => 'Something went wrong',
			'common.retry' => 'Retry',
			'common.cancel' => 'Cancel',
			'common.confirm' => 'Confirm',
			'common.delete' => 'Delete',
			'common.save' => 'Save',
			'common.edit' => 'Edit',
			'common.close' => 'Close',
			'common.ok' => 'OK',
			'common.yes' => 'Yes',
			'common.no' => 'No',
			'common.add' => 'Add',
			'common.clearSearch' => 'Clear search',
			'common.items' => ({required Object count}) => '${count} items',
			'common.unsavedChangesTitle' => 'Unsaved Changes',
			'common.unsavedChangesMessage' => 'You have unsaved changes. Discard them?',
			'common.discard' => 'Discard',
			'common.refresh' => 'Refresh',
			'common.images' => 'images',
			'common.offline' => 'You are offline',
			'common.offlineSubtitle' => 'Some features may be limited',
			'common.offlineMode' => 'Offline Mode',
			'common.details' => 'Technical Details',
			'error.network' => 'No Internet Connection',
			'error.networkDesc' => 'Please check your internet connection and try again.',
			'error.timeout' => 'Request Timed Out',
			'error.timeoutDesc' => 'The request took too long. Please try again later.',
			'error.parsing' => 'Data Error',
			'error.parsingDesc' => 'Unable to process the data. Please try again or contact support.',
			'error.authentication' => 'Authentication Error',
			'error.authenticationDesc' => 'Your session has expired. Please sign in again.',
			'error.notFound' => 'Not Found',
			'error.notFoundDesc' => 'The requested resource was not found.',
			'error.serverError' => 'Server Error',
			'error.serverErrorDesc' => 'The server is experiencing issues. Please try again later.',
			'error.unknownDesc' => 'An unexpected error occurred. Please try again.',
			'sync.appName' => 'Galápagos Wildlife',
			'sync.downloading' => ({required Object table}) => 'Downloading ${table}...',
			'sync.preparing' => 'Preparing...',
			'sync.errorTitle' => 'Could not download data.',
			'sync.errorSubtitle' => 'Please check your internet connection.',
			'sync.retry' => 'Retry',
			'location.servicesDisabled' => 'Location services are disabled',
			'location.permissionDenied' => 'Location permission denied',
			'location.locationObtained' => 'Location obtained',
			'onboarding.welcome' => 'Welcome to Galápagos Wildlife',
			'onboarding.discoverTitle' => 'Discover Wildlife',
			'onboarding.discoverDesc' => 'Browse 40+ species of birds, reptiles, mammals and marine life unique to the islands',
			'onboarding.mapTitle' => 'Explore the Islands',
			'onboarding.mapDesc' => 'Interactive map with islands, visit sites, and offline tile support',
			'onboarding.sightingsTitle' => 'Record Sightings',
			'onboarding.sightingsDesc' => 'Log your wildlife encounters with photos, location, and notes',
			'onboarding.badgesTitle' => 'Earn Badges',
			'onboarding.badgesDesc' => 'Track your progress and unlock achievements as you explore',
			'onboarding.getStarted' => 'Get Started',
			'onboarding.next' => 'Next',
			'onboarding.skip' => 'Skip',
			'search.title' => 'Search',
			'search.hint' => 'Search species, islands, sites...',
			'search.noResults' => 'No results found',
			'search.noResultsSubtitle' => 'Try a different search term',
			'search.speciesSection' => 'Species',
			'search.islandsSection' => 'Islands',
			'search.sitesSection' => 'Visit Sites',
			'leaderboard.title' => 'Leaderboard',
			'leaderboard.rank' => 'Rank',
			'leaderboard.sightings' => 'Sightings',
			'leaderboard.species' => 'Species',
			'leaderboard.photos' => 'Photos',
			'leaderboard.you' => 'You',
			'leaderboard.empty' => 'No sightings recorded yet. Be the first!',
			'leaderboard.topExplorer' => 'Top Explorer',
			'share.species' => 'Share species',
			'share.shareText' => ({required Object name, required Object scientificName}) => 'Check out ${name} (${scientificName}) on Galápagos Wildlife!',
			'share.copiedToClipboard' => 'Copied to clipboard',
			'celebrations.title' => 'Celebrations',
			'celebrations.todayEvent' => ({required Object event}) => 'Today: ${event}',
			'celebrations.birthdayOverlay' => 'It\'s your birthday!',
			'errors.network' => 'No internet connection. Please check your network.',
			'errors.timeout' => 'Request timed out. Please try again.',
			'errors.auth' => 'Authentication error. Please sign in again.',
			'errors.storage' => 'Storage error. Please try again.',
			'errors.validation' => 'Please check your input.',
			'errors.unknown' => 'An unexpected error occurred.',
			'errors.tryAgain' => 'Try Again',
			'fieldEdit.title' => 'Field Edit',
			'fieldEdit.mode' => 'Field Editing Mode',
			'fieldEdit.moveVisitSite' => 'Move Visit Site',
			'fieldEdit.editTrail' => 'Edit Trail',
			'fieldEdit.createNewTrail' => 'Create New Trail',
			'fieldEdit.howToMoveSite' => 'How to Move Site?',
			'fieldEdit.dragOnMap' => 'Drag on Map',
			'fieldEdit.dragOnMapDesc' => 'All markers become draggable — drag any to its correct position',
			'fieldEdit.useCurrentGps' => 'Use Current GPS Location',
			'fieldEdit.useCurrentGpsDesc' => 'Tap a site marker to move it to your current position',
			'fieldEdit.howToEditTrail' => 'How to Edit Trail?',
			'fieldEdit.editOnMap' => 'Edit on Map',
			'fieldEdit.editOnMapDesc' => 'Tap a trail, then add/remove points',
			'fieldEdit.walkRecordGps' => 'Walk & Record GPS',
			'fieldEdit.walkRecordGpsDesc' => 'Re-record trail by walking the route',
			'fieldEdit.howToCreateTrail' => 'How to Create Trail?',
			'fieldEdit.drawOnMap' => 'Draw on Map',
			'fieldEdit.drawOnMapDesc' => 'Tap map to add points, drag to adjust',
			'fieldEdit.walkRecordGpsNewDesc' => 'GPS tracking while walking the route',
			'fieldEdit.correctSiteLocation' => 'Correct site location',
			'fieldEdit.correctTrailPath' => 'Correct trail path',
			'fieldEdit.drawOnMapOrGps' => 'Draw on map or GPS tracking',
			'fieldEdit.dragAnySiteToMove' => 'Drag any site marker to move it',
			'fieldEdit.tapSiteToMoveToCurrentLocation' => 'Tap a site marker to move it to your current location',
			'fieldEdit.tapTrailToStartEditing' => 'Tap a trail to start editing',
			'fieldEdit.tapTrailThenWalk' => 'Tap a trail, then start walking to re-record',
			'fieldEdit.tapMapToAddPoints' => 'Tap on map to add trail points',
			'fieldEdit.discardChanges' => 'Discard Changes?',
			'fieldEdit.discardChangesMessage' => 'You have unsaved changes. Discard them?',
			'fieldEdit.keepEditing' => 'Keep Editing',
			'fieldEdit.discard' => 'Discard',
			'fieldEdit.doneEditing' => 'Done Editing?',
			'fieldEdit.sitesSaved' => 'Site positions have been saved to the server.',
			'fieldEdit.saveNewTrail' => 'Save New Trail',
			'fieldEdit.trailNameEn' => 'Trail Name (English)',
			'fieldEdit.trailNameEnHint' => 'e.g., Tortuga Bay Trail',
			'fieldEdit.trailNameEs' => 'Trail Name (Spanish)',
			'fieldEdit.trailNameEsHint' => 'e.g., Sendero Bahía Tortuga',
			'fieldEdit.continueRecording' => 'Continue Recording',
			'fieldEdit.saveTrail' => 'Save',
			'fieldEdit.needTwoPoints' => 'Need at least 2 points to save trail',
			'fieldEdit.enterBothTrailNames' => 'Please enter trail names in both languages',
			'fieldEdit.saveTrailChanges' => 'Save Trail Changes',
			'fieldEdit.saveTrailChangesDesc' => 'This will replace the existing trail path with the edited coordinates.',
			'fieldEdit.continueEditing' => 'Continue Editing',
			'fieldEdit.saveChanges' => 'Save Changes',
			'fieldEdit.movingSitesDrag' => 'Moving Sites — drag any marker',
			'fieldEdit.movingSiteManual' => 'Moving Site (Drag)',
			'fieldEdit.movingSiteGps' => 'Moving Site (GPS)',
			'fieldEdit.tapTrailToEdit' => 'Tap a trail to edit',
			'fieldEdit.editingTrail' => 'Editing Trail',
			'fieldEdit.recordingTrailGps' => 'Recording Trail (GPS)',
			'fieldEdit.creatingTrail' => 'Creating Trail',
			'fieldEdit.recordingNewTrailGps' => 'Recording New Trail (GPS)',
			'fieldEdit.pauseRecording' => 'Pause',
			'fieldEdit.resumeRecording' => 'Resume',
			'fieldEdit.stopAndSave' => 'Stop & Save',
			'fieldEdit.editTrailInfo' => 'Edit info',
			'fieldEdit.undo' => 'Undo',
			'fieldEdit.cancel' => 'Cancel',
			'fieldEdit.save' => 'Save',
			'fieldEdit.deletePoint' => ({required Object number}) => 'Delete point ${number}',
			'fieldEdit.deletePoints' => ({required Object count}) => 'Delete ${count} points',
			'fieldEdit.tapPointsDragToMove' => 'Tap point(s) • drag moves selection',
			'fieldEdit.subModePoints' => 'Points',
			'fieldEdit.subModeMove' => 'Move',
			'fieldEdit.subModeRotate' => 'Rotate',
			_ => null,
		};
	}
}
