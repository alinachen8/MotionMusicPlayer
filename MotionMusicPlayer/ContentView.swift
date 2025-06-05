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
        MusicPlayerView()
    }
}

