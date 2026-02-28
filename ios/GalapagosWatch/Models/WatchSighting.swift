import Foundation

/// Avistamiento registrado en el Watch, pendiente de sync con el iPhone.
struct WatchSighting: Codable, Identifiable {
    let id: UUID
    let speciesId: Int
    let speciesName: String
    let latitude: Double?
    let longitude: Double?
    let observedAt: Date
    let notes: String?
    var synced: Bool

    init(
        speciesId: Int,
        speciesName: String,
        latitude: Double?,
        longitude: Double?,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.speciesId = speciesId
        self.speciesName = speciesName
        self.latitude = latitude
        self.longitude = longitude
        self.observedAt = Date()
        self.notes = notes
        self.synced = false
    }

    /// Convierte a diccionario para enviar por WCSession.transferUserInfo()
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "species_id": speciesId,
            "species_name": speciesName,
            "observed_at": ISO8601DateFormatter().string(from: observedAt),
        ]
        if let lat = latitude  { dict["latitude"]  = lat }
        if let lng = longitude { dict["longitude"] = lng }
        if let n   = notes     { dict["notes"]     = n   }
        return dict
    }
}
