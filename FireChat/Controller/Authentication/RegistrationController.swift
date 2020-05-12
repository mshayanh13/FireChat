//
//  RegistrationController.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/11/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit
import Firebase

class RegistrationController: UIViewController {
    
    //MARK: Properties
    
    private var registrationViewModel = RegistrationViewModel()
    private var profileImage: UIImage?
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.clipsToBounds = true
        return button
    }()
    
    private lazy var emailContainerView: InputContainerView = {
        return InputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
    }()
    
    private lazy var fullNameContainerView: InputContainerView = {
        return InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullNameTextField)
    }()
    
    private lazy var usernameContainerView: InputContainerView = {
        return InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: usernameTextField)
    }()
    
    private lazy var passwordContainerView: UIView = {
        return InputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    }()
    
    private let emailTextField = CustomTextField(placeholder: "Email")
    private let fullNameTextField = CustomTextField(placeholder: "Full Name")
    private let usernameTextField = CustomTextField(placeholder: "Username")
    
    private let passwordTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let signUpButton: CustomButton = {
        let button = CustomButton(title: "Sign Up")
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ",
                                                        attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Sign Up",
                                                  attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    //MARK: Selectors
    
    @objc func handleRegistration() {
        guard let email = emailTextField.text?.lowercased(),
            let password = passwordTextField.text,
            let fullName = fullNameTextField.text,
            let username = usernameTextField.text?.lowercased() else { return }
        
        self.uploadImage { (imageURL, error) in
            
            self.createUser(email: email, password: password) { (userUid, error) in
                
                guard let userUid = userUid else {
                    print(error!)
                    return
                }
                
                var data: [String: Any] = ["email": email, "fullname": fullName, "uid": userUid, "username": username]
                
                if let imageURL = imageURL {
                    data["profileImageURL"] = imageURL
                }
                
                self.uploadUserInfoToDatabase(data: data) { (error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            registrationViewModel.email = sender.text
        } else if sender == passwordTextField {
            registrationViewModel.password = sender.text
        } else if sender == usernameTextField {
            registrationViewModel.username = sender.text
        } else {
            registrationViewModel.fullName = sender.text
        }
        
        checkFormStatus()
    }
    
    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Helpers
    
    func configureUI() {
        configureGradientLayer()
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        plusPhotoButton.setDimensions(height: 200.0, width: 200.0)
        
        let stackView = UIStackView(arrangedSubviews: [emailContainerView,
                                                       fullNameContainerView,
                                                       usernameContainerView,
                                                       passwordContainerView,
                                                       signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor,
                                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                     right: view.rightAnchor,
                                     paddingLeft: 32,
                                     paddingBottom: 16,
                                     paddingRight: 32)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func uploadImage(completionHandler: @escaping (_ profileImageURL: String?, _ errorMessage: String?)->Void) {
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

//MARK: UIImagePickerViewDelegate

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as? UIImage
        profileImage = image
        plusPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        plusPhotoButton.layer.borderColor = UIColor(white: 1, alpha: 0.7).cgColor
        plusPhotoButton.layer.borderWidth = 3.0
        plusPhotoButton.layer.cornerRadius = 200 / 2
        
        dismiss(animated: true, completion: nil)
        
    }
}

extension RegistrationController: AuthenticationControllerProtocol {
    func checkFormStatus() {
        if registrationViewModel.formIsValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        }
    }
}
