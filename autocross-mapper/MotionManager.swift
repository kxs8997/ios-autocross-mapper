import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private var pedometerManager = CMPedometer()
    
    @Published var accelerationX: Double = 0.0
    @Published var accelerationY: Double = 0.0
    @Published var accelerationZ: Double = 0.0
    
    @Published var stepCount: Int = 0
    @Published var distance: Double = 0.0
    
    func startUpdates() {
        // Start DeviceMotion updates for real-time movement tracking
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.05  // 20Hz updates
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let motion = motion, error == nil else {
                    print("Device Motion Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                // Update real-time acceleration
                DispatchQueue.main.async {
                    self?.accelerationX = motion.userAcceleration.x
                    self?.accelerationY = motion.userAcceleration.y
                    self?.accelerationZ = motion.userAcceleration.z
                }
            }
        }
        
        // Start Pedometer updates for step count and distance
        if CMPedometer.isStepCountingAvailable() && CMPedometer.isDistanceAvailable() {
            pedometerManager.startUpdates(from: Date()) { [weak self] data, error in
                guard let data = data, error == nil else {
                    print("Pedometer Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                DispatchQueue.main.async {
                    self?.stepCount = data.numberOfSteps.intValue
                    if let distance = data.distance {
                        self?.distance = distance.doubleValue
                    }
                }
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        pedometerManager.stopUpdates()
    }
}

