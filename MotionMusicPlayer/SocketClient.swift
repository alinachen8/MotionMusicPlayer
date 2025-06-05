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
    
    private let host: NWEndpoint.Host = "10.0.0.203" // Your computer's IP address
    private let port: NWEndpoint.Port = 65433 // Updated port to match server
    
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

//        do {
//            // Print the JSON we're about to send
//            print("📤 About to send JSON:", json)
//            
//            // Convert to JSON data
//            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
//            
//            // Print the raw JSON string for debugging
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("📤 Raw JSON string:", jsonString)
//            }
//            
//            // Send the data
//            connection.send(content: jsonData, completion: .contentProcessed { error in
//                if let error = error {
//                    print("❌ Send error: \(error)")
//                } else {
//                    print("✅ JSON sent successfully")
//                }
//            })
//            
//            // Optional: receive response from server
//            receive()
//        } catch {
//            print("❌ JSON serialization error: \(error)")
//            print("❌ Failed to serialize JSON:", json)
//        }
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
