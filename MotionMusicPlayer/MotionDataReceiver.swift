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

    override init() {
        super.init()

        if WCSession.isSupported() {
            print("✅ WCSession is supported")
            session = WCSession.default
            session?.delegate = self
            session?.activate()
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

    // Here’s where we receive motion data
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("📡 Received motion data:")
            print("x: \(message["x"] ?? "nil")")
            print("y: \(message["y"] ?? "nil")")
            print("z: \(message["z"] ?? "nil")")
        }
    }

    // Also required on iOS 14+
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
