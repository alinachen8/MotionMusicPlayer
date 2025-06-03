//
//  MotionDataManager.swift
//  WatchMotionData Watch App
//
//  Created by Alina Chen on 5/14/25.
//
//

import Foundation
import CoreMotion
import WatchConnectivity

enum MovementType {
    case moveUp
    case shaking
    case none
}

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let session = WCSession.default
    

    @Published var x: Double = 0.0
    @Published var y: Double = 0.0
    @Published var z: Double = 0.0

    @Published var gyroX: Double = 0.0
    @Published var gyroY: Double = 0.0
    @Published var gyroZ: Double = 0.0

    func startStreaming() {
        // Accelerometer
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                guard let data = data else { return }

                DispatchQueue.main.async {
                    self.x = data.acceleration.x
                    self.y = data.acceleration.y
                    self.z = data.acceleration.z

                    let message = [
                        "x": self.x,
                        "y": self.y,
                        "z": self.z
                    ]
                    if self.session.isReachable {
                        self.session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                            print("Error sending accelerometer data: \(error.localizedDescription)")
                        })
                    }
                }
            }
        } else {
            print("Accelerometer not available")
        }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.2
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let self = self, let motion = motion else { return }

                self.processDeviceMotion(motion, type: .moveUp) // You can change to .shaking
            }
        } else {
            print("Device motion not available")
        }


//        // Gyroscope
//        if motionManager.isGyroAvailable {
//            motionManager.gyroUpdateInterval = 0.2
//            motionManager.startGyroUpdates(to: .main) { data, error in
//                guard let data = data else { return }
//
//                DispatchQueue.main.async {
//                    self.gyroX = data.rotationRate.x
//                    self.gyroY = data.rotationRate.y
//                    self.gyroZ = data.rotationRate.z
//
//                    let gyroMessage = [
//                        "gyroX": self.gyroX,
//                        "gyroY": self.gyroY,
//                        "gyroZ": self.gyroZ
//                    ]
//                    if self.session.isReachable {
//                        self.session.sendMessage(gyroMessage, replyHandler: nil, errorHandler: { error in
//                            print("Error sending gyroscope data: \(error.localizedDescription)")
//                        })
//                    }
//                }
//            }
//        } else {
//            print("Gyroscope not available")
//        }
    }


    func stopStreaming() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    
    private func processDeviceMotion(_ motion: CMDeviceMotion, type: MovementType) {
        let accel = motion.userAcceleration
        let attitude = motion.attitude
        let rotationRate = motion.rotationRate
        

        // First: check for shaking (priority)
        let rx = abs(rotationRate.x)
        let ry = abs(rotationRate.y)
        let rz = abs(rotationRate.z)
        let magnitude = sqrt(rx * rx + ry * ry + rz * rz)

        if magnitude > 5 {
            print("🤚 Wrist shaking detected! Magnitude: \(magnitude)")
//            return   Exit early so moveUp doesn't also trigger
        }

        // Then: check for upward motion only if no shaking
        if accel.z > 0.8 {
            print("⬆️ Arm moving upward detected (z: \(accel.z))")
        }
    }

    func testGyroscopeAvailability() {
        print("Gyroscope available? \(motionManager.isGyroAvailable)")

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.2
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                if let motion = motion {
                    let r = motion.rotationRate
                    print("rotationRate = x:\(r.x), y:\(r.y), z:\(r.z)")
                }
            }
        } else {
            print("❌ DeviceMotion not available")
        }
    }
    
}
