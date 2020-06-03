//
//  MessageCell.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/14/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

protocol MessageCellProtocol: class {
    func handleZoomIn(for startingImageView: UIImageView)
    func handlePlay(for videoUrl: URL)
}

class MessageCell: UICollectionViewCell {
    
    //MARK: Properties
    
    var message: Message? {
        didSet { configure() }
    }
    
    var delegate: MessageCellProtocol?
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 16)
        tv.isScrollEnabled = true
        tv.isEditable = false
        tv.textColor = .white
        return tv
    }()
    
    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        return view
    }()
    
    private lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom)))
        return imageView
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "play")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
//    let activityIndicatorView: UIActivityIndicatorView = {
//        let aiv = UIActivityIndicatorView(style: .large)
//        aiv.translatesAutoresizingMaskIntoConstraints = false
//        aiv.hidesWhenStopped = true
//        return aiv
//    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint!
    var bubbleLeftAnchor: NSLayoutConstraint!
    var bubbleRightAnchor: NSLayoutConstraint!
    
//    var player: AVPlayer?
//    var playerLayer: AVPlayerLayer?
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 8, paddingBottom: -4)
        profileImageView.setDimensions(height: 32, width: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleWidthAnchor = bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        bubbleWidthAnchor.isActive = true
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        
        bubbleLeftAnchor.isActive = false
        bubbleRightAnchor.isActive = false
        
        addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 4, paddingRight: 0)
        
        addSubview(messageImageView)
        messageImageView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 4, paddingRight: 0)
        
        addSubview(playButton)
        playButton.centerX(inView: bubbleContainer)
        playButton.centerY(inView: bubbleContainer)
        playButton.setDimensions(height: 50, width: 50)
        
//        addSubview(activityIndicatorView)
//        activityIndicatorView.centerX(inView: bubbleContainer)
//        activityIndicatorView.centerY(inView: bubbleContainer)
//        activityIndicatorView.setDimensions(height: 50, width: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        playerLayer?.removeFromSuperlayer()
//        player?.pause()
//        activityIndicatorView.stopAnimating()
//    }
    
    //MARK: Selectors
    
    @objc func handleZoom(tapGesture: UITapGestureRecognizer) {
        guard message?.videoUrl == nil, let imageView = tapGesture.view as? UIImageView else { return }
        delegate?.handleZoomIn(for: imageView)
    }
    
    @objc func handlePlay() {
        guard let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) else { return }
        delegate?.handlePlay(for: url)
        
//        guard let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) else { return }
//
//        player = AVPlayer(url: url)
//
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer?.frame = messageImageView.frame
//        print(messageImageView.debugDescription)
//        bubbleContainer.layer.addSublayer(playerLayer!)
//
//        player?.play()
//        activityIndicatorView.startAnimating()
//        playButton.isHidden = true
    }
    
    //MARK: Helpers
    
    func configure() {
        guard let message = message else { return }
        let viewModel = MessageViewModel(message: message)
        
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        
        if let text = message.text {
            textView.isHidden = false
            textView.textColor = viewModel.messageTextColor
            textView.text = text
            
            messageImageView.isHidden = true
        } else if let messageImageUrl = message.imageUrl {
            playButton.isHidden = message.videoUrl == nil
            textView.isHidden = true
            
            messageImageView.sd_setImage(with: URL(string: messageImageUrl))
            bubbleContainer.backgroundColor = .clear
            messageImageView.isHidden = false
        }
        
        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        
        profileImageView.isHidden = viewModel.shouldHideProfileImage
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
    
}
