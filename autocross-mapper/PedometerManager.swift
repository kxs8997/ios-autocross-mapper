import CoreMotion
import SwiftUI

class PedometerManager: ObservableObject {
    private let pedometer = CMPedometer()
    
    @Published var stepCount: Int = 0
    @Published var distance: Double = 0.0
    @Published var isPedometerAvailable: Bool = false
    
    func startPedometerUpdates() {
        if CMPedometer.isStepCountingAvailable() && CMPedometer.isDistanceAvailable() {
            isPedometerAvailable = true
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let data = data, error == nil else {
                    print("Pedometer Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                // Make sure updates are published on the main thread
                DispatchQueue.main.async {
                    // Update step count and distance
                    self?.stepCount = data.numberOfSteps.intValue
                    if let distance = data.distance {
                        self?.distance = distance.doubleValue
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isPedometerAvailable = false
            }
            print("Pedometer not available on this device.")
        }
    }

    func stopPedometerUpdates() {
        pedometer.stopUpdates()
    }
}

