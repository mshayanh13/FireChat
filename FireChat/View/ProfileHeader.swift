//
//  ProfileHeader.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/27/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

protocol ProfileHeaderDelegate: class {
    func dismissController()
}

class ProfileHeader: UIView {
    
    //MARK: Properties
    
    var user: User? {
        didSet { populateUserData() }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        button.tintColor = .white
        button.imageView?.setDimensions(height: 22, width: 22)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleToFill
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4.0
        return iv
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Full Name"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Username"
        return label
    }()
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let height = frame.height
        configureUI(size: height / 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Selectors
    
    @objc func handleDismissal() {
        delegate?.dismissController()
    }
    
    //MARK: Helpers
    
    func populateUserData() {
        guard let user = user else { return }
        
        fullnameLabel.text = user.fullName
        usernameLabel.text = "@\(user.username)"
        
        guard let url = URL(string: user.profileImageURL) else { return }
        profileImageView.sd_setImage(with: url)
        
    }
    
    func configureUI(size: CGFloat = 200) {
        configureGradientLayer()
        
        profileImageView.setDimensions(height: size, width: size)
        profileImageView.layer.cornerRadius = size / 2
        
        addSubview(profileImageView)
        profileImageView.centerX(inView: self)
        profileImageView.anchor(top: topAnchor, paddingTop: 50)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: profileImageView.bottomAnchor, paddingTop: 25)
        
        addSubview(dismissButton)
        dismissButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 12)
        dismissButton.setDimensions(height: 40, width: 40)
    }
    
}
