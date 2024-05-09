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
            completion(true)
            
        })
        
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
