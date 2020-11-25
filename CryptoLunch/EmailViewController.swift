//
//  EmailViewController.swift
//  CryptoLunch
//
//  Created by Josh Arnold on 11/14/20.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa


class EmailView : UIView {
    
    private var email:TextField!
    var amount:TextField!
    private var button:Button!
    private var sep1:UIView!
    private var disposeBag:DisposeBag = DisposeBag()
    
    var emailText:String {
        return self.email.text ?? ""
    }
    
    var amountText:String {
        return self.amount.text ?? "0"
    }
    
    var amountDouble:Double {
        if let x = Double(self.amountText.replacingOccurrences(of: "$", with: "")) {
            return x
        }
        return 0
    }
    
    init() {
        super.init(frame: .zero)
        
        
        
        backgroundColor = .clear
        layer.cornerRadius = 20
        layer.borderWidth = 2
        layer.borderColor = UIColor.primary.cgColor
        
        email = TextField()
        email.layer.borderColor = UIColor.clear.cgColor
        email.textAlignment = .left
        email.setPlaceholder(text: "jeff@gmail.com")
        email.keyboardType = .emailAddress
        addSubview(email)
        
        amount = TextField()
        amount.keyboardType = .decimalPad
        amount.layer.borderColor = UIColor.clear.cgColor
        amount.setPlaceholder(text: "$100")
        addSubview(amount)
        
        sep1 = UIView()
        sep1.backgroundColor = .primary
        addSubview(sep1)
        
        email.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(60)
        }
        
        sep1.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(2)
            make.centerX.equalTo(self.email.snp.right)
        }
        
        amount.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.left.equalTo(self.sep1)
            make.right.equalToSuperview().inset(5)
        }
        
        amount.rx.text
            .asObservable()
            .filter { $0!.count >= 1}
            .map { text in text!.contains("$") ? text! : "$" + text!}
            .bind(to: amount.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clear() {
        self.email.text = ""
        self.amount.text = ""
    }
    
    func edit() {
        self.email.becomeFirstResponder()
    }
}


struct PaymentRequest : Decodable {
    var email:String
    var amount:String
    
    var amountDouble:Double {
        return Double(self.amount.replacingOccurrences(of: "$", with: "")) ?? 0.0
    }
}


class SubtitleTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = UIFont.init(name: "Avenir Next", size: 16)
        detailTextLabel?.font = UIFont.init(name: "Avenir Next", size: 12)
        detailTextLabel?.textColor = .systemGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class EmailViewController : UIViewController {
    
    private var nextButton:UIBarButtonItem!
    private var cancelButton:UIBarButtonItem!
    private var scrollView:UIScrollView = UIScrollView()
    private var stack:UIStackView!
    private var emailView:EmailView!
    private var addEmailButton:Button!
    private var tableView:UITableView!
    
    private var bag:DisposeBag = DisposeBag()
    private var data:BehaviorRelay<[PaymentRequest]> = BehaviorRelay(value: [])
    
    private var amount:BehaviorRelay<Double> = BehaviorRelay(value: 0.0)
        
    private var originalAmount:Double = 0.0
    
    init(amount:Double) {
        super.init(nibName: nil, bundle: nil)
        originalAmount = amount
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Who owes you?"        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        createNextButton()
        setupScrollView()
        setupStackView()
        setupTableView()
        
        
        self.react()
        self.amount.accept(self.originalAmount)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailView.edit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.addTapGesture { (tap) in
            self.view.endEditing(true)
        }
    }
    
    func react() {
        
        self.amount
            .asObservable()
            .map {
            return NSAttributedString(string: "$"+String($0), attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.systemGray3,
                NSAttributedString.Key.font : UIFont.init(name: "AvenirNext-Bold", size: 10)!,
            ])
            }
            .bind(to: self.emailView.amount.rx.attributedPlaceholder)
        .disposed(by: self.bag)
        
        // Delete
        self.tableView.rx.itemDeleted.subscribe(onNext: { x in
            var newData:[PaymentRequest] = self.data.value
            let pay = newData.remove(at: x.row)
            self.amount.accept(self.amount.value + pay.amountDouble)
            self.data.accept(newData)
        }).disposed(by: self.bag)
        
        // On tap
        addEmailButton.rx.tap.asObservable()
            .subscribe(onNext: {
                
                if (self.emailView.amountDouble == 0.0 && self.emailView.emailText != "" && self.amount.value > 0) {
                    self.data.accept(self.data.value + [PaymentRequest(email: self.emailView.emailText, amount: "$"+String(self.amount.value))])
                    self.amount.accept(0)
                    self.emailView.clear()
                    return
                }
                
                let x:Double = self.amount.value - self.emailView.amountDouble
                
                guard x >= 0 && self.emailView.emailText != "" && self.emailView.amountText != "" else {self.emailView.shake(); return}
                
            self.data.accept(self.data.value + [PaymentRequest(email: self.emailView.emailText, amount: self.emailView.amountText)])
            self.amount.accept(x)
            self.emailView.clear()
        }).disposed(by: bag)
                
        // Drive data
        data.bind(to: tableView.rx.items(cellIdentifier: "cell")) { row, model, cell in
            if let cell = cell as? PaymentRow {
                cell.email?.text = "\(model.email)"
                cell.amount?.text = "\(model.amount)"
            }
        }.disposed(by: bag)
    }
}


class PaymentRow : UITableViewCell {
    
    var email:UILabel!
    var amount:UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        email = UILabel()
        email.text = "josh@robinhood.com"
        email.textAlignment = .left
        email.textColor = .primary
        email.font = UIFont(name: "Avenir Next", size: 12)
        contentView.addSubview(email)
        
        amount = UILabel()
        amount.text = "$99.0"
        amount.font = UIFont(name: "Avenir Next", size: 12)
        amount.textColor = .primary
        amount.textAlignment = .right
        contentView.addSubview(amount)
        
        email.snp.makeConstraints { (make) in
            make.top.bottom.left.equalToSuperview().inset(10)
            make.width.equalToSuperview().inset(60)
        }
        
        amount.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview().inset(10)
            make.width.equalTo(60)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmailViewController {
    
    func createNextButton() {
        let x = Button()
        
        x.rx.tap
            .asObservable()
            .subscribe (onNext: {
                
                guard self.data.value.count > 0 && self.amount.value == 0 else {
                    self.emailView.shake()
                    return
                }
                                                
                self.view.endEditing(true)
                let vc = FinalViewController()
                self.hero.isEnabled = true
                vc.hero.isEnabled = true
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }).disposed(by: self.bag)
        
        x.removeConstraints(x.constraints)
        x.layer.cornerRadius = 17
        x.widthAnchor.constraint(equalToConstant: 60).isActive = true
        x.heightAnchor.constraint(equalToConstant: 35).isActive = true
        x.setText(text: "Request", color: .primary)
        x.backgroundColor = .clear        
        nextButton = UIBarButtonItem(customView: x)
        self.navigationItem.rightBarButtonItem = nextButton
        
        let y = Button()
        
        y.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] x in
            self?.navigationController?.hero.dismissViewController()
        }).disposed(by: self.bag)
        
        y.removeConstraints(y.constraints)
        y.layer.cornerRadius = 17
        y.widthAnchor.constraint(equalToConstant: 60).isActive = true
        y.heightAnchor.constraint(equalToConstant: 35).isActive = true
        y.setText(text: "Back", color: .primary)
        y.backgroundColor = .clear
        cancelButton = UIBarButtonItem(customView: y)
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    func setupStackView() {
        emailView = EmailView()
        emailView.hero.id = "pay"
                
        addEmailButton = Button()
        addEmailButton.setText(text: "Add")
        addEmailButton.hero.id = "button"
        
        stack = UIStackView(arrangedSubviews: [emailView, addEmailButton])
        stack.alignment = .fill
        stack.spacing = 10
        stack.axis = .vertical
        stack.distribution = .fill        
        scrollView.addSubview(stack)
                                         
        stack.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(40)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.width.equalTo(220)
        }
    }
    
    func setupTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        
        tableView.delaysContentTouches = false
        tableView.isScrollEnabled = false
        tableView.alwaysBounceVertical = false
//        tableView.isUserInteractionEnabled = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(PaymentRow.self, forCellReuseIdentifier: "cell")
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.stack.snp.bottom).offset(40)
            make.bottom.left.right.equalToSuperview().inset(60)            
        }
    }
}
