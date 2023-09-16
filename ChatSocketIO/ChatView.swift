//
//  ChatView.swift
//  ChatSocketIO
//
//  Created by 9OSU1G02 on 9/16/23.
//

import SwiftUI

struct ChatView: View {
    @State private var message: String = ""
    @State private var messages: [Message] = []
    @State private var username: String = ""
    @State private var users: [String: String] = [:]
    @State private var newUser: String = ""
    @State private var showUsernamePrompt: Bool = true
    @State private var isShowingNewUserAlert = false

    var body: some View {
        NavigationView {
            VStack {
                if showUsernamePrompt {
                    HStack {
                        TextField("Enter your username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: connect) {
                            Text("Connect")
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(messages, id: \.self) { message in
                            HStack {
                                if message.username == username {
                                    Text("Me:")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                } else {
                                    Text("\(message.username):")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }

                                Text(message.text)
                            }
                        }
                    }

                    HStack {
                        TextField("Enter a message", text: $message)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: sendMessage) {
                            Text("Send")
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Awesome Chat \(users.count > 0 ? "(\(users.count) connected)" : "")")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                ChatClient.shared.disconnect()
            }
            .alert("\(newUser) just joined the chat!",
                   isPresented: $isShowingNewUserAlert)
            {
                Button("OK", role: .cancel) {
                    isShowingNewUserAlert = false
                }
            }
        }
    }

    func connect() {
        ChatClient.shared.connect(username: username)
        ChatClient.shared.receiveMessage { id, username, message in
            self.receiveMessage(username: username, text: message, id: id)
        }
        ChatClient.shared.receiveNewUser { username, users in
            self.receiveNewUser(username: username, users: users)
        }
        showUsernamePrompt = false
    }

    func sendMessage() {
        ChatClient.shared.sendMessage(message)
        message = ""
    }

    func receiveMessage(username: String, text: String, id: String) {
        messages.append(Message(username: username, text: text, id: id))
    }

    func receiveNewUser(username: String, users: [String: String]) {
        self.users = users
        newUser = username

        isShowingNewUserAlert = self.username != username
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
