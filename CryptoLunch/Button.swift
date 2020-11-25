//
//  Button.swift
//  CryptoLunch
//
//  Created by Josh Arnold on 11/14/20.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class Button : UIButton {
    
    private var disposeBag:DisposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        self.stylize()
        self.becomeReactive()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stylize() {
//        layer.borderWidth = 2
//        layer.borderColor = UIColor.primary.cgColor
        layer.cornerRadius = 20
        tintColor = .primary
        backgroundColor = .primary
    }
    
    func setText(text:String, color:UIColor = UIColor.white) {
        setAttributedTitle(NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.foregroundColor : color,
            NSAttributedString.Key.font : UIFont.init(name: "AvenirNext-Bold", size: 13)!,
        ]), for: .normal)
    }
    
    func becomeReactive() {
        self.rx.controlEvent(.touchDown).asObservable().subscribe(onNext: { [weak self] in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [.allowUserInteraction], animations: {
                self?.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85)
            }, completion: nil)
        }).disposed(by: self.disposeBag)
        
        self.rx.controlEvent([.touchUpInside, .touchUpOutside]).asObservable().subscribe(onNext: { [weak self] in
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 16, options: [.allowUserInteraction], animations: {
                self?.transform = CGAffineTransform.identity
            }, completion: nil)
        }).disposed(by: self.disposeBag)
    }
}
