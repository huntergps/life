import SwiftUI
import WatchKit

/// Pantalla principal del Watch: lista de especies para registrar avistamiento rápido.
struct SightingLoggerView: View {
    @EnvironmentObject var connectivity: WatchConnectivityService
    @EnvironmentObject var location: LocationService
    @EnvironmentObject var storage: LocalStorageService

    @State private var showConfirmation = false
    @State private var lastLogged: WatchSpecies?
    @State private var isLogging = false

    var body: some View {
        NavigationStack {
            Group {
                if storage.cachedSpecies.isEmpty {
                    emptyState
                } else {
                    speciesList
                }
            }
            .navigationTitle("Avistamiento")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay(alignment: .bottom) {
            if showConfirmation, let species = lastLogged {
                confirmationBanner(species: species)
            }
        }
    }

    // MARK: - Species list

    private var speciesList: some View {
        List(storage.cachedSpecies) { species in
            Button {
                logSighting(species)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(species.displayName)
                            .font(.body)
                            .lineLimit(2)
                        Text(species.scientificName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                    Spacer()
                    conservationDot(species.conservationStatus)
                }
            }
            .listItemTint(.clear)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Abre el app en el iPhone para cargar especies")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Confirmation banner

    private func confirmationBanner(species: WatchSpecies) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(species.displayName)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.bottom, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func conservationDot(_ status: String?) -> some View {
        let color: Color = switch status?.uppercased() {
        case "CR": .red
        case "EN": .orange
        case "VU": .yellow
        case "NT": .blue
        default:   .green
        }
        return Circle()
            .fill(color)
            .frame(width: 8, height: 8)
    }

    // MARK: - Actions

    private func logSighting(_ species: WatchSpecies) {
        guard !isLogging else { return }
        isLogging = true

        let sighting = WatchSighting(
            speciesId: species.id,
            speciesName: species.displayName,
            latitude: location.currentLocation?.coordinate.latitude,
            longitude: location.currentLocation?.coordinate.longitude
        )

        storage.saveSighting(sighting)
        connectivity.sendSighting(sighting)

        // Haptic feedback
        WKInterfaceDevice.current().play(.success)

        withAnimation {
            lastLogged = species
            showConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showConfirmation = false }
            isLogging = false
        }
    }
}
