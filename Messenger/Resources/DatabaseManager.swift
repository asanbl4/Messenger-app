//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Асанали Батырхан on 04.05.2024.
//

import Foundation
import FirebaseDatabase


final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// MARK: - Account Management

extension DatabaseManager {
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)){
        // for trouble shooting
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            // That finds existing email to not register user twice with the same email
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            // return true
            completion(true)
        })
    }
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ], withCompletionBlock: { error, _ in
            guard error == nil else{
                print("failed to write into database")
                completion(false)
                return
            }
            
            // add the user into users collection
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                // [[String: String]] is array of dicts
                if var usersCollection = snapshot.value as? [[String: String]]{
                    // append to user dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else {
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                
            })
            
            completion(true)
            
        })
        
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
        
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    /*
     users => [
        [
            "name": ,
            "safeEmail": ,
        ],
        [
            "name": ,
            "safeEmail": ,
        ],
     ]
     */
}

// MARK: - Sending  messages / conversations
extension DatabaseManager {
    
    /*
     "dsaasdf" => {
        messages: [
            {
                "id": String,
                "type": text/video/photo,
                "content": String,
                "date": Date(),
                "senderEmail": String,
                "is_read": true/false
            }
        ]
     }
     
     conversation => [
        [
            "conversation_id": "dsaasdf",
            "other_user_email": ,
            "latest_message" => [
                                "date": Date(),
                                "latest_message": Message
                                "is_read": true/false
                                ]
        ],
     ]
     */
    /// Creates a new conversation with taargetUserEmail and first message
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let reference = database.child("\(safeEmail)")
        reference.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message,
                ],
            ]
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user
                // you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                reference.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationId: conversationId,
                                                     name: name,
                                                     
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
            else {
                // create new conversation
                userNode["conversations"] = [
                    newConversationData
                ]
                
                reference.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationId: conversationId,
                                                     name: name,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
            
            
        })
    }
    
    private func finishCreatingConversation(conversationId: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        {
//            "id": String,
//            "type": text/video/photo,
//            "content": String,
//            "date": Date(),
//            "senderEmail": String,
//            "is_read": true/false
//        }
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
            
        }
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "senderEmail": currentUserEmail,
            "is_read": false,
            "name": name,
        ]
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("Adding conversation: \(conversationId)")
        
        database.child("\(conversationId)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    /// Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            print("")
            // This is for converting dictionary in db to array
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    LatestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
            
        })
    }
    
    /// Gets all messages for a given conversation
    public func getAllMessagesForConversations(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversations: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
}





struct ChatAppUser {
    let firstName : String
    let lastName: String
    let emailAddress: String
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName : String {
        // joe-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}
