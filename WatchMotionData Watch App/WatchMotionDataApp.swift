//
//  WatchMotionDataApp.swift
//  WatchMotionData Watch App
//
//  Created by Alina Chen on 5/14/25.
//

import SwiftUI

@main
struct WatchMotionData_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
