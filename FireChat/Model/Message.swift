//
//  Message.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/15/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import Foundation
import Firebase

struct Message {
    let text: String?
    let toId: String
    let fromId: String
    var timestamp: Timestamp!
    var user: User?
    var imageUrl: String?
    var imageHeight: Double?
    var imageWidth: Double?
    var videoUrl: String?
    
    let isFromCurrentUser: Bool
    
    var chatPartnerId: String {
        return isFromCurrentUser ? toId : fromId
    }
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        self.isFromCurrentUser = fromId == Auth.auth().currentUser?.uid
        
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageHeight = dictionary["imageHeight"] as? Double
        self.imageWidth = dictionary["imageWidth"] as? Double
        self.videoUrl = dictionary["videoUrl"] as? String
    }
}

struct Conversation {
    let user: User
    let message: Message
}
