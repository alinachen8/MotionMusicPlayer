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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Hello, world!")

            // Optional: Just to confirm it's receiving
            Text("Motion data incoming...")
        }
        .padding()
    }
}

