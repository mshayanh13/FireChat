//
//  AuthService.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/12/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit
import Firebase

struct RegistrationCredentials {
    let email: String
    let password: String
    let fullName: String
    let username: String
    let profileImage: UIImage?
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func createUser(credentials: RegistrationCredentials, completionHandler: @escaping (String?)->Void) {
        
        self.uploadImage(credentials.profileImage) { (imageURL, error) in
            
            self.createUser(email: credentials.email, password: credentials.password) { (userUid, error) in
                
                guard let userUid = userUid else {
                    print(error!)
                    completionHandler(error!)
                    return
                }
                
                var data: [String: Any] = ["email": credentials.email, "fullname": credentials.fullName, "uid": userUid, "username": credentials.username]
                
                if let imageURL = imageURL {
                    data["profileImageURL"] = imageURL
                }
                
                self.uploadUserInfoToDatabase(data: data, completionHandler: completionHandler)
            }
            
        }
    }
    
    func uploadImage(_ profileImage: UIImage?, completionHandler: @escaping (_ profileImageURL: String?, _ errorMessage: String?)->Void) {
        guard let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.3) else {
            completionHandler(nil, "Error")
            return
        }
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) { (meta, error) in
            if let error = error {
                print("DEBUG: Failed to uplaod image with error: \(error.localizedDescription)")
                completionHandler(nil, error.localizedDescription)
                return
            }
            
            ref.downloadURL { (url, error) in
                guard let profileImageURL = url?.absoluteString else {
                    completionHandler(nil, "Error")
                    return
                }
                
                completionHandler(profileImageURL, nil)
                
            }
        }
    }
    
    func createUser(email: String, password: String, completionHandler: @escaping (_ uid: String?, _ errorMessage: String?)->Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed to create user with error: \(error.localizedDescription)")
                completionHandler(nil, error.localizedDescription)
            }
            
            guard let uid = result?.user.uid else {
                completionHandler(nil, "Error")
                return
            }
            
            completionHandler(uid, nil)
            
        }
    }
    
    func uploadUserInfoToDatabase(data: [String: Any], completionHandler: @escaping (_ errorMessage: String?)->Void) {
        
        guard let uid = data["uid"] as? String else { return }
        Firestore.firestore().collection("users").document(uid).setData(data) { (error) in
            
            if let error = error {
                print("DEBUG: Failed to upload user data with error: \(error.localizedDescription)")
                completionHandler(error.localizedDescription)
                return
            }
            
            print("DEBUG: Did create user...")
            completionHandler(nil)
            
        }
    }
}
