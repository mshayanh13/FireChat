//
//  ConverstaionViewModel.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/26/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import Foundation

struct ConversationViewModel {
    private let conversation: Conversation
    
    var profileImageUrl: URL? {
        return URL(string: conversation.user.profileImageURL)
    }
    
    var timestamp: String {
        let date = conversation.message.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    init(conversation: Conversation) {
        self.conversation = conversation
    }
}
