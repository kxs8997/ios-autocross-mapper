import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State private var rotationAngle: Double = 0
    @State private var zoomScale: CGFloat = 1.0
    @State private var firstConeTagged = false // Track if the first cone has been tagged

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(locationManager.gpsAccuracyMessage)
                    .font(.subheadline)
                    .foregroundColor(locationManager.isGPSAccuracyGood ? .green : .red)

                Spacer()

                Button(action: {
                    let chartName = generateChartName()
                    ChartManager.saveChart(name: chartName, coneLocations: locationManager.coneLocations, rotationAngle: rotationAngle)
                }) {
                    Text("Save")
                        .font(.subheadline)
                        .padding(4)
                        .frame(width: 60, height: 25)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            VStack {
                HStack {
                    Button(action: {
                        locationManager.selectedConeType = .leftPointer
                    }) {
                        Text("Left Pointer")
                            .font(.subheadline)
                            .padding(4)
                            .frame(width: 80, height: 25)
                            .background(locationManager.selectedConeType == .leftPointer ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        locationManager.selectedConeType = .rightPointer
                    }) {
                        Text("Right Pointer")
                            .font(.subheadline)
                            .padding(4)
                            .frame(width: 80, height: 25)
                            .background(locationManager.selectedConeType == .rightPointer ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        locationManager.selectedConeType = .single
                    }) {
                        Text("Single")
                            .font(.subheadline)
                            .padding(4)
                            .frame(width: 80, height: 25)
                            .background(locationManager.selectedConeType == .single ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }

            VStack {
                HStack {
                    Button(action: {
                        locationManager.tagCone()
                        // After tagging the first cone, mark it as tagged for auto-scrolling
                        firstConeTagged = true
                    }) {
                        Text("Tag Cone")
                            .font(.subheadline)
                            .padding(4)
                            .frame(width: 80, height: 25)
                            .background(locationManager.isGPSAccuracyGood ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!locationManager.isGPSAccuracyGood)

                    Button(action: {
                        locationManager.deleteLastCone()
                    }) {
                        Text("Delete Last Cone")
                            .font(.subheadline)
                            .padding(4)
                            .frame(width: 100, height: 25)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }

            // Add ScrollViewReader for programmatic scrolling
            if let firstCone = locationManager.coneLocations.first?.location {
                ScrollView([.horizontal, .vertical]) {
                    ScrollViewReader { proxy in
                        ScatterPlotView(
                            coneLocations: locationManager.coneLocations,
                            referenceLocation: firstCone,
                            rotationAngle: rotationAngle,
                            zoomScale: zoomScale
                        )
                        .frame(width: 1000, height: 1000)
                        .padding()
                        .rotationEffect(.degrees(rotationAngle)) // Apply rotation effect to ScatterPlotView
                        .onChange(of: firstConeTagged) { newValue in
                            // Auto-scroll to the first cone after it's tagged by index
                            if newValue {
                                withAnimation {
                                    proxy.scrollTo(0, anchor: .center) // Scroll to the first cone's index
                                }
                            }
                        }
                    }
                }
            } else {
                Text("No cones tagged yet.")
                    .font(.subheadline)
                    .padding()
            }

            // Corrected string interpolation
            VStack(spacing: 10) {
                Text("Zoom Level: \(String(format: "%.1f", zoomScale))x")
                    .font(.subheadline)
                Slider(value: $zoomScale, in: 0.05...3.0, step: 0.1)
                    .padding(.horizontal)

                // Add Rotation Slider
                Text("Rotation Angle: \(Int(rotationAngle))°")
                    .font(.subheadline)
                Slider(value: $rotationAngle, in: -180...180, step: 1) // Rotation slider
                    .padding(.horizontal)
            }
            .padding() // Ensure padding to keep the slider visible
        }
        .padding()
        .background(Color.black)
    }

    func generateChartName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        return "Chart_\(dateFormatter.string(from: Date()))"
    }
}

