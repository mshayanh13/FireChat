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
    
}
