//
//  CustomInputAccessoryView.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/14/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import Foundation
import UIKit

protocol CustomInputAccessoryViewDelegate: class {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSendMessage message: String)
    func sendMediaMessage()
}

class CustomInputAccessoryView: UIView {
    
    //MARK: Properties
    
    weak var delegate: CustomInputAccessoryViewDelegate?
    
    private lazy var messageInputTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.placeholder = "Enter Message..."
        tf.borderStyle = .none
        tf.delegate = self
        return tf
    }()
    
    private lazy var uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSendMedia)))
        return uploadImageView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.systemPurple, for: .normal)
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return button
    }()
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        backgroundColor = .white

        layer.shadowOpacity = 0.25
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowColor = UIColor.lightGray.cgColor

        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, bottom: layoutMarginsGuide.bottomAnchor, right: rightAnchor, paddingTop: 12, paddingBottom: 12, paddingRight: 8, width: 50)
        
        addSubview(uploadImageView)
        uploadImageView.anchor(top: topAnchor, left: leftAnchor, bottom: layoutMarginsGuide.bottomAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 12, width: 50)
        
        addSubview(messageInputTextField)
        messageInputTextField.anchor(top: topAnchor,
                                     left: uploadImageView.rightAnchor,
                                    bottom: layoutMarginsGuide.bottomAnchor,
                                    right: sendButton.leftAnchor,
                                    paddingTop: 12, paddingLeft: 8,
                                    paddingBottom: 12, paddingRight: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    //MARK: Selectors
    
    @objc func handleSendMessage() {
        guard let message = messageInputTextField.text, message != "" else { return }
        delegate?.inputView(self, wantsToSendMessage: message)
    }
    
    @objc func handleSendMedia() {
        delegate?.sendMediaMessage()
    }
    
    //MARK: Helper
    
    func clearTextField() {
        messageInputTextField.text = nil
    }
    
}

extension CustomInputAccessoryView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
}
