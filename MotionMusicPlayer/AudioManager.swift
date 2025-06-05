//
//  AudioManager.swift
//  MotionMusicPlayer
//
//  Created by Alina Chen on 6/4/25.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    @Published var likedSongs: Set<String> = []
    @Published var currentSong: Song?

    static let shared = AudioManager()

    private var player: AVAudioPlayer?
    private var songIndex = 0

    private let songs: [Song] = [
        Song(filename: "d4vd", title: "You Left Me First", imageName: "d4vd", artist: "d4vd"),
        Song(filename: "dwsanty", title: "CARICIAS (ﾉ･_-)☆", imageName: "dw_santy", artist: "DW Santy"),
        Song(filename: "kuria", title: "Deep Green", imageName: "kuria", artist: "Christian Kuria"),
        Song(filename: "marias", title: "Echo", imageName: "marias", artist: "The Marias")
    ] // replace with your file names (no .mp3)

    @Published var isPlaying = false
    @Published var currentSongName = "None"

    private init() {
        loadSong(index: songIndex)
    }

    private func loadSong(index: Int) {
        guard index < songs.count else { return }
        let song = songs[index]
        currentSong = song

        guard let url = Bundle.main.url(forResource: song.filename, withExtension: "mp3") else {
            print("❌ Could not load song: \(song.filename)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            currentSongName = currentSong!.title
        } catch {
            print("❌ AVAudioPlayer error:", error)
        }
    }

    func togglePlayPause() {
        guard let player = player else { return }

        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func nextTrack() {
        songIndex = (songIndex + 1) % songs.count
        loadSong(index: songIndex)
        player?.play()
        isPlaying = true
    }

    func previousTrack() {
        songIndex = (songIndex - 1 + songs.count) % songs.count
        loadSong(index: songIndex)
        player?.play()
        isPlaying = true
    }

    func pauseIfGestureDetected(_ gesture: String) {
        if gesture == "pause_gesture" {
            togglePlayPause()
        }
    }
    
    func toggleLike() {
        let song = currentSong!.title
        if likedSongs.contains(song) {
            likedSongs.remove(song)
        } else {
            likedSongs.insert(song)
        }
    }
    
    func isCurrentSongLiked() -> Bool {
        return likedSongs.contains(currentSongName)
    }
}
