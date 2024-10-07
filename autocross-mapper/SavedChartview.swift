import SwiftUI
import CoreLocation
struct SavedChartView: View {
    let chart: SavedChart
    @State var rotationAngle: Double
    @State private var zoomScale: CGFloat = 1.0 // Add zoom scale state

    init(chart: SavedChart) {
        self.chart = chart
        self._rotationAngle = State(initialValue: chart.rotationAngle)
    }

    var body: some View {
        VStack {
            Text(chart.name)
                .font(.headline)
                .padding()

            let firstConeLocation = CLLocationCoordinate2D(
                latitude: chart.coneData.first?.location.latitude ?? 0.0,
                longitude: chart.coneData.first?.location.longitude ?? 0.0
            )

            ScrollView([.horizontal, .vertical]) {
                ScatterPlotView(
                    coneLocations: chart.coneData,
                    referenceLocation: firstConeLocation,
                    rotationAngle: rotationAngle,
                    zoomScale: zoomScale // Pass zoom scale to ScatterPlotView
                )
                .frame(width: 1000, height: 1000) // Adjust the size based on your needs
                .padding()
            }

            // Zoom slider and rotation slider
            VStack(spacing: 10) {
                let zoomLevelText = String(format: "%.1f", zoomScale)
                Text("Zoom Level: \(zoomLevelText)x")
                    .font(.subheadline)

                Slider(value: $zoomScale, in: 0.05...3.0, step: 0.1) // Zoom slider
                    .padding(.horizontal)

                Text("Rotation Angle: \(Int(rotationAngle))°")
                    .font(.subheadline)

                Slider(value: $rotationAngle, in: -180...180, step: 1) // Rotation slider
                    .padding(.horizontal)
            }
            .padding()
        }
        .padding()
        .background(Color.black)
    }
}

