import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityService
    @State private var selection: Tab = .logger

    enum Tab {
        case logger, trail, species
    }

    var body: some View {
        TabView(selection: $selection) {
            SightingLoggerView()
                .tag(Tab.logger)

            TrailRecordingView()
                .tag(Tab.trail)

            SpeciesListView()
                .tag(Tab.species)
        }
        .tabViewStyle(.page)
    }
}
