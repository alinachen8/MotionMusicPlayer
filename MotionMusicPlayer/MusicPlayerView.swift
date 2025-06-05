//
//  MusicPlayerView.swift
//  MotionMusicPlayer
//
//  Created by Alina Chen on 6/4/25.
//

import SwiftUI

struct MusicPlayerView: View {
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var socket = SocketClient.shared

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("CS396: Gesture Music Player")
                                    .fontWeight(.semibold)
                                    .padding(.top, 40)
                                    .foregroundColor(.black)
                Text("🔍 Gesture: \(socket.classification)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer(minLength: 40)

                // 🎵 Album Art
                if let song = audioManager.currentSong {
                    Image(song.imageName)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding(.horizontal, 20)

                    // 📝 Song Title + Artist + Like
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(song.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)

                                Text(song.artist) // Replace with real artist if available
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Button(action: {
                                audioManager.toggleLike()
                            }) {
                                Image(systemName: audioManager.isCurrentSongLiked() ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // 📊 (Optional) Static progress bar placeholder
                Rectangle()
                    .frame(height: 4)
                    .foregroundColor(.gray.opacity(0.3))
                    .cornerRadius(2)
                    .padding(.horizontal, 32)

                // ⏯ Playback Controls
                HStack(spacing: 50) {
                    Button(action: {
                        audioManager.previousTrack()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.black)
                    }

                    Button(action: {
                        audioManager.togglePlayPause()
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(.black)
                    }

                    Button(action: {
                        audioManager.nextTrack()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.black)
                    }
                }

                Spacer()
            }
            .padding(.top)
            .onChange(of: socket.classification) { gesture in
                print("Gesture received: \(gesture)")

                switch gesture {
                case "stop":
                    audioManager.togglePlayPause()
                case "rotate_next":
                    audioManager.nextTrack()
                case "rotate_prev":
                    audioManager.previousTrack()
                case "like":
                    audioManager.toggleLike()
                default:
                    break
                }
            }

        }
    }
}

#Preview {
    MusicPlayerView()
}
