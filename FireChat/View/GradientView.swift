//
//  GradientView.swift
//  FireChat
//
//  Created by Mohammad Shayan on 5/28/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        guard let layer = self.layer as? CAGradientLayer else { return }
        layer.colors = [UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor]
        layer.locations = [0, 1]
        layer.frame = self.bounds
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}
