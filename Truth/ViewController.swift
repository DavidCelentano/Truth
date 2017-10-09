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
    
    // username label
    @IBOutlet weak var usernameTextField: UITextField!
    
    // api model object
    private let api = BungieAPIService()
    
    // tracks the current console type
    private var console: Console = .Xbox
    
    // tracks recently searched players
    private var recentPlayers: Variable<[String]> = Variable([])
    
    // needed for reactive variable observation
    private let disposeBag = DisposeBag()
    
    // character detail outlets
    @IBOutlet weak var subclassLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var specialLabel: UILabel!
    @IBOutlet weak var heavyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var consoleControl: UISegmentedControl!
    @IBOutlet weak var recentPlayer1Button: UIButton!
    @IBOutlet weak var recentPlayer2Button: UIButton!
    @IBOutlet weak var recentPlayer3Button: UIButton!
    @IBOutlet weak var recentlyViewedLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGradient()
        
        // link reactive variables from the model to the view
        api.subclass.asObservable().bind(to: subclassLabel.rx.text).disposed(by: disposeBag)
        api.lightLevel.asObservable().bind(to: lightLabel.rx.text).disposed(by: disposeBag)
        api.primary.asObservable().bind(to: primaryLabel.rx.text).disposed(by: disposeBag)
        api.special.asObservable().bind(to: specialLabel.rx.text).disposed(by: disposeBag)
        api.heavy.asObservable().bind(to: heavyLabel.rx.text).disposed(by: disposeBag)
        api.hoursPlayed.asObservable().bind(to: timeLabel.rx.text).disposed(by: disposeBag)
        api.info.asObservable().bind(to: infoLabel.rx.text).disposed(by: disposeBag)
        api.recentPlayers.asObservable().subscribe(onNext: { list in
            var players = list
            players.keepLast(3)
            for (index, element) in players.enumerated() {
                switch index {
                case 0:
                    DispatchQueue.main.async {
                        self.recentlyViewedLabel.isHidden = false
                        self.recentPlayer1Button.layer.borderWidth = 2.0
                        self.recentPlayer1Button.layer.borderColor = UIColor.white.cgColor
                        self.recentPlayer1Button.setTitle(element, for: .normal)
                        self.recentPlayer1Button.isHidden = false
                    }
                case 1:
                    DispatchQueue.main.async {
                        self.recentPlayer2Button.layer.borderWidth = 2.0
                        self.recentPlayer2Button.layer.borderColor = UIColor.white.cgColor
                        self.recentPlayer2Button.setTitle(element, for: .normal)
                        self.recentPlayer2Button.isHidden = false
                    }
                case 2:
                    DispatchQueue.main.async {
                        self.recentPlayer3Button.layer.borderWidth = 2.0
                        self.recentPlayer3Button.layer.borderColor = UIColor.white.cgColor
                        self.recentPlayer3Button.setTitle(element, for: .normal)
                        self.recentPlayer3Button.isHidden = false
                    }
                default:
                    return
                }
            }
        }).disposed(by: disposeBag)
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
    

    // set the console type based on the switch
    @IBAction func consoleChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            console = .Xbox
        } else {
            console = .PlayStation
        }
        if var username = usernameTextField.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // send the API request
            sendAPIRequest(for: username)
        }
    }
    
    @IBAction func searchTapped(_ sender: UIButton) {
        if var username = usernameTextField.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // send the API request
            sendAPIRequest(for: username)
        }
    }
    
    @IBAction func recentPlayer1Tapped(_ sender: UIButton) {
        if var username = sender.titleLabel?.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // set the search text field to the correct user
            usernameTextField.text = username
            // send the API request
            sendAPIRequest(for: username)
        }
    }
    
    @IBAction func recentPlayer2Tapped(_ sender: UIButton) {
        if var username = sender.titleLabel?.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // set the search text field to the correct user
            usernameTextField.text = username
            // send the API request
            sendAPIRequest(for: username)
        }
    }
    @IBAction func recentPlayer3Tapped(_ sender: UIButton) {
        if var username = sender.titleLabel?.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // set the search text field to the correct user
            usernameTextField.text = username
            // send the API request
            sendAPIRequest(for: username)
        }
    }
    
    // MARK: API Methods
    
    private func sendAPIRequest(for username: String) {
        // dismiss keyboard
        view.endEditing(true)
        // send API request
        api.fetchAccountId(for: username, console: console)
    }
    
}

extension ViewController: UITextFieldDelegate {
    // when users press return on the keyboard, start the search
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if var username = usernameTextField.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // send the API request
            sendAPIRequest(for: username)
        }
        return false
    }
}

