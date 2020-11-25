//
//  TextField.swift
//  CryptoLunch
//
//  Created by Josh Arnold on 11/14/20.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class TextField : UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    init() {
        super.init(frame: .zero)
        self.stylize()
        heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stylize() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.primary.cgColor
        layer.cornerRadius = 20
        textAlignment = .center
        tintColor = .primary
        textColor = .primary
        font = UIFont.init(name: "AvenirNext-Bold", size: 13)
        autocapitalizationType = .none
        spellCheckingType = .no
    }
    
    func setPlaceholder(text: String) {
        attributedPlaceholder = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.systemGray3,
            NSAttributedString.Key.font : UIFont.init(name: "AvenirNext-Bold", size: 13)!,
        ])
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
