import Foundation
import WatchConnectivity

/// Maneja la comunicación WCSession entre el Watch y el iPhone.
final class WatchConnectivityService: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityService()

    @Published var isReachable = false
    @Published var iPhoneConnected = false

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Enviar avistamiento al iPhone

    /// Envía un avistamiento al iPhone. Si no hay conexión, lo encola (transferUserInfo).
    func sendSighting(_ sighting: WatchSighting) {
        let dict = sighting.toDict()

        if WCSession.default.isReachable {
            // En tiempo real (iPhone desbloqueado y app abierta)
            WCSession.default.sendMessage(
                ["action": "new_sighting", "data": dict],
                replyHandler: { _ in
                    LocalStorageService.shared.markSynced(id: sighting.id)
                },
                errorHandler: { [weak self] _ in
                    // Falla en tiempo real → encola en background
                    self?.enqueueSighting(dict)
                }
            )
        } else {
            // iPhone no disponible → encola para sync posterior
            enqueueSighting(dict)
        }
    }

    private func enqueueSighting(_ dict: [String: Any]) {
        WCSession.default.transferUserInfo(["action": "new_sighting", "data": dict])
    }

    // MARK: - Enviar trail al iPhone

    /// Envía un trail grabado (array de [lat, lng]) al iPhone.
    func sendTrail(coordinates: [[Double]], name: String) {
        let payload: [String: Any] = [
            "action": "new_trail",
            "name": name,
            "coordinates": coordinates,
            "recorded_at": ISO8601DateFormatter().string(from: Date()),
        ]
        WCSession.default.transferUserInfo(payload)
    }

    // MARK: - Recibir datos del iPhone

    /// El iPhone envía la lista de especies para la zona actual.
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            if let speciesJson = applicationContext["species"] as? String,
               let speciesData = speciesJson.data(using: .utf8),
               let species = try? JSONDecoder().decode([WatchSpecies].self, from: speciesData) {
                LocalStorageService.shared.cacheSpecies(species)
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let action = message["action"] as? String, action == "update_species",
               let speciesJson = message["data"] as? String,
               let speciesData = speciesJson.data(using: .utf8),
               let species = try? JSONDecoder().decode([WatchSpecies].self, from: speciesData) {
                LocalStorageService.shared.cacheSpecies(species)
            }
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.iPhoneConnected = activationState == .activated
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
}
