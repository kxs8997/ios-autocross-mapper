import SwiftUI
import CoreLocation

struct ScatterPlotView: View {
    let coneLocations: [Cone]
    let referenceLocation: CLLocationCoordinate2D
    let rotationAngle: Double
    let zoomScale: CGFloat // Pass zoomScale into ScatterPlotView

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

                    // Directly apply zoom scaling without normalization
                    let normalizedX = point.x * zoomScale + chartWidth / 2
                    let normalizedY = point.y * zoomScale + chartHeight / 2
                    let coneSize = 5 * zoomScale // Scale cone size with zoom

                    // Print the position for debugging
                    // print("Cone \(index) position: (\(normalizedX), \(normalizedY))")

                    if index < 2 {
                        // First two cones are always starting cones
                        Circle()
                            .fill(Color.green)
                            .frame(width: coneSize, height: coneSize)
                            .position(CGPoint(x: normalizedX, y: normalizedY))
                    } else {
                        // Handle other cone types (pointer cones and single cones)
                        switch cone.type {
                        case .leftPointer:
                            Circle()
                                .fill(Color.orange)
                                .frame(width: coneSize, height: coneSize)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.orange)
                                        .frame(width: 20 * zoomScale, height: 3 * zoomScale)
                                        .offset(x: -15 * zoomScale)
                                )
                                .position(CGPoint(x: normalizedX, y: normalizedY))

                        case .rightPointer:
                            Circle()
                                .fill(Color.orange)
                                .frame(width: coneSize, height: coneSize)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.orange)
                                        .frame(width: 20 * zoomScale, height: 3 * zoomScale)
                                        .offset(x: 15 * zoomScale)
                                )
                                .position(CGPoint(x: normalizedX, y: normalizedY))

                        case .single:
                            Circle()
                                .fill(Color.orange)
                                .frame(width: coneSize, height: coneSize)
                                .position(CGPoint(x: normalizedX, y: normalizedY))

                        default:
                            EmptyView() // Return a valid view even for unexpected cases
                        }
                    }
                }
            }
            .rotationEffect(.degrees(rotationAngle)) // Apply rotation
        }
    }
}

