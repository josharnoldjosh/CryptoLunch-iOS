//
//  PaymentViewController.swift
//  CryptoLunch
//
//  Created by Josh Arnold on 11/13/20.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Hero
import Closures


class PaymentViewController : UIViewController {
    
    
    private var scrollView:UIScrollView = UIScrollView()
    private var stackView:UIStackView!
    private var paymentAmount, walletInput:TextField!
    private var button:Button!
    private var disposeBag:DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CryptoLunch"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupScrollView()
        setupTextFields()
        setupButton()
        setupStackView()
        becomeReactive()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.addTapGesture { (tap) in
            self.view.endEditing(true)
        }        
    }
    
    func becomeReactive() {
        paymentAmount.rx.text
            .asObservable()
            .filter { $0!.count >= 1}
            .map { text in text!.contains("$") ? text! : "$" + text!}
            .bind(to: paymentAmount.rx.text)
            .disposed(by: disposeBag)
        
        button.rx.tap.asObservable()            
            .subscribe(onNext: {
            if let x = Double(self.paymentAmount.text!.replacingOccurrences(of: "$", with: "")) {                
                self.view.endEditing(true)
                let controller = UINavigationController(rootViewController: EmailViewController(amount: x))
                controller.modalPresentationStyle = .fullScreen
                controller.hero.isEnabled = true
                
                self.present(controller, animated: true, completion: nil)
            }else{
                self.paymentAmount.shake()
            }
        }).disposed(by: disposeBag)
    }
}


extension PaymentViewController {
    
    func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    func setupStackView() {
        stackView = UIStackView(arrangedSubviews: [paymentAmount, walletInput, button])
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.distribution = .fill
        scrollView.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(40)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.width.equalTo(220)
        }
    }
    
    func setupTextFields() {
        paymentAmount = TextField()
        paymentAmount.keyboardType = .decimalPad
        paymentAmount.setPlaceholder(text: "$0.00")
        paymentAmount.hero.id = "pay"
        
        walletInput = TextField()
        walletInput.setPlaceholder(text: "XXX XXX XXX")
    }
    
    func setupButton() {
        button = Button()
        button.setText(text: "Next")
        button.hero.id = "button"
    }
}
