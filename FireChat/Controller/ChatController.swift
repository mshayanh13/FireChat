//
//  ChatController.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/14/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

class ChatController: UICollectionViewController {
    
    //MARK: Properties
    
    private let user: User
    
    //MARK: Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: Helpers
    
    func configureUI() {
        collectionView.backgroundColor = .white
    }
}
