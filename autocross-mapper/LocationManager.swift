import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocation? // Current location
    @Published var gpsAccuracyMessage: String = "Not Ready"
    @Published var isGPSAccuracyGood: Bool = false
    @Published var coneLocations: [Cone] = [] // List of tagged cone locations
    @Published var selectedConeType: ConeType = .single // Default to single cone

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Function to tag a new cone
    func tagCone() {
        guard let currentLocation = location else { return }
        
        // Ensure GPS accuracy is good before tagging
        if isGPSAccuracyGood {
            let newCone = Cone(location: currentLocation.coordinate, type: selectedConeType)
            coneLocations.append(newCone)
            print("Cone tagged at: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        } else {
            print("GPS accuracy not sufficient to tag a cone.")
        }
    }

    // Function to delete the last tagged cone
    func deleteLastCone() {
        if !coneLocations.isEmpty {
            coneLocations.removeLast()
            print("Last cone deleted.")
        }
    }

    // Calculate distance between two coordinates
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let endLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distance = startLocation.distance(from: endLocation)
        return distance // Distance in meters
    }
}

extension LocationManager: CLLocationManagerDelegate {
    // Update current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation

        // Check GPS accuracy
        if newLocation.horizontalAccuracy <= 5 {
            gpsAccuracyMessage = "OK"
            isGPSAccuracyGood = true
        } else {
            gpsAccuracyMessage = "Not Ready"
            isGPSAccuracyGood = false
        }
    }

    // Handle authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            gpsAccuracyMessage = "GPS not authorized"
            isGPSAccuracyGood = false
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    // Handle location manager errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location: \(error.localizedDescription)")
        gpsAccuracyMessage = "Error"
        isGPSAccuracyGood = false
    }
}

