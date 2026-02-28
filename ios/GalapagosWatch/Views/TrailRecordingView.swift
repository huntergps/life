import SwiftUI
import CoreLocation

/// Grabación de trail GPS sin necesitar el iPhone.
/// Usa HKWorkoutSession para mantener GPS activo en background.
struct TrailRecordingView: View {
    @EnvironmentObject var location: LocationService
    @EnvironmentObject var connectivity: WatchConnectivityService

    @State private var isRecording = false
    @State private var recordedPoints: [CLLocationCoordinate2D] = []
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?
    @State private var showSendConfirmation = false
    @State private var trailName = ""
    @State private var showNameAlert = false

    private var formattedTime: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }

    private var distanceMeters: Double {
        guard recordedPoints.count > 1 else { return 0 }
        var total = 0.0
        for i in 1..<recordedPoints.count {
            let a = CLLocation(latitude: recordedPoints[i-1].latitude, longitude: recordedPoints[i-1].longitude)
            let b = CLLocation(latitude: recordedPoints[i].latitude,   longitude: recordedPoints[i].longitude)
            total += a.distance(from: b)
        }
        return total
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Estado GPS
                statusRow

                // Tiempo
                Text(formattedTime)
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .monospacedDigit()

                // Distancia
                Text(distanceMeters >= 1000
                     ? String(format: "%.2f km", distanceMeters / 1000)
                     : String(format: "%.0f m", distanceMeters))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Puntos grabados
                Text("\(recordedPoints.count) puntos")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Spacer()

                // Botones
                if isRecording {
                    Button(role: .destructive) {
                        stopRecording()
                    } label: {
                        Label("Detener", systemImage: "stop.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                } else {
                    Button {
                        startRecording()
                    } label: {
                        Label("Grabar trail", systemImage: "record.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(location.currentLocation == nil)

                    if !recordedPoints.isEmpty {
                        Button {
                            showNameAlert = true
                        } label: {
                            Label("Enviar al iPhone", systemImage: "iphone.and.arrow.forward")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
            .navigationTitle("Trail")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showNameAlert) {
            trailNameSheet
        }
        .overlay {
            if showSendConfirmation {
                sentConfirmation
            }
        }
    }

    private var statusRow: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(location.currentLocation != nil ? .green : .orange)
                .frame(width: 8, height: 8)
            Text(location.currentLocation != nil ? "GPS listo" : "Esperando GPS")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var trailNameSheet: some View {
        VStack(spacing: 12) {
            Text("Nombre del trail")
                .font(.headline)
            TextField("Trail Isabela...", text: $trailName)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
            Button("Enviar") {
                sendTrail()
                showNameAlert = false
            }
            .buttonStyle(.borderedProminent)
            .disabled(trailName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }

    private var sentConfirmation: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(.green)
            Text("Trail enviado al iPhone")
                .font(.caption)
        }
        .padding()
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    private func startRecording() {
        recordedPoints = []
        elapsedSeconds = 0
        isRecording = true
        location.startUpdating()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
            if let loc = location.currentLocation {
                let last = recordedPoints.last
                let current = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                // Solo graba si se movió más de 5 metros
                if let prev = last {
                    let prevLoc = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
                    if current.distance(from: prevLoc) >= 5 {
                        recordedPoints.append(loc.coordinate)
                    }
                } else {
                    recordedPoints.append(loc.coordinate)
                }
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        location.stopUpdating()
    }

    private func sendTrail() {
        let coords = recordedPoints.map { [$0.latitude, $0.longitude] }
        connectivity.sendTrail(coordinates: coords, name: trailName)
        recordedPoints = []
        trailName = ""
        withAnimation { showSendConfirmation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showSendConfirmation = false }
        }
    }
}
