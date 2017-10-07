//
//  ViewController.swift
//  Truth
//
//  Created by David Celentano on 10/5/17.
//  Copyright © 2017 David Celentano. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    let api = BungieAPIService()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var subclassLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var specialLabel: UILabel!
    @IBOutlet weak var heavyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var consoleSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGradient()
        api.subclass.asObservable().bind(to: subclassLabel.rx.text).disposed(by: disposeBag)
        api.lightLevel.asObservable().bind(to: lightLabel.rx.text).disposed(by: disposeBag)
        api.primary.asObservable().bind(to: primaryLabel.rx.text).disposed(by: disposeBag)
        api.special.asObservable().bind(to: specialLabel.rx.text).disposed(by: disposeBag)
        api.heavy.asObservable().bind(to: heavyLabel.rx.text).disposed(by: disposeBag)
        api.hoursPlayed.asObservable().bind(to: timeLabel.rx.text).disposed(by: disposeBag)
        api.info.asObservable().bind(to: infoLabel.rx.text).disposed(by: disposeBag)
    }
    
    // creates a gradient for the view background
    private func setUpGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        view.backgroundColor = UIColor.truthBlue
        gradientLayer.colors = [UIColor.truthBlue.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0, 1.0]
        view.layer.sublayers?.insert(gradientLayer, at: 0)
    }

    @IBAction func searchTapped(_ sender: UIButton) {
        view.endEditing(true)
        if let username = usernameTextField.text {
            if consoleSwitch.isOn {
                api.fetchAccountId(for: username, console: .Xbox)
            } else {
                api.fetchAccountId(for: username, console: .PlayStation)
            }
            
        }
        // TODO else return feedback to enter a username
    }
    
}

