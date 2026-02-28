import SwiftUI

/// Guía offline de especies cargadas desde el iPhone.
struct SpeciesListView: View {
    @EnvironmentObject var storage: LocalStorageService
    @State private var searchText = ""

    private var filteredSpecies: [WatchSpecies] {
        if searchText.isEmpty { return storage.cachedSpecies }
        return storage.cachedSpecies.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.scientificName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            if storage.cachedSpecies.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "binoculars")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Sin especies")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Abre el app en el iPhone")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .navigationTitle("Especies")
            } else {
                List(filteredSpecies) { species in
                    NavigationLink {
                        SpeciesDetailView(species: species)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(species.displayName)
                                .font(.body)
                                .lineLimit(1)
                            Text(species.scientificName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .italic()
                                .lineLimit(1)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Buscar")
                .navigationTitle("Especies (\(storage.cachedSpecies.count))")
            }
        }
    }
}

struct SpeciesDetailView: View {
    let species: WatchSpecies

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(species.displayName)
                    .font(.headline)

                Text(species.scientificName)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)

                Divider()

                HStack {
                    Label("Cat. \(species.categoryId)", systemImage: "tag")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if let status = species.conservationStatus {
                    HStack {
                        conservationBadge(status)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func conservationBadge(_ status: String) -> some View {
        let (label, color): (String, Color) = switch status.uppercased() {
        case "CR": ("En Peligro Crítico", .red)
        case "EN": ("En Peligro", .orange)
        case "VU": ("Vulnerable", .yellow)
        case "NT": ("Casi Amenazado", .blue)
        default:   ("Preocupación Menor", .green)
        }
        return Text(label)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
