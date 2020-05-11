//
//  CustomButton.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/11/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        layer.cornerRadius = 5.0
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        setTitleColor(.white, for: .normal)
        setHeight(height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
