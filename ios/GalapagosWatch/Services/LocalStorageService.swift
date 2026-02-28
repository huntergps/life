import Foundation

/// Persistencia local en el Watch usando UserDefaults.
/// Guarda avistamientos pendientes de sincronizar y la lista de especies.
final class LocalStorageService: ObservableObject {
    static let shared = LocalStorageService()

    private let defaults = UserDefaults.standard
    private let sightingsKey = "pending_sightings"
    private let speciesKey   = "cached_species"

    @Published var pendingSightings: [WatchSighting] = []
    @Published var cachedSpecies: [WatchSpecies] = []

    private init() {
        loadSightings()
        loadSpecies()
    }

    // MARK: - Sightings

    func saveSighting(_ sighting: WatchSighting) {
        pendingSightings.append(sighting)
        persist()
    }

    func markSynced(id: UUID) {
        pendingSightings.removeAll { $0.id == id }
        persist()
    }

    func markAllSynced() {
        pendingSightings.removeAll()
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(pendingSightings) {
            defaults.set(data, forKey: sightingsKey)
        }
    }

    private func loadSightings() {
        guard let data = defaults.data(forKey: sightingsKey),
              let list = try? JSONDecoder().decode([WatchSighting].self, from: data)
        else { return }
        pendingSightings = list
    }

    // MARK: - Species

    func cacheSpecies(_ species: [WatchSpecies]) {
        cachedSpecies = species
        if let data = try? JSONEncoder().encode(species) {
            defaults.set(data, forKey: speciesKey)
        }
    }

    private func loadSpecies() {
        guard let data = defaults.data(forKey: speciesKey),
              let list = try? JSONDecoder().decode([WatchSpecies].self, from: data)
        else { return }
        cachedSpecies = list
    }
}
