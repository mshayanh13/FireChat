//
//  Service.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/13/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

struct Service {
    
    static func getCurrentUserUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    static func fetchUsers(completion: @escaping ([User])-> Void) {
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            guard var users = snapshot?.documents.map({ User(dictionary: $0.data()) }) else { return }
            
            if let i = users.firstIndex(where: {$0.uid == Auth.auth().currentUser?.uid}) {
                users.remove(at: i)
            }
            
            completion(users)
        }
    }
    
    static func fetchUser(withUid uid: String, completion: @escaping (User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { (snapshot, error) in
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchConversations(completion: @escaping ([Conversation]) -> Void) {
        var converstaions = [Conversation]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_MESSAGES.document(uid).collection("recent-messages").order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ (change) in
                let dictionary = change.document.data()
                let message = Message(dictionary: dictionary)
                
                self.fetchUser(withUid: message.chatPartnerId) { (user) in
                    let conversation = Conversation(user: user, message: message)
                    converstaions.append(conversation)
                    completion(converstaions)
                }
                
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
    
    static func uploadTextMessage(_ message: String, to user: User, completion: @escaping ((Error?) -> Void)) {
        
        let properties = ["text": message]
        uploadMessage(with: properties, to: user, completion: completion)
        
    }
    
    static func uploadImageMessage(_ image: UIImage, to user: User, completion: @escaping ((Error?) -> Void)) {
        uploadImageToStorage(image) { (imageUrl, error) in
            if let error = error {
                completion(error)
            } else if let imageUrl = imageUrl {
                let properties = ["imageUrl": imageUrl,
                "imageWidth": image.size.width,
                "imageHeight": image.size.height] as [String : Any]
                
                uploadMessage(with: properties, to: user, completion: completion)
            }
        }
    }
    
    static func uploadImageToStorage(_ image: UIImage, completion: @escaping (_ imageUrl: String?, _ error: Error?) -> Void) {
        if let imageData = image.jpegData(compressionQuality: 0.2) {
            let profileImageRef = Storage.storage().reference().child("message_images/\(NSUUID().uuidString).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            profileImageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    completion(nil, error)
                } else if let _ = metadata {
                    profileImageRef.downloadURL { (url, error) in
                        if let error = error {
                            completion(nil, error)
                        } else if let url = url {
                            completion(url.absoluteString, nil)
                        }
                    }
                }
            }
        }
    }
    
    static func uploadVideoMessage(_ videoUrl: URL, to user: User, completion: @escaping ((Error?) -> Void)) {
        let filename = UUID().uuidString + ".mp4"
        
        guard let newUrl = getVideoURL(from: videoUrl, with: filename) else { return }
        uploadVideoToStorage(newUrl, with: filename) { (properties, error) in
            if let error = error {
                completion(error)
            } else if let properties = properties {
                uploadMessage(with: properties, to: user, completion: completion)
            }
        }
    }
    
    static func uploadVideoToStorage(_ videoUrl: URL, with filename: String, completion: @escaping (_ properties: [String: Any]?, _ error: Error?) -> Void) {
        let videoRef = Storage.storage().reference().child("message_movies/\(filename)")
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        videoRef.putFile(from: videoUrl, metadata: metadata) {
            (metadata, error) in
            if let error = error {
                completion(nil, error)
            } else if let _ = metadata {
                videoRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(nil, error)
                    } else if let url = url, let thumbnail = self.thumbnailImage(for: videoUrl) {
                        self.uploadImageToStorage(thumbnail) { (thumbnailImageUrl, error) in
                            if let error = error {
                                completion(nil, error)
                            } else if let thumbnailImageUrl = thumbnailImageUrl {
                                let properties = ["videoUrl": url.absoluteString,
                                                  "imageUrl": thumbnailImageUrl,
                                                  "imageWidth": thumbnail.size.width,
                                                  "imageHeight": thumbnail.size.height] as [String : Any]
                                
                                completion(properties, nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func getVideoURL(from url: URL, with filename: String) -> URL? {
        
        do {
            let documents = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destination = documents.appendingPathComponent(filename)
            try FileManager.default.copyItem(at: url, to: destination)
            return destination
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        
    }
    
    static func deleteVideo(at url: URL) {
        do {
            
            try FileManager.default.removeItem(at: url)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func thumbnailImage(for videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        
        
        return nil
    }
    
    static func uploadMessage(with properties: [String: Any], to user: User, completion: @escaping ((Error?) -> Void)) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        var data: [String: Any] = ["fromId": currentUid,
                                   "toId": user.uid,
                                   "timestamp": Timestamp(date: Date())]
        
        properties.forEach { (key, value) in
            data[key] = value
        }
        
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) { error in
            if let error = error {
                completion(error)
            } else {
                COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data) { (error) in
                            if let error = error {
                                completion(error)
                            } else {
                                COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid).setData(data) { error in
                                    if let error = error {
                                        completion(error)
                                    } else {
                                        completion(nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
}
