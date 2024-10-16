import SwiftUI
import CoreLocation

struct ScatterPlotViewSaved: View {
    let coneLocations: [Cone]
    let referenceLocation: CLLocationCoordinate2D
    let rotationAngle: Double // Rotation for the entire world
    let zoomScale: CGFloat

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
                // Iterate over coneLocations using the index
                ForEach(Array(coneLocations.enumerated()), id: \.offset) { index, cone in
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
                            Circle()
                                .fill(Color.orange)
                                .frame(width: coneSize, height: coneSize)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.orange)
                                        .frame(width: 5 * zoomScale, height: 1.5 * zoomScale)
                                        .offset(x: 3 * zoomScale)
                                        .rotationEffect(.degrees(cone.rotation), anchor: .center) // Rotate the dash with the cone's own rotation
                                )
                                .position(CGPoint(x: normalizedX, y: normalizedY))

                        case .single:
                            Circle()
                                .fill(Color.orange)
                                .frame(width: coneSize, height: coneSize)
                                .position(CGPoint(x: normalizedX, y: normalizedY))

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

