//
//  ContentView.swift
//  WatchMotionData Watch App
//
//  Created by Alina Chen on 5/14/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()

    var body: some View {
        VStack(spacing: 8) {
            Text("Streaming...").bold()

            Group {
                Text("Accelerometer")
                Text("X: \(motionManager.accelX, specifier: "%.2f")")
                Text("Y: \(motionManager.accelY, specifier: "%.2f")")
                Text("Z: \(motionManager.accelZ, specifier: "%.2f")")
            }

            Divider().padding(.vertical, 4)

            Group {
                Text("Gyroscope")
                Text("X: \(motionManager.gyroX, specifier: "%.2f")")
                Text("Y: \(motionManager.gyroY, specifier: "%.2f")")
                Text("Z: \(motionManager.gyroZ, specifier: "%.2f")")
            }
        }
        .font(.footnote)
        .padding()
        .onAppear {
            motionManager.startStreaming()
        }
        .onDisappear {
            motionManager.stopStreaming()
        }
    }
}

#Preview {
    ContentView()
}


