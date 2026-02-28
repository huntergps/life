import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct SightingEntry: TimelineEntry {
    let date: Date
    let sightingCount: Int
    let lastSpeciesName: String?
}

// MARK: - Provider

struct SightingComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> SightingEntry {
        SightingEntry(date: Date(), sightingCount: 0, lastSpeciesName: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SightingEntry) -> Void) {
        let count = UserDefaults.standard.integer(forKey: "today_sighting_count")
        let last  = UserDefaults.standard.string(forKey: "last_species_name")
        completion(SightingEntry(date: Date(), sightingCount: count, lastSpeciesName: last))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SightingEntry>) -> Void) {
        let count = UserDefaults.standard.integer(forKey: "today_sighting_count")
        let last  = UserDefaults.standard.string(forKey: "last_species_name")
        let entry = SightingEntry(date: Date(), sightingCount: count, lastSpeciesName: last)
        // Actualiza cada 15 minutos
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Complication Views

struct SightingCircularView: View {
    let entry: SightingEntry
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "binoculars.fill")
                .font(.caption2)
            Text("\(entry.sightingCount)")
                .font(.title3)
                .fontWeight(.bold)
                .minimumScaleFactor(0.5)
        }
    }
}

struct SightingRectangularView: View {
    let entry: SightingEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "binoculars.fill")
                    .font(.caption2)
                Text("\(entry.sightingCount) hoy")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            if let name = entry.lastSpeciesName {
                Text(name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text("Sin avistamientos")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Widget

@main
struct GalapagosComplication: Widget {
    let kind = "GalapagosComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SightingComplicationProvider()) { entry in
            ZStack {
                AccessoryWidgetBackground()
                SightingCircularView(entry: entry)
            }
        }
        .configurationDisplayName("Galápagos Wildlife")
        .description("Avistamientos del día")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
        ])
    }
}
