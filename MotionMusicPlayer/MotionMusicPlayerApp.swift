//
//  MotionMusicPlayerApp.swift
//  MotionMusicPlayer
//
//  Created by Alina Chen on 5/14/25.
//

import SwiftUI

@main
struct MotionMusicPlayerApp: App {
    @StateObject var receiver = MotionReceiver()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(receiver)
        }
    }
}
