import Foundation
import WatchConnectivity
import Flutter

/// Maneja la comunicación WCSession en el lado del iPhone.
/// Recibe avistamientos y trails del Watch y los reenvía a Flutter via Method Channel.
@objc class WatchConnectivityHandler: NSObject, WCSessionDelegate {

    private let channel: FlutterMethodChannel

    @objc init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Enviar especies al Watch (llamado desde Flutter)

    @objc func sendSpeciesToWatch(_ speciesJson: String) {
        guard WCSession.default.activationState == .activated,
              let data = speciesJson.data(using: .utf8)
        else { return }

        do {
            try WCSession.default.updateApplicationContext(["species": data])
        } catch {
            // Si falla applicationContext, usa sendMessage si Watch está disponible
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(
                    ["action": "update_species", "data": data],
                    replyHandler: nil
                )
            }
        }
    }

    // MARK: - Recibir datos del Watch (avistamientos en tiempo real)

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleIncoming(message)
    }

    // MARK: - Recibir datos del Watch (cola offline)

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handleIncoming(userInfo)
    }

    private func handleIncoming(_ dict: [String: Any]) {
        guard let action = dict["action"] as? String else { return }

        DispatchQueue.main.async {
            switch action {
            case "new_sighting":
                if let data = dict["data"] as? [String: Any] {
                    self.channel.invokeMethod("watchSightingReceived", arguments: data)
                }
            case "new_trail":
                self.channel.invokeMethod("watchTrailReceived", arguments: dict)
            default:
                break
            }
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
