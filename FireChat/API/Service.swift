//
//  Service.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/13/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import Foundation
import Firebase

struct Service {
    
    static func getCurrentUserUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    static func fetchUsers(completion: @escaping ([User])-> Void) {
        var users = [User]()
        Firestore.firestore().collection("users").getDocuments { (snapshot, error) in
            snapshot?.documents.forEach({ (document) in
                
                let dict = document.data()
                let user = User(dictionary: dict)
                users.append(user)
                completion(users)
            })
        }
    }
    
    static func fetchMessages(forUser user: User, completion: @escaping ([Message]) -> Void) {
        var messages = [Message]()
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    let dictionary = change.document.data()
                    messages.append(Message(dictionary: dictionary))
                    completion(messages)
                }
            })
        }
    }
    
    static func uploadMessage(_ message: String, to user: User, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = ["text": message,
                                   "fromId": currentUid,
                                   "toId": user.uid,
                                   "timestamp": Timestamp(date: Date())]
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) { _ in
            COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data, completion: completion)
        }
    }
    
}
