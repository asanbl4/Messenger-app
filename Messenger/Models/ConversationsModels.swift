//
//  ConversationsModels.swift
//  Messenger
//
//  Created by Асанали Батырхан on 24.05.2024.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let LatestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
