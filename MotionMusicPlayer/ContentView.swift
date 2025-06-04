//
//  ContentView.swift
//  MotionMusicPlayer
//
//  Created by Alina Chen on 5/14/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var receiver: MotionReceiver

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📡 Live Motion Data")
                .font(.headline)
            
            Text("⏱ Timestamp: \(String(format: "%.2f", receiver.latestTimestamp))")
                .font(.subheadline)

            Group {
                Text("🧭 Accelerometer:")
                HStack {
                    Text("x: \(String(format: "%.2f", receiver.latestAccel["x"] ?? 0))")
                    Text("y: \(String(format: "%.2f", receiver.latestAccel["y"] ?? 0))")
                    Text("z: \(String(format: "%.2f", receiver.latestAccel["z"] ?? 0))")
                }
                
                Text("🌀 Gyroscope:")
                HStack {
                    Text("x: \(String(format: "%.2f", receiver.latestGyro["x"] ?? 0))")
                    Text("y: \(String(format: "%.2f", receiver.latestGyro["y"] ?? 0))")
                    Text("z: \(String(format: "%.2f", receiver.latestGyro["z"] ?? 0))")
                }

                Text("🧠 Attitude:")
                HStack {
                    Text("Pitch: \(String(format: "%.2f", receiver.latestAttitude["pitch"] ?? 0))")
                    Text("Roll: \(String(format: "%.2f", receiver.latestAttitude["roll"] ?? 0))")
                    Text("Yaw: \(String(format: "%.2f", receiver.latestAttitude["yaw"] ?? 0))")
                }
            }
            .font(.caption)
        }
        .padding()
    }
}

