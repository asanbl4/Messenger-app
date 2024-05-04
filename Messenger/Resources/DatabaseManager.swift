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
    
    
}

// MARK - account management

extension DatabaseManager {
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)){
        database.child(email).observeSingleEvent(of: .value, with: { snapshot in
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
    public func insertUser(with user: ChatAppUser) {
        database.child(user.emailAddress).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ])
    }
}

struct ChatAppUser {
    let firstName : String
    let lastName: String
    let emailAddress: String
//    let profilePictureUrl : String
}
