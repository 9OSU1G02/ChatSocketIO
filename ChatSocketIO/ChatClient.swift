//
//  ChatClient.swift
//  ChatSocketIO
//
//  Created by 9OSU1G02 on 9/16/23.
//

import SocketIO
import UIKit

class ChatClient: NSObject {
    static let shared = ChatClient()
    var manager: SocketManager!
    var socket: SocketIOClient!
    var username: String!
    
    override init() {
        super.init()
        manager = SocketManager(socketURL: .init(string: "http://localhost:1902")!)
        socket = manager.defaultSocket
    }
    
    func connect(username: String) {
        self.username = username
        socket.connect(withPayload: ["username": username])
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func sendMessage(_ message: String) {
        socket.emit("sendMessage", message) {
            print("----> send message success: ", message)
        }
    }
    
    func sendUsername(_ username: String) {
        socket.emit("sendUsername", username) {
            print("----> send username success: ", username)
        }
    }
    
    func receiveMessage(_ completion: @escaping (String, String, String) -> Void) {
        socket.on("receiveMessage") { data, _ in
            if let id = data[0] as? String, let username = data[1] as? String, let message = data[2] as? String {
                completion(id, username, message)
            }
        }
    }
    
    func receiveNewUser(_ completion: @escaping (String, [String: String]) -> Void) {
        socket.on("receiveNewUser") { data, _ in
            if let username = data[0] as? String, let users = data[1] as? [String: String] {
                completion(username, users)
            }
        }
    }
}
