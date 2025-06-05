//
//  SocketClient.swift
//  MotionMusicPlayer
//
//  Created by Alina Chen on 6/3/25.
//

import Foundation
import Network

class SocketClient: ObservableObject {
    @Published var classification: String = ""
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
                let cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)
                print("📥 Raw response: \(cleaned)")

                if let jsonData = cleaned.data(using: .utf8) {
                    do {
                        if let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                           let gesture = parsed["prediction"] as? String,
                           let status = parsed["status"] as? String, status == "complete" {
                            DispatchQueue.main.async {
                                self.classification = gesture
                            }
                        } else {
                            print("⚠️ Missing 'prediction' or 'status'")
                        }
                    } catch {
                        print("❌ JSON parse error: \(error)")
                    }
                }
            } else if let error = error {
                print("❌ Receive error: \(error)")
            }

            // Continue receiving future messages
            self.receive()
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
