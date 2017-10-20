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
    private var usernameTextField: UITextField = {
        let t = UITextField()
        t.returnKeyType = .search
        t.backgroundColor = UIColor.white
        t.borderStyle = .roundedRect
        t.autocapitalizationType = .none
        return t
    }()
    
    private var usernameLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        l.text = "Enter a username"
        return l
    }()
    
    private var searchButton: UIButton = {
       let b = UIButton()
        b.setImage(#imageLiteral(resourceName: "Search Icon"), for: .normal)
        b.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        return b
    }()
    
    private var consoleLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        l.text = "Platform"
        return l
    }()
    
    private var platformSwitch: UISegmentedControl = {
        let s = UISegmentedControl()
        s.tintColor = UIColor.white
        s.insertSegment(withTitle: "Xbox", at: 0, animated: false)
        s.insertSegment(withTitle: "PS", at: 1, animated: false)
        s.insertSegment(withTitle: "PC", at: 2, animated: false)
        s.selectedSegmentIndex = 0
        s.addTarget(self, action: #selector(platformChanged), for: UIControlEvents.valueChanged)
        return s
    }()
    
    private var versionLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        l.text = "Destiny Version"
        return l
    }()
    
    private var versionSwitch: UISegmentedControl = {
        let s = UISegmentedControl()
        s.tintColor = UIColor.white
        s.insertSegment(withTitle: "1", at: 0, animated: false)
        s.insertSegment(withTitle: "2", at: 1, animated: false)
        s.selectedSegmentIndex = 1
        s.setWidth(50.0, forSegmentAt: 0)
        s.setWidth(50.0, forSegmentAt: 1)
        s.addTarget(self, action: #selector(versionChanged), for: UIControlEvents.valueChanged)
        return s
    }()
    
    // api model object
    private let api = BungieAPIService()
    
    // tracks the current console type
    private var console: Console = .Xbox
    
    // tracks the destiny version to search against
    private var destiny2Enabled: Bool = true
    
    // tracks recently searched players
    private var recentPlayers: Variable<[String]> = Variable([])
    
    // needed for reactive variable observation
    private let disposeBag = DisposeBag()
    
    // character detail outlets
    // TODO subclass uilabel to make a custom one
    private var subclassHeaderLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var subclassDetailLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var primaryHeaderLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var primaryDetailLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var specialHeaderLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var specialDetailLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var heavyHeaderLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var heavyDetailLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var lightLevelHeaderLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var lightLevelDetailLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var timePlayedHeaderLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var timePlayedDetailLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    private var infoLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        return l
    }()
    
    private var recentPlayersHeaderLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    private var recentPlayer1Button: UIButton = {
        let b = UIButton()
        b.setTitleColor(UIColor.white, for: .normal)
        b.addTarget(self, action: #selector(recentPlayer1Tapped), for: .touchUpInside)
        return b
    }()
    private var recentPlayer2Button: UIButton = {
        let b = UIButton()
        b.setTitleColor(UIColor.white, for: .normal)
        b.addTarget(self, action: #selector(recentPlayer2Tapped), for: .touchUpInside)
        return b
    }()
    private var recentPlayer3Button: UIButton = {
        let b = UIButton()
        b.setTitleColor(UIColor.white, for: .normal)
        b.addTarget(self, action: #selector(recentPlayer3Tapped), for: .touchUpInside)
        return b
    }()
    
    
    @IBOutlet weak var scrollView: UIScrollView!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGradient()
        
        usernameTextField.delegate = self
        
        // setup header labels
        subclassHeaderLabel.text = "Class | Subclass"
        primaryHeaderLabel.text = "Primary Weapon"
        specialHeaderLabel.text = "Special Weapon"
        heavyHeaderLabel.text = "Heavy Weapon"
        lightLevelHeaderLabel.text = "Light Level"
        timePlayedHeaderLabel.text = "Hours Played"
        recentPlayersHeaderLabel.text = "Quick Search"
        
        // setup horizontal stack views
        let subclassStackView = UIStackView(arrangedSubviews: [subclassHeaderLabel, subclassDetailLabel])
        subclassStackView.alignment = .center
        subclassStackView.axis = .horizontal
        subclassStackView.spacing = 15
        
        let primaryStackView = UIStackView(arrangedSubviews: [primaryHeaderLabel, primaryDetailLabel])
        primaryStackView.alignment = .center
        primaryStackView.axis = .horizontal
        primaryStackView.spacing = 15
        
        let specialStackView = UIStackView(arrangedSubviews: [specialHeaderLabel, specialDetailLabel])
        specialStackView.alignment = .center
        specialStackView.axis = .horizontal
        specialStackView.spacing = 15
        
        let heavyStackView = UIStackView(arrangedSubviews: [heavyHeaderLabel, heavyDetailLabel])
        heavyStackView.alignment = .center
        heavyStackView.axis = .horizontal
        heavyStackView.spacing = 15
        
        let lightLevelStackView = UIStackView(arrangedSubviews: [lightLevelHeaderLabel, lightLevelDetailLabel])
        lightLevelStackView.alignment = .center
        lightLevelStackView.axis = .horizontal
        lightLevelStackView.spacing = 15
        
        let timePlayedStackView = UIStackView(arrangedSubviews: [timePlayedHeaderLabel, timePlayedDetailLabel])
        timePlayedStackView.alignment = .center
        timePlayedStackView.axis = .horizontal
        timePlayedStackView.spacing = 15
        
        
        // setup vertical stack views
        let statsStackView = UIStackView(arrangedSubviews: [subclassStackView, primaryStackView, specialStackView, heavyStackView, lightLevelStackView, timePlayedStackView])
        statsStackView.alignment = .fill
        statsStackView.axis = .vertical
        statsStackView.spacing = 15
        statsStackView.distribution = .equalSpacing
        
        let recentPlayersStackView = UIStackView(arrangedSubviews: [recentPlayersHeaderLabel, recentPlayer1Button, recentPlayer2Button, recentPlayer3Button])
        recentPlayersStackView.alignment = .fill
        recentPlayersStackView.axis = .vertical
        recentPlayersStackView.spacing = 15
        recentPlayersStackView.distribution = .equalSpacing
        
        let consoleStackView = UIStackView(arrangedSubviews: [consoleLabel, platformSwitch])
        consoleStackView.alignment = .center
        consoleStackView.axis = .vertical
        consoleStackView.spacing = 10
        consoleStackView.distribution = .equalSpacing
        
        let versionStackView = UIStackView(arrangedSubviews: [versionLabel, versionSwitch])
        versionStackView.alignment = .center
        versionStackView.axis = .vertical
        versionStackView.spacing = 10
        versionStackView.distribution = .equalSpacing
        
        // layout views in scrollView
        scrollView.addSubview(consoleStackView)
        consoleStackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(15)
            make.leading.equalTo(scrollView).offset(15)
        }
        
        scrollView.addSubview(versionStackView)
        versionStackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(15)
            make.trailing.equalTo(scrollView).offset(-15)
            make.leading.greaterThanOrEqualTo(consoleStackView.snp.trailing).offset(20).priority(999)
        }
        
        scrollView.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(consoleStackView.snp.bottom).offset(15)
            make.centerX.equalTo(scrollView)
        }
        
        scrollView.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.leading.greaterThanOrEqualTo(scrollView).offset(15).priority(999)
            make.centerX.equalTo(scrollView)
            make.top.equalTo(usernameLabel.snp.bottom).offset(10)
        }
        
        scrollView.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.leading.equalTo(usernameTextField.snp.trailing).offset(10)
            make.width.equalTo(34)
            make.height.equalTo(34)
            make.centerY.equalTo(usernameTextField)
        }
        
        scrollView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(15)
            make.leading.equalTo(scrollView).offset(15)
            make.trailing.equalTo(scrollView).offset(-15)
        }
        
        scrollView.addSubview(statsStackView)
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(15)
            make.centerX.equalTo(scrollView)
            make.leading.equalTo(scrollView).offset(15)
            make.trailing.equalTo(scrollView).offset(-15)
        }
        
        scrollView.addSubview(recentPlayersStackView)
        recentPlayersStackView.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(15)
            make.centerX.equalTo(scrollView)
            make.bottom.equalTo(scrollView).offset(-20)
        }
        

        // link reactive variables from the model to the view
        api.subclass.asObservable().bind(to: subclassDetailLabel.rx.text).disposed(by: disposeBag)
        api.lightLevel.asObservable().bind(to: lightLevelDetailLabel.rx.text).disposed(by: disposeBag)
        api.primary.asObservable().bind(to: primaryDetailLabel.rx.text).disposed(by: disposeBag)
        api.special.asObservable().bind(to: specialDetailLabel.rx.text).disposed(by: disposeBag)
        api.heavy.asObservable().bind(to: heavyDetailLabel.rx.text).disposed(by: disposeBag)
        api.hoursPlayed.asObservable().bind(to: timePlayedDetailLabel.rx.text).disposed(by: disposeBag)
        api.info.asObservable().bind(to: infoLabel.rx.text).disposed(by: disposeBag)
        // start / stop animating the activity indicator when loading
//        api.isLoading.asObservable().subscribe(onNext: { isLoading in
//            if isLoading {
//                DispatchQueue.main.async {
//                    self.loadingIndicator.startAnimating()
//                }
//            }
//            else {
//                DispatchQueue.main.async {
//                    self.loadingIndicator.stopAnimating()
//                }
//            }
//        }).disposed(by: disposeBag)
        
        // update the recent players list for quick search
        api.recentPlayers.asObservable().subscribe(onNext: { list in
            var players = list
            players.keepLast(3)
            for (index, element) in players.enumerated() {
                switch index {
                case 0:
                    DispatchQueue.main.async {
                        self.recentPlayersHeaderLabel.isHidden = false
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
    
    @objc func platformChanged() {
        if platformSwitch.selectedSegmentIndex == 0 {
            console = .Xbox
        } else if platformSwitch.selectedSegmentIndex == 1 {
            console = .PlayStation
        } else {
            console = .PC
        }
        if var username = usernameTextField.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // send the API request
            sendAPIRequest(for: username)
        }
    }
    
    @objc func versionChanged() {
        if versionSwitch.selectedSegmentIndex == 0 {
            destiny2Enabled = false
        } else {
            destiny2Enabled = true
        }
        if var username = usernameTextField.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // send the API request
            sendAPIRequest(for: username)
        }
    }
    
    @objc func searchTapped() {
        if var username = usernameTextField.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // send the API request
            sendAPIRequest(for: username)
        }
    }
    
    @objc func recentPlayer1Tapped() {
        if var username = recentPlayer1Button.titleLabel?.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // set the search text field to the correct user
            usernameTextField.text = username
            // send the API request
            sendAPIRequest(for: username)
        }
    }

    @objc func recentPlayer2Tapped() {
        if var username = recentPlayer2Button.titleLabel?.text {
            // trim any trailing whitespace for autocomplete
            username = username.trimmingCharacters(in: .whitespaces)
            // set the search text field to the correct user
            usernameTextField.text = username
            // send the API request
            sendAPIRequest(for: username)
        }
    }
    @objc func recentPlayer3Tapped() {
        if var username = recentPlayer3Button.titleLabel?.text {
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
        api.fetchAccountId(for: username, console: console, destiny2Enabled: destiny2Enabled)
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

