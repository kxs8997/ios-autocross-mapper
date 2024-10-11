import SwiftUI
import CoreLocation

struct ScatterPlotViewContent: View {
    let coneLocations: [Cone]
    let referenceLocation: CLLocationCoordinate2D
    let rotationAngle: Double
    let zoomScale: CGFloat
    let currentLocation: CLLocationCoordinate2D? // New: Current location to be shown as a blue dot
    let onSelectCone: (Int) -> Void
    let onDeselectCone: () -> Void

    // Convert lat/lon differences to meters using a reference location
    func convertToMeters(location: CLLocationCoordinate2D, reference: CLLocationCoordinate2D) -> CGPoint {
        let latitudeDifference = location.latitude - reference.latitude
        let longitudeDifference = location.longitude - reference.longitude

        let deltaY = latitudeDifference * 111_000 // Convert latitude to meters
        let deltaX = longitudeDifference * 111_000 * cos(reference.latitude * .pi / 180) // Convert longitude to meters

        return CGPoint(x: CGFloat(deltaX), y: CGFloat(deltaY))
    }

    var body: some View {
        GeometryReader { geometry in
            let chartWidth = geometry.size.width
            let chartHeight = geometry.size.height

            ZStack {
                // Background area to capture taps outside cones
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle()) // Make the entire area tappable
                    .onTapGesture {
                        onDeselectCone() // Call the deselect closure if tapped outside
                    }

                // Iterate over coneLocations using .enumerated()
                ForEach(Array(coneLocations.enumerated()), id: \.0) { (index, cone) in
                    let point = convertToMeters(location: cone.location, reference: referenceLocation)

                    // Apply zoom scaling
                    let normalizedX = point.x * zoomScale + chartWidth / 2
                    let normalizedY = point.y * zoomScale + chartHeight / 2
                    let coneSize = 2.5 * zoomScale // Scale cone size with zoom

                    if index < 2 {
                        // First two cones are always starting cones
                        Circle()
                            .fill(Color.green)
                            .frame(width: coneSize, height: coneSize)
                            .position(CGPoint(x: normalizedX, y: normalizedY))
                    } else {
                        // Handle pointer and single cones
                        switch cone.type {
                        case .pointer:
                            ZStack {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: coneSize, height: coneSize)

                                Rectangle()
                                    .fill(Color.orange)
                                    .frame(width: 5 * zoomScale, height: 1.5 * zoomScale)
                                    .offset(x: 3 * zoomScale)
                                    .rotationEffect(.degrees(cone.rotation), anchor: .center)
                            }
                            .position(CGPoint(x: normalizedX, y: normalizedY))
                            .onTapGesture {
                                onSelectCone(index)
                            }

                        case .single:
                            Circle()
                                .fill(Color.orange)
                                .frame(width: coneSize, height: coneSize)
                                .position(CGPoint(x: normalizedX, y: normalizedY))
                                .onTapGesture {
                                    onSelectCone(index)
                                }

                        default:
                            EmptyView()
                        }
                    }
                }

                // Add the blue dot for the current location
                if let currentLocation = currentLocation {
                    let currentPoint = convertToMeters(location: currentLocation, reference: referenceLocation)
                    let normalizedX = currentPoint.x * zoomScale + chartWidth / 2
                    let normalizedY = currentPoint.y * zoomScale + chartHeight / 2

                    Circle()
                        .fill(Color.blue) // Blue dot for current location
                        .frame(width: 2 * zoomScale, height: 2 * zoomScale)
                        .position(CGPoint(x: normalizedX, y: normalizedY))
                }
            }
            .rotationEffect(.degrees(rotationAngle))
        }
    }
}

