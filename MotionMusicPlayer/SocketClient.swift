//
//  SocketClient.swift
//  MotionMusicPlayer
//
//  Created by Alina Chen on 6/3/25.
//

import Foundation
import Network

class SocketClient {
    static let shared = SocketClient()
    
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "SocketClientQueue")
    
    private let host: NWEndpoint.Host = "127.0.0.1" // localhost
    private let port: NWEndpoint.Port = 65432 // !! UPDATE
    
    private init() {
        connect()
    }
    
    private func connect() {
        connection = NWConnection(host: host, port: port, using: .tcp)
                
        connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("✅ Socket connected to \(self.host):\(self.port)")
            case .failed(let error):
                print("❌ Socket connection failed: \(error)")
            case .waiting(let error):
                print("⏳ Waiting to reconnect: \(error)")
            default:
                break
            }
        }

        // 👇 YOU NEED THIS to initiate the connection!
        connection?.start(queue: queue)
        print("🔌 Socket connection started")
    }
    
    func send(json: [String: Any]) {
        guard let connection = connection else {
            print("❌ No active connection")
            return
        }

        do {
            var data = try JSONSerialization.data(withJSONObject: json, options: [])
            if let newline = "\n".data(using: .utf8) {
                data.append(newline)  // newline-delimited JSON
            }
            
            connection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    print("❌ Send error: \(error)")
                } else {
                    print("📤 Sent JSON to server")
                }
            })
            
            // Optional: receive response from server
            receive()
        } catch {
            print("❌ JSON serialization error: \(error)")
        }
    }
        
    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, _, error in
            if let data = data, let response = String(data: data, encoding: .utf8) {
                print("📥 Received from server: \(response)")
                // Do something with the response
            } else if let error = error {
                print("❌ Receive error: \(error)")
            }
        }
    }
}



extension SocketClient {
    func close() {
        connection?.cancel()
        connection = nil
        print("🔌 Socket connection closed")
    }
}

print("🔌 Initializing SocketClient...")
let client: SocketClient = SocketClient.shared
// Example usage of both play and pause actions
client.send(json: ["action": "play", "song": "example.mp3"])
client.send(json: ["action": "pause"])

let endTime = Date().addingTimeInterval(300) // 5 minutes = 300 seconds
while Date() < endTime {
    print("Sending play command...")
    client.send(json: ["action": "pause"])
    Thread.sleep(forTimeInterval: 5)

    if let input = readLine(strippingNewline: true), input.lowercased() == "x" {
        print("Exiting loop due to 'x' key press.")
        break
    }
}

client.close()
// Example usage:
// client.close()
// client.send(json: ["action": "play", "song": "example.mp3"])
// client.send(json: ["action": "pause"])
// client.send(json: ["action": "stop"])