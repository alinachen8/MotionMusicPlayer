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
    
    private var startTime: TimeInterval? // Store the start time

    @Published var accelX: Double = 0.0
    @Published var accelY: Double = 0.0
    @Published var accelZ: Double = 0.0

    @Published var gyroX: Double = 0.0
    @Published var gyroY: Double = 0.0
    @Published var gyroZ: Double = 0.0

    func startStreaming() {
        self.startTime = Date().timeIntervalSince1970 // Set start time when streaming starts
        deleteAllCSVFiles() // Delete all CSV files at the start of each run
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let self = self, let motion = motion else { return }

                self.processDeviceMotion(motion, type: .moveUp) // You can change to .shaking
            }
        } else {
            print("Device motion not available")
        }
    }


    func stopStreaming() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func processDeviceMotion(_ motion: CMDeviceMotion, type: MovementType) {
        let accel = motion.userAcceleration
        let attitude = motion.attitude
        let rotationRate = motion.rotationRate
        
        // more of my own changes
        let ax = accel.x
        let ay = accel.y
        let az = accel.z
        
        print("Acceleration")
        print("x: \(ax)")
        print("y: \(ay)")
        print("z: \(az)")
        print("\n")
        
        let attitude_pitch = attitude.pitch
        let attitude_roll = attitude.roll
        let attitude_yaw = attitude.yaw
        
        print("Attitude")
        print("Pitch: \(attitude_pitch)")
        print("Roll: \(attitude_roll)")
        print("Yaw: \(attitude_yaw)")
        print("\n")
        
        let rx = rotationRate.x
        let ry = rotationRate.y
        let rz = rotationRate.z
        
        print("Rotation")
        print("x: \(rx)")
        print("y: \(ry)")
        print("z: \(rz)")
        
        let magnitude = sqrt((rx * rx) + (ry * ry) + (rz * rz))
        
        // Update published properties
        DispatchQueue.main.async {
            self.accelX = ax
            self.accelY = ay
            self.accelZ = az
            
            self.gyroX = rx
            self.gyroY = ry
            self.gyroZ = rz
        }
        
        if session.isReachable {
            let message: [String: Any] = [
                "accelX": ax,
                "accelY": ay,
                "accelZ": az,
                "gyroX": rx,
                "gyroY": ry,
                "gyroZ": rz,
                "pitch": attitude_pitch,
                "roll": attitude_roll,
                "yaw": attitude_yaw
            ]
            
            session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("❌ Failed to send message: \(error.localizedDescription)")
            })
        }
        
        // Use elapsed time since start
        let now = Date().timeIntervalSince1970
        let elapsed = (startTime != nil) ? now - startTime! : 0
        print("Time elapsed since start: \(elapsed) seconds")
        let csvLine = "\(elapsed),\(ax),\(ay),\(az),\(rx),\(ry),\(rz),\(attitude_pitch),\(attitude_roll),\(attitude_yaw)\n"
        writeLineToCSV(line: csvLine)


//        if magnitude > 5 {
//            print("🤚 Wrist shaking detected! Magnitude: \(magnitude)")
//            return  // Exit early so moveUp doesn't also trigger
//        }
//
//        // Then: check for upward motion only if no shaking
//        if accel.z > 0.8 {
//            print("⬆️ Arm moving upward detected (z: \(accel.z))")
//        }
    }
    
    private func writeLineToCSV(line: String) {
        let fileName = "motion_data.csv"
        let fileManager = FileManager.default

        do {
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            guard let documentDirectory = urls.first else { return }

            let fileURL = documentDirectory.appendingPathComponent(fileName)
            print("Writing to CSV file at: \(fileURL.path)") // Debug log

            // If file doesn't exist, create and write header first
            if !fileManager.fileExists(atPath: fileURL.path) {
                let header = "timestamp,accel_x,accel_y,accel_z,rotation_x,rotation_y,rotation_z, pitch,roll,yaw\n"
                try header.write(to: fileURL, atomically: true, encoding: .utf8)
                print("CSV file created with header.") // Debug log
            }

            // Append line
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            if let data = line.data(using: .utf8) {
                fileHandle.write(data)
                print("Line appended to CSV: \(line)") // Debug log
            }
            fileHandle.closeFile()

        } catch {
            print("Failed to write to CSV: \(error)") // Debug log
        }
    }

    private func deleteAllCSVFiles() {
        let fileManager = FileManager.default
        do {
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            guard let documentDirectory = urls.first else { return }
            let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "csv" {
                    try fileManager.removeItem(at: fileURL)
                    print("Deleted CSV file: \(fileURL.lastPathComponent)")
                }
            }
        } catch {
            print("Failed to delete CSV files: \(error)")
        }
    }
}
