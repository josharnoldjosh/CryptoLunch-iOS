//
//  FinalViewController.swift
//  CryptoLunch
//
//  Created by Josh Arnold on 11/24/20.
//

import Foundation
import UIKit
import SnapKit
import Lottie
import Hero


class FinalViewController : UIViewController {

    private var loading:AnimationView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.animate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // call thing here...
        self.loading.play { (done) in
            
            
            
            UIView.animate(withDuration: 0.5) {
                self.loading.alpha = 0
            } completion: { (done) in
                
                self.loading.animation = Lottie.Animation.named("tick.min")
                self.loading.animationSpeed = 0.5
                self.loading.loopMode = .playOnce
                self.loading.currentProgress = 0.00001
                self.loading.alpha = 1.0
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                                                
                self.loading.play { (done) in
                                              
                    UIView.animate(withDuration: 0.5) {
                        self.loading.alpha = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        let x = UINavigationController(rootViewController: PaymentViewController())
                        x.hero.isEnabled = true
                        x.modalPresentationStyle = .fullScreen
                        self.hero.isEnabled = true
                        self.hero.modalAnimationType = .cover(direction:.right)
                        x.hero.modalAnimationType = .cover(direction: .right)
//                        self.hero.replaceViewController(with: x)
                        self.present(x, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func dismissViewControllers() {

        guard let vc = self.presentingViewController else { return }

        while (vc.presentingViewController != nil) {
            vc.dismiss(animated: true, completion: nil)
        }
    }
}


extension FinalViewController {
    
    func animate() {
        loading = AnimationView()
        view.addSubview(loading)
        
        loading.animation = Lottie.Animation.named("timeline.min")
        loading.animationSpeed = 1.5
        loading.loopMode = .playOnce
        loading.currentProgress = 0.00001
                
        loading.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        }
    }
}
