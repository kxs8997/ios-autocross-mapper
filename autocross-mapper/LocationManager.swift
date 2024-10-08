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
    @Published var selectedConeType: ConeType = .single // Default to single cone

    private let outdoorAccuracyThreshold: CLLocationAccuracy = 15.0

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func tagCone() {
        guard let currentLocation = location else {
            print("Location not available.")
            return
        }

        if isGPSAccuracyGood {
            let newCone = Cone(location: currentLocation.coordinate, type: selectedConeType)
            coneLocations.append(newCone)
            print("Cone tagged at: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        } else {
            print("GPS accuracy not sufficient to tag a cone.")
        }
    }

    func deleteLastCone() {
        if !coneLocations.isEmpty {
            coneLocations.removeLast()
            print("Last cone deleted.")
        }
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

        // Check if the accuracy is sufficient for outdoor use
        if newLocation.horizontalAccuracy <= outdoorAccuracyThreshold {
            gpsAccuracyMessage = "OK"
            isGPSAccuracyGood = true
        } else {
            gpsAccuracyMessage = "Not Ready"
            isGPSAccuracyGood = false
        }

        print("Updated location: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude) | Accuracy: \(newLocation.horizontalAccuracy)m")
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

