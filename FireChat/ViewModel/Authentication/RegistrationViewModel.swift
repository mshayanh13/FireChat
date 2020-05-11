//
//  RegistrationViewModel.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/11/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import Foundation

struct RegistrationViewModel: AuthenticationProtocol {
    var email: String?
    var fullName: String?
    var username: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false &&
            fullName?.isEmpty == false &&
            username?.isEmpty == false &&
            password?.isEmpty == false
    }
}
