//
//  ChatController.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/14/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

private let reuseIdentifier = "MessageCell"

class ChatController: UICollectionViewController {
    
    //MARK: Properties
    
    private let user: User
    private var messages = [Message]()
    var fromCurrentUser = false
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        return iv
    }()
    
    var startingFrame: CGRect?
    var blackBackground: UIView?
    var startingImageView: UIImageView?
    
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
        fetchMessages()
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: API
    
    func fetchMessages() {
        showLoader(true)
        Service.fetchMessages(forUser: user) { (messages) in
            self.showLoader(false)
            
            self.messages = messages
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom, animated: true)
        }
    }
    
    //MARK: Helpers
    
    func configureUI() {
        collectionView.backgroundColor = .white
        configureNavigationBar(withTitle: user.username, prefersLargeTitles: false)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    //MARK: Selectors
    
    @objc func handleKeyboardDidShow() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(item: messages.count-1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
}

extension ChatController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MessageCell else { return MessageCell() }
        let message = messages[indexPath.row]
        
        cell.message = message
        cell.message?.user = user
        cell.delegate = self
        
        if let text = message.text {
            cell.bubbleWidthAnchor.constant = estimateFrame(for: text).width + 42
        } else {
            cell.bubbleWidthAnchor.constant = 200
        }
        return cell
    }
}

//MARK: UICollectionViewDelegateFlowLayout

extension ChatController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let width = UIScreen.main.bounds.width
        let message = messages[indexPath.row]
        
        if let text = message.text {
            let estimatedFrame = estimateFrame(for: text)
            height = estimatedFrame.height + 20
        } else if let imageWidth = message.imageWidth, let imageHeight = message.imageHeight {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrame(for text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
}

//MARK: CustomInputAccessoryViewDelegate

extension ChatController: CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSendMessage message: String) {
        
        inputView.clearTextField()
        
        Service.uploadTextMessage(message, to: user) { (error) in
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            
            inputView.clearTextField()
        }
    }
    
    func sendMediaMessage() {
        let imagePicker = UIImagePickerController()
        
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.mediaTypes = [kUTTypeImage as String]//, kUTTypeMovie as String]
            
        present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: UIImagePickerControllerDelegate

extension ChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let filename = NSUUID().uuidString + ".mp4"
        
        if let videoUrl = info[.mediaURL] as? URL//, let newUrl = getVideoURL(from: videoUrl, with: filename)
        {
            
            //handleVideoSelected(with: newUrl, and: filename)
            
        } else {
            
            handleImageSelected(with: info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelected() {
        
    }
    
    private func handleImageSelected(with info: [UIImagePickerController.InfoKey: Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectedImage = selectedImage {
            
            Service.uploadImageMessage(selectedImage, to: user) { (error) in
                if let error = error {
                    self.showError(error.localizedDescription)
                    return
                }
            }
        }
    }
}

//MARK: MessageCellProtocol
extension ChatController: MessageCellProtocol {
    func handleZoomIn(for startingImageView: UIImageView) {
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        guard let startingFrame = startingFrame, let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        blackBackground = UIView(frame: keyWindow.frame)
        
        let zoomingImageView = UIImageView(frame: startingFrame)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image
        blackBackground?.isUserInteractionEnabled = true
        blackBackground?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true
        
        if let blackBackground = blackBackground {
            
            blackBackground.backgroundColor = .black
            blackBackground.alpha = 0
            keyWindow.addSubview(blackBackground)
            
            blackBackground.addSubview(zoomingImageView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                blackBackground.alpha = 1
                self.customInputView.alpha = 0
                
                let height = startingFrame.height / startingFrame.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        guard let startingFrame = startingFrame, let zoomOutImageView = tapGesture.view, let blackBackground = blackBackground else { return }
        zoomOutImageView.layer.cornerRadius = 16
        zoomOutImageView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            zoomOutImageView.frame = startingFrame
            blackBackground.alpha = 0
            self.customInputView.alpha = 1
        }) { (completed) in
            zoomOutImageView.removeFromSuperview()
            self.startingImageView?.isHidden = false
        }
    }
    
    func handlePlay(for videoUrl: String) {
        guard let url = URL(string: videoUrl) else { return }
        
    }
    
    
}
