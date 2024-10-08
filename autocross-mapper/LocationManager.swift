import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocation? // Current location
    @Published var gpsAccuracyMessage: String = "Not Ready"
    @Published var isGPSAccuracyGood: Bool = false
    @Published var gpsAccuracyInMeters: CLLocationAccuracy = 0.0 // New property to track accuracy in meters
    @Published var coneLocations: [Cone] = [] // List of tagged cone locations
    @Published var selectedConeType: ConeType = .single // Default to pointer cone
    @Published var outdoorAccuracyThreshold: CLLocationAccuracy = 15.0 // Default threshold value

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func tagCone(location: CLLocationCoordinate2D, rotation: Double) {
        let newCone = Cone(location: location, type: selectedConeType, rotation: rotation)
        coneLocations.append(newCone)
        print("Cone tagged at: \(location.latitude), \(location.longitude) with rotation: \(rotation)°")
    }

    // Function to delete the last tagged cone
    func deleteLastCone() {
        if !coneLocations.isEmpty {
            coneLocations.removeLast()
            print("Last cone deleted.")
        }
    }

    // Update the rotation of a cone at a specific index
    func updateConeRotation(at index: Int, rotation: Double) {
        guard index >= 0 && index < coneLocations.count else { return }

        // Update the rotation of the selected cone
        var cone = coneLocations[index]
        cone.rotation = rotation
        coneLocations[index] = cone
        print("Cone at index \(index) updated with new rotation: \(rotation)°")
    }

    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let endLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distance = startLocation.distance(from: endLocation)
        return distance
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation

        // Update GPS accuracy in meters
        gpsAccuracyInMeters = newLocation.horizontalAccuracy

        // Check if the accuracy is sufficient for outdoor use based on the adjustable threshold
        if newLocation.horizontalAccuracy <= outdoorAccuracyThreshold {
            gpsAccuracyMessage = "OK"
            isGPSAccuracyGood = true
        } else {
            gpsAccuracyMessage = "Not Ready"
            isGPSAccuracyGood = false
        }

        print("Updated location: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude) | Accuracy: \(newLocation.horizontalAccuracy)m | Threshold: \(outdoorAccuracyThreshold)m")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            print("Location updates authorized.")
        case .denied, .restricted:
            gpsAccuracyMessage = "GPS not authorized"
            isGPSAccuracyGood = false
            print("Location updates denied or restricted.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("Location authorization not determined yet.")
        @unknown default:
            print("Unknown authorization status.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location: \(error.localizedDescription)")
        gpsAccuracyMessage = "Error"
        isGPSAccuracyGood = false
    }
}

