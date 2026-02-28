import Foundation

/// Versión compacta de especie para el Watch (sin imágenes grandes).
struct WatchSpecies: Codable, Identifiable, Hashable {
    let id: Int
    let commonNameEs: String
    let commonNameEn: String
    let scientificName: String
    let categoryId: Int
    let conservationStatus: String?

    var displayName: String {
        let locale = Locale.current.languageCode ?? "en"
        return locale == "es" ? commonNameEs : commonNameEn
    }

    var conservationColor: String {
        switch conservationStatus?.uppercased() {
        case "CR": return "red"
        case "EN": return "orange"
        case "VU": return "yellow"
        case "NT": return "blue"
        default:   return "green"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case commonNameEs = "common_name_es"
        case commonNameEn = "common_name_en"
        case scientificName = "scientific_name"
        case categoryId = "category_id"
        case conservationStatus = "conservation_status"
    }
}
