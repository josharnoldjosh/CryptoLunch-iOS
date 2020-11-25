//
//  Splash.swift
//  CryptoLunch
//
//  Created by Josh Arnold on 11/25/20.
//

import Foundation
import UIKit
import SnapKit
import Lottie


class SplashViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.backgroundColor = .systemBackground
        
        let view = AnimationView()
        view.animation = Lottie.Animation.named("splash")
        view.currentProgress = 0.0001
        view.animationSpeed = 0.5
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(135)
        }
        
        view.play { (play) in
            UIView.animate(withDuration: 1.0) {
                view.alpha = 0
            } completion: { (done) in
                let x = UINavigationController(rootViewController: PaymentViewController())
                x.hero.isEnabled = true
                x.modalPresentationStyle = .fullScreen
                x.hero.modalAnimationType = .slide(direction: .right)
                self.present(x, animated: true, completion: nil)
            }
        }
    }
}
