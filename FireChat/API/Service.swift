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
