import SwiftUI

@main
struct GalapagosWatchApp: App {
    @StateObject private var connectivity = WatchConnectivityService.shared
    @StateObject private var locationService = LocationService.shared
    @StateObject private var storage = LocalStorageService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
                .environmentObject(locationService)
                .environmentObject(storage)
        }
    }
}
