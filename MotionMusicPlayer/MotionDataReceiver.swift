//
//  MotionDataReceiver.swift
//  MotionMusicPlayer
//
//  Created by Alina Chen on 5/14/25.
//

import Foundation
import WatchConnectivity

class MotionReceiver: NSObject, ObservableObject, WCSessionDelegate {
    private var session: WCSession?
    @Published var latestAccel: [String: Double] = [:]
    @Published var latestGyro: [String: Double] = [:]
    @Published var latestAttitude: [String: Double] = [:]
    @Published var latestTimestamp: Double = 0.0

    override init() {
        super.init()

        if WCSession.isSupported() {
            print("✅ WCSession is supported")
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            
            // Initialize socket connection
            print("Initializing socket connection...")
            _ = SocketClient.shared  // This will trigger the connection
        } else {
            print("❌ WCSession not supported")
        }
    }

    // Required for activation
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("🟢 iPhone WCSession activated. State: \(activationState.rawValue)")
        if let error = error {
           print("❌ Activation error: \(error.localizedDescription)")
        }
    }
    
    func sendToPython(json: [String: Any]) {
        // Assuming you have a global SocketClient instance
        SocketClient.shared.send(json: json)
    }

    // Here's where we receive motion data
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("📡 Received motion data:")
            print(message) // Log all keys

            // Format for your socket as JSON
            let motionPayload: [String: Any] = [
                "timestamp": message["timestamp"] ?? 0,
                "accel": [
                    "x": message["accelX"] ?? 0,
                    "y": message["accelY"] ?? 0,
                    "z": message["accelZ"] ?? 0
                ],
                "gyro": [
                    "x": message["gyroX"] ?? 0,
                    "y": message["gyroY"] ?? 0,
                    "z": message["gyroZ"] ?? 0
                ],
                "attitude": [
                    "pitch": message["pitch"] ?? 0,
                    "roll": message["roll"] ?? 0,
                    "yaw": message["yaw"] ?? 0
                ]
            ]
            
            DispatchQueue.main.async {
                self.latestTimestamp = message["timestamp"] as? Double ?? 0.0

                self.latestAccel = [
                    "x": message["accelX"] as? Double ?? 0.0,
                    "y": message["accelY"] as? Double ?? 0.0,
                    "z": message["accelZ"] as? Double ?? 0.0
                ]

                self.latestGyro = [
                    "x": message["gyroX"] as? Double ?? 0.0,
                    "y": message["gyroY"] as? Double ?? 0.0,
                    "z": message["gyroZ"] as? Double ?? 0.0
                ]

                self.latestAttitude = [
                    "pitch": message["pitch"] as? Double ?? 0.0,
                    "roll": message["roll"] as? Double ?? 0.0,
                    "yaw": message["yaw"] as? Double ?? 0.0
                ]
            }


            // Send to your Python server via TCP socket
            SocketClient.shared.send(json: motionPayload)
        }
//        DispatchQueue.main.async {
//            print("📡 Received motion data:")
//            print("x: \(message["x"] ?? "nil")")
//            print("y: \(message["y"] ?? "nil")")
//            print("z: \(message["z"] ?? "nil")")
//        }
    }

    // Also required on iOS 14+
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
