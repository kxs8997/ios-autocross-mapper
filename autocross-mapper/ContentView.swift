import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State private var selectedConeIndex: Int? = nil // Index of the selected cone to rotate
    @State private var pointerConeRotation: Double = 0 // Rotation for the selected pointer cone
    @State private var worldRotation: Double = 0 // Rotation for the entire world
    @State private var zoomScale: CGFloat = 1.0
    @State private var firstConeTagged = false // Track if the first cone has been tagged
    @State private var pointerConeSelected = false // Track whether a pointer cone is selected

    var body: some View {
        VStack(spacing: 10) {
            // GPS Accuracy Status Display
            HStack {
                Text("GPS Status: \(locationManager.gpsAccuracyMessage)")
                    .font(.subheadline)
                    .foregroundColor(locationManager.isGPSAccuracyGood ? .green : .red)

                Spacer()

                // Display GPS accuracy in meters
                Text("Accuracy: \(String(format: "%.1f", locationManager.gpsAccuracyInMeters)) meters")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                // Save Button to Save the Chart
                Button(action: {
                    saveChart()
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

            // Outdoor Accuracy Threshold Slider
            VStack {
                Text("Set Outdoor Accuracy Threshold: \(String(format: "%.1f", locationManager.outdoorAccuracyThreshold)) meters")
                    .font(.subheadline)

                Slider(value: $locationManager.outdoorAccuracyThreshold, in: 1...50, step: 1)
                    .padding(.horizontal)
            }

            // Cone Type Selection (Pointer and Single Cones)
            VStack {
                HStack {
                    Button(action: {
                        locationManager.selectedConeType = .pointer
                    }) {
                        Text("Pointer Cone")
                            .font(.subheadline)
                            .padding(4)
                            .frame(width: 100, height: 25)
                            .background(locationManager.selectedConeType == .pointer ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        locationManager.selectedConeType = .single
                        pointerConeSelected = false // Deselect pointer cone when single is selected
                    }) {
                        Text("Single Cone")
                            .font(.subheadline)
                            .padding(4)
                            .frame(width: 100, height: 25)
                            .background(locationManager.selectedConeType == .single ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }

            // Tagging and Deleting Cones
            VStack {
                HStack {
                    // Tag Cone Button
                    Button(action: {
                        tagCone()
                        firstConeTagged = true // Mark the first cone as tagged
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

                    // Delete Last Cone Button
                    Button(action: {
                        locationManager.deleteLastCone()
                        pointerConeSelected = false // Deselect pointer cone when deleted
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

            // ScatterPlotView with auto-scroll for the first tagged cone
            if let firstCone = locationManager.coneLocations.first?.location {
                ScrollView([.horizontal, .vertical]) {
                    ScrollViewReader { proxy in
                        ScatterPlotViewContent(
                            coneLocations: locationManager.coneLocations,
                            referenceLocation: firstCone,
                            rotationAngle: worldRotation, // World rotation
                            zoomScale: zoomScale,
                            currentLocation: locationManager.location?.coordinate, // Pass current location to ScatterPlotView
                            onSelectCone: { index in
                                let cone = locationManager.coneLocations[index]
                                if cone.type == .pointer {
                                    selectedConeIndex = index
                                    pointerConeRotation = cone.rotation
                                    pointerConeSelected = true // Mark pointer cone as selected
                                } else {
                                    pointerConeSelected = false // Deselect pointer cone if a single cone is selected
                                }
                            },
                            onDeselectCone: {
                                pointerConeSelected = false // Deselect cone if tapping outside
                            }
                        )
                        .frame(width: 1000, height: 1000)
                        .padding()
                        .onChange(of: firstConeTagged) { newValue in
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

            // Zoom Controls for the Scatter Plot
            VStack(spacing: 10) {
                Text("Zoom Level: \(String(format: "%.1f", zoomScale))x")
                    .font(.subheadline)
                Slider(value: $zoomScale, in: 0.05...8.0, step: 0.1)
                    .padding(.horizontal)
            }
            .padding()

            // World Rotation Controls
            VStack(spacing: 10) {
                Text("Rotate World: \(Int(worldRotation))°")
                    .font(.subheadline)
                Slider(value: $worldRotation, in: -180...180, step: 1)
                    .padding(.horizontal)
            }

            // Pointer Cone Selected Notification
            if pointerConeSelected {
                Text("Pointer Cone Selected")
                    .font(.headline)
                    .foregroundColor(.orange)
            }

            // Rotation Controls for the Selected Pointer Cone
            if let selectedIndex = selectedConeIndex, pointerConeSelected {
                VStack {
                    Text("Rotate Pointer Cone: \(Int(pointerConeRotation))°")
                        .font(.subheadline)

                    Slider(value: $pointerConeRotation, in: -180...180, step: 1, onEditingChanged: { _ in
                        updatePointerConeRotation(for: selectedIndex)
                    })
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color.black)
    }

    // Function to tag a cone (pointer or single)
    // Function to tag a cone (pointer or single)
    func tagCone() {
        guard let currentLocation = locationManager.location else {
            print("No GPS location available.")
            return
        }

        // Automatically set the first cone as the starting cone if no cone is tagged yet
        if locationManager.coneLocations.isEmpty {
            let startingCone = Cone(location: currentLocation.coordinate, type: .starting)
            locationManager.coneLocations.append(startingCone)
            return
        }

        // Use the blue dot's current location to tag the pointer cone
        if locationManager.selectedConeType == .pointer {
            let newCone = Cone(location: currentLocation.coordinate, type: .pointer, rotation: pointerConeRotation) // Use current location
            locationManager.coneLocations.append(newCone)
        } else {
            let newCone = Cone(location: currentLocation.coordinate, type: .single)
            locationManager.coneLocations.append(newCone)
            pointerConeSelected = false // Deselect pointer cone when a single cone is tagged
        }
    }


    // Function to update rotation for an already tagged pointer cone
    func updatePointerConeRotation(for index: Int) {
        guard index < locationManager.coneLocations.count else { return }

        var cone = locationManager.coneLocations[index]
        cone.rotation = pointerConeRotation
        locationManager.coneLocations[index] = cone
    }

    // Function to calculate new location offset by angle and distance relative to the starting cone
    func offsetLocation(from startLocation: CLLocationCoordinate2D, angle: Double, distance: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6378137.0 // Earth radius in meters

        let deltaLatitude = (distance / earthRadius) * cos(angle * .pi / 180.0)
        let deltaLongitude = (distance / earthRadius) * sin(angle * .pi / 180.0) / cos(startLocation.latitude * .pi / 180.0)

        let newLatitude = startLocation.latitude + deltaLatitude * (180.0 / .pi)
        let newLongitude = startLocation.longitude + deltaLongitude * (180.0 / .pi)

        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }

    // Function to save the current chart
    func saveChart() {
        let chartName = generateChartName()
        ChartManager.saveChart(name: chartName, coneLocations: locationManager.coneLocations, rotationAngle: worldRotation)
        print("Chart \(chartName) saved!")
    }

    // Function to generate a chart name based on the current date and time
    func generateChartName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        return "Chart_\(dateFormatter.string(from: Date()))"
    }
}

