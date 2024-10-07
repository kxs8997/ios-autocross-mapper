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

    // Find the maximum distance between cones for normalization
    func calculateMaxDistance(cones: [Cone], reference: CLLocationCoordinate2D) -> CGFloat {
        var maxDistance: CGFloat = 0
        for cone in cones {
            let point = convertToMeters(location: cone.location, reference: reference)
            let distance = sqrt(point.x * point.x + point.y * point.y)
            maxDistance = max(maxDistance, distance)
        }
        return maxDistance
    }

    var body: some View {
        GeometryReader { geometry in
            let chartWidth = geometry.size.width
            let chartHeight = geometry.size.height

            let maxDistance = calculateMaxDistance(cones: coneLocations, reference: referenceLocation)

            ZStack {
                ForEach(0..<coneLocations.count, id: \.self) { index in
                    let cone = coneLocations[index]
                    let point = convertToMeters(location: cone.location, reference: referenceLocation)

                    // Normalize the positions based on the maximum distance and then apply zoom
                    let normalizedX = (point.x / maxDistance) * (chartWidth / 2) * zoomScale + chartWidth / 2
                    let normalizedY = (point.y / maxDistance) * (chartHeight / 2) * zoomScale + chartHeight / 2
                    let coneSize = 10 * zoomScale // Scale cone size with zoom

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
                        
                        // Handle all other cases with a default
                        default:
                            Circle()
                                .fill(Color.gray)
                                .frame(width: coneSize, height: coneSize)
                                .position(CGPoint(x: normalizedX, y: normalizedY))
                        }
                    }
                }
            }
            .rotationEffect(.degrees(rotationAngle)) // Apply rotation
        }
    }
}

