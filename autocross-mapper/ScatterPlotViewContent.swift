import SwiftUI
import CoreLocation

struct ScatterPlotViewContent: View {
    let coneLocations: [Cone]
    let referenceLocation: CLLocationCoordinate2D
    let rotationAngle: Double
    let zoomScale: CGFloat
    let onSelectCone: (Int) -> Void
    let onDeselectCone: () -> Void

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
                                // Circle representing the pointer cone
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: coneSize, height: coneSize)

                                // The dash (rectangle) inside the pointer cone
                                Rectangle()
                                    .fill(Color.orange)
                                    .frame(width: 10 * zoomScale, height: 1.5 * zoomScale) // Smaller rectangle size
                                    .offset(x: 5 * zoomScale) // Adjust offset to fit inside the circle
                                    .rotationEffect(.degrees(cone.rotation), anchor: .center) // Rotate the dash
                            }
                            .position(CGPoint(x: normalizedX, y: normalizedY)) // Position the entire pointer cone
                            .onTapGesture {
                                onSelectCone(index) // Call the select closure
                            }

                        case .single:
                            Circle()
                                .fill(Color.orange)
                                .frame(width: coneSize, height: coneSize)
                                .position(CGPoint(x: normalizedX, y: normalizedY))
                                .onTapGesture {
                                    onSelectCone(index) // Call the select closure
                                }

                        default:
                            EmptyView()
                        }
                    }
                }
            }
            .rotationEffect(.degrees(rotationAngle)) // Apply world rotation to the entire plot
        }
    }
}

