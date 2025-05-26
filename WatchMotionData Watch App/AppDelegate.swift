//
//  AppDelegate.swift
//  MotionMusicPlayer
//
//  Created by Alina Chen on 5/14/25.
//

import Foundation
import WatchConnectivity
import WatchKit

class AppDelegate: NSObject, WKApplicationDelegate, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
              print("WCSession activation failed with error: \(error.localizedDescription)")
          } else {
              print("WCSession activated successfully with state: \(activationState.rawValue)")
          }
    }
    
    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
}

