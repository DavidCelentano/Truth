////
////  ViewController.swift
////  Truth
////
////  Created by David Celentano on 10/5/17.
////  Copyright © 2017 David Celentano. All rights reserved.
////
//
//import UIKit
//import SnapKit
//import RxSwift
//import RxCocoa
//import Flurry_iOS_SDK
//import StoreKit
//import Foundation
//
//class ViewController: UIViewController {
//  
//  // MARK: UI elements
//  
//  // username label
//  private var usernameTextField: UITextField = {
//    let t = UITextField()
//    t.returnKeyType = .search
//    t.backgroundColor = UIColor.white
//    t.borderStyle = .roundedRect
//    t.autocapitalizationType = .none
//    t.clearButtonMode = .always
//    return t
//  }()
//  
//  private var usernameLabel = UILabel.whiteLabel()
//  
//  private var searchButton: UIButton = {
//    let b = UIButton()
//    b.setImage(#imageLiteral(resourceName: "Search Icon"), for: .normal)
//    b.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
//    return b
//  }()
//  
//  private var platformLabel: UILabel = {
//    let l = UILabel()
//    l.textColor = UIColor.white
//    l.numberOfLines = 0
//    l.text = "Platform"
//    return l
//  }()
//  
//  private var platformSwitch: UISegmentedControl = {
//    let s = UISegmentedControl()
//    s.tintColor = UIColor.white
//    s.insertSegment(withTitle: "Xbox", at: 0, animated: false)
//    s.insertSegment(withTitle: "PS", at: 1, animated: false)
//    s.insertSegment(withTitle: "PC", at: 2, animated: false)
//    s.selectedSegmentIndex = UserDefaults.standard.value(forKey: "platform") as? Int ?? 0
//    s.setWidth(50.0, forSegmentAt: 0)
//    s.setWidth(50.0, forSegmentAt: 1)
//    s.setWidth(50.0, forSegmentAt: 2)
//    s.addTarget(self, action: #selector(platformChanged), for: UIControlEvents.valueChanged)
//    return s
//  }()
//  
//  private var versionLabel: UILabel = {
//    let l = UILabel()
//    l.textColor = UIColor.white
//    l.numberOfLines = 0
//    l.text = "Version"
//    return l
//  }()
//  
//  private var versionSwitch: UISegmentedControl = {
//    let s = UISegmentedControl()
//    s.tintColor = UIColor.white
//    s.insertSegment(withTitle: "1", at: 0, animated: false)
//    s.insertSegment(withTitle: "2", at: 1, animated: false)
//    s.selectedSegmentIndex = UserDefaults.standard.value(forKey: "version") as? Int ?? 1
//    s.setWidth(50.0, forSegmentAt: 0)
//    s.setWidth(50.0, forSegmentAt: 1)
//    s.addTarget(self, action: #selector(versionChanged), for: UIControlEvents.valueChanged)
//    return s
//  }()
//  
//  private var loadingIndicator: UIActivityIndicatorView = {
//    let i = UIActivityIndicatorView()
//    i.activityIndicatorViewStyle = .white
//    i.hidesWhenStopped = true
//    return i
//  }()
//  
//  // api model object
//  private let api = BungieAPIService()
//  
//  // tracks the current console type
//  private var console: Console = {
//    guard let consoleId = UserDefaults.standard.value(forKey: "platform") as? Int else { return .Xbox }
//    if consoleId == 0 { return .Xbox }
//    else if consoleId == 1 { return .PlayStation }
//    else if consoleId == 2 { return .PC }
//    else { assertionFailure("console set unexpected value"); return .Xbox }
//    }() {
//    didSet {
//      // disabled destiny 1 if PC is selected
//      if console == .PC {
//        versionSwitch.setEnabled(false, forSegmentAt: 0)
//        versionSwitch.selectedSegmentIndex = 1
//        destiny2Enabled = true
//      } else {
//        versionSwitch.setEnabled(true, forSegmentAt: 0)
//      }
//    }
//  }
//  
//  // tracks the destiny version to search against
//  private var destiny2Enabled: Bool = {
//    guard let versionId = UserDefaults.standard.value(forKey: "version") as? Int else { return true }
//    if versionId == 0 { return false }
//    else if versionId == 1 { return true }
//    else { assertionFailure("destiny2Enabled set unexpected value"); return true }
//  }()
//  
//  // tracks recently searched players
//  private var recentPlayers: Variable<[String]> = Variable([])
//  
//  // the number of stats currently supported
//  private var numOfStats = 10
//  
//  // needed for reactive variable observation
//  private let disposeBag = DisposeBag()
//  
//  // character detail outlets
//  private var subclassHeaderLabel = UILabel.whiteLabel()
//  private var subclassDetailLabel = UILabel.whiteLabel()
//  private var primaryHeaderLabel = UILabel.whiteLabel()
//  private var primaryDetailLabel = UILabel.whiteLabel()
//  private var specialHeaderLabel = UILabel.whiteLabel()
//  private var specialDetailLabel = UILabel.whiteLabel()
//  private var heavyHeaderLabel = UILabel.whiteLabel()
//  private var heavyDetailLabel = UILabel.whiteLabel()
//  private var overallKDHeaderLabel = UILabel.whiteLabel()
//  private var overallKDDetailLabel = UILabel.whiteLabel()
//  private var overallKDAHeaderLabel = UILabel.whiteLabel()
//  private var overallKDADetailLabel = UILabel.whiteLabel()
//  private var overallCombatRatingHeaderLabel = UILabel.whiteLabel()
//  private var overallCombatRatingDetailLabel = UILabel.whiteLabel()
//  private var overallWinLossRatioHeaderLabel = UILabel.whiteLabel()
//  private var overallWinLossRatioDetailLabel = UILabel.whiteLabel()
//  private var lightLevelHeaderLabel = UILabel.whiteLabel()
//  private var lightLevelDetailLabel = UILabel.whiteLabel()
//  private var weaponBestTypeHeaderLabel = UILabel.whiteLabel()
//  private var weaponBestTypeDetaiLabel = UILabel.whiteLabel()
//  private var timePlayedHeaderLabel = UILabel.whiteLabel()
//  private var timePlayedDetailLabel = UILabel.whiteLabel()
//  private var infoLabel: UILabel = {
//    let l = UILabel()
//    l.textColor = UIColor.orange
//    l.numberOfLines = 0
//    return l
//  }()
//  
//  // stats stack views
//  private var statsStackView: UIStackView!
//  private var subclassStackView: UIStackView!
//  private var primaryStackView: UIStackView!
//  private var specialStackView: UIStackView!
//  private var heavyStackView: UIStackView!
//  private var overallKDStackView: UIStackView!
//  private var overallKDAStackView: UIStackView!
//  private var overallWinLossRatioStackView: UIStackView!
//  private var overallCombatRatingStackView: UIStackView!
//  private var weaponBestTypeStackView: UIStackView!
//  private var lightLevelStackView: UIStackView!
//  private var timePlayedStackView: UIStackView!
//  
//  
//  // recent players buttons
//  private var recentPlayersHeaderLabel: UILabel = {
//    let l = UILabel()
//    l.textColor = UIColor.white
//    l.numberOfLines = 0
//    l.textAlignment = .center
//    l.isHidden = true
//    return l
//  }()
//  private var recentPlayer1Button: UIButton = {
//    let b = UIButton()
//    b.setTitleColor(UIColor.white, for: .normal)
//    b.addTarget(self, action: #selector(recentPlayer1Tapped), for: .touchUpInside)
//    b.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
//    return b
//  }()
//  private var recentPlayer2Button: UIButton = {
//    let b = UIButton()
//    b.setTitleColor(UIColor.white, for: .normal)
//    b.addTarget(self, action: #selector(recentPlayer2Tapped), for: .touchUpInside)
//    b.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
//    return b
//  }()
//  private var recentPlayer3Button: UIButton = {
//    let b = UIButton()
//    b.setTitleColor(UIColor.white, for: .normal)
//    b.addTarget(self, action: #selector(recentPlayer3Tapped), for: .touchUpInside)
//    b.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
//    return b
//  }()
//  
//  private var filterButton: UIButton = {
//    let b = UIButton(type: .system)
//    b.setTitle("Filter", for: .normal)
//    b.layer.cornerRadius = 5
//    b.layer.borderWidth = 1
//    b.layer.borderColor = UIColor.white.cgColor
//    b.titleLabel?.adjustsFontSizeToFitWidth = true
//    b.tintColor = .white
//    b.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
//    return b
//  }()
//  
//  
//  @IBOutlet weak var scrollView: UIScrollView!
//  
//  // MARK: View Functions
//  
//  // set status bar to white
//  override var preferredStatusBarStyle: UIStatusBarStyle {
//    return .lightContent
//  }
//  
//  override func viewWillLayoutSubviews() {
//    // update filter number
//    let hiddenStats = numOfStats - statsStackView.arrangedSubviews.count
//    if hiddenStats > 0 {
//      filterButton.setTitle("Filter (\(hiddenStats))", for: .normal)
//    } else {
//      filterButton.setTitle("Filter", for: .normal)
//    }
//  }
//  
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    
//    // if PC has been retained by userdefaults, ensure destiny 1 is disabled
//    if console == .PC {
//      versionSwitch.setEnabled(false, forSegmentAt: 0)
//      versionSwitch.selectedSegmentIndex = 1
//      destiny2Enabled = true
//    }
//    
//    setUpGradient()
//    
//    usernameTextField.delegate = self
//    
//    // set fonts
//    usernameLabel.text = "Enter a gamertag"
//    recentPlayersHeaderLabel.font = UIFont.boldSystemFont(ofSize: 16)
//    infoLabel.font = UIFont.boldSystemFont(ofSize: 16)
//    
//    // setup header labels
//    subclassHeaderLabel.text = "Class | Subclass:"
//    primaryHeaderLabel.text = "Primary Weapon:"
//    specialHeaderLabel.text = "Special Weapon:"
//    heavyHeaderLabel.text = "Heavy Weapon:"
//    lightLevelHeaderLabel.text = "Light Level:"
//    timePlayedHeaderLabel.text = "Hours Played:"
//    overallKDHeaderLabel.text = "Overall KD:"
//    overallKDAHeaderLabel.text = "Overall KDA:"
//    overallWinLossRatioHeaderLabel.text = "Overall Win/Loss:"
//    overallCombatRatingHeaderLabel.text = "Overall Combat Rating:"
//    weaponBestTypeHeaderLabel.text = "Best Weapon Type:"
//    recentPlayersHeaderLabel.text = "Quick Search"
//    
//    // setup horizontal stack views
//    subclassStackView = createStatStackView(with: [subclassHeaderLabel, subclassDetailLabel])
//    primaryStackView = createStatStackView(with: [primaryHeaderLabel, primaryDetailLabel])
//    specialStackView = createStatStackView(with: [specialHeaderLabel, specialDetailLabel])
//    heavyStackView = createStatStackView(with: [heavyHeaderLabel, heavyDetailLabel])
//    overallKDStackView = createStatStackView(with: [overallKDHeaderLabel, overallKDDetailLabel])
//    overallKDAStackView = createStatStackView(with: [overallKDAHeaderLabel, overallKDADetailLabel])
//    overallWinLossRatioStackView = createStatStackView(with: [overallWinLossRatioHeaderLabel, overallWinLossRatioDetailLabel])
//    overallCombatRatingStackView = createStatStackView(with: [overallCombatRatingHeaderLabel, overallCombatRatingDetailLabel])
//    weaponBestTypeStackView = createStatStackView(with: [weaponBestTypeHeaderLabel, weaponBestTypeDetaiLabel])
//    lightLevelStackView = createStatStackView(with: [lightLevelHeaderLabel, lightLevelDetailLabel])
//    timePlayedStackView = createStatStackView(with: [timePlayedHeaderLabel, timePlayedDetailLabel])
//    
//    
//    // setup vertical stack views
//    statsStackView = UIStackView()
//    // include stats based on user default settings
//    let ud = UserDefaults.standard
//    if ud.value(forKey: "subclassEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(subclassStackView) }
//    if ud.value(forKey: "primaryEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(primaryStackView) }
//    if ud.value(forKey: "specialEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(specialStackView) }
//    if ud.value(forKey: "heavyEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(heavyStackView) }
//    if ud.value(forKey: "lightLevelEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(lightLevelStackView) }
//    if ud.value(forKey: "overallKDEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(overallKDStackView) }
//    if ud.value(forKey: "overallKDAEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(overallKDAStackView) }
//    if ud.value(forKey: "overallWinLossEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(overallWinLossRatioStackView) }
//    if ud.value(forKey: "overallCombatRatingEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(overallCombatRatingStackView) }
//    if ud.value(forKey: "weaponBestTypeEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(weaponBestTypeStackView)}
//    if ud.value(forKey: "timePlayedEnabled") as? Bool ?? true { statsStackView.addArrangedSubview(timePlayedStackView) }
//    
//    statsStackView.alignment = .fill
//    statsStackView.axis = .vertical
//    statsStackView.spacing = 15
//    statsStackView.distribution = .equalSpacing
//    
//    let recentPlayersStackView = UIStackView(arrangedSubviews: [recentPlayersHeaderLabel, recentPlayer1Button, recentPlayer2Button, recentPlayer3Button])
//    recentPlayersStackView.alignment = .fill
//    recentPlayersStackView.axis = .vertical
//    recentPlayersStackView.spacing = 15
//    recentPlayersStackView.distribution = .equalSpacing
//    
//    let consoleStackView = UIStackView(arrangedSubviews: [platformLabel, platformSwitch])
//    consoleStackView.alignment = .center
//    consoleStackView.axis = .vertical
//    consoleStackView.spacing = 10
//    consoleStackView.distribution = .equalSpacing
//    
//    let versionStackView = UIStackView(arrangedSubviews: [versionLabel, versionSwitch])
//    versionStackView.alignment = .center
//    versionStackView.axis = .vertical
//    versionStackView.spacing = 10
//    versionStackView.distribution = .equalSpacing
//    
//    // layout views in scrollView
//    scrollView.addSubview(consoleStackView)
//    consoleStackView.snp.makeConstraints { make in
//      make.top.equalTo(scrollView).offset(15)
//      make.leading.equalTo(scrollView).offset(15)
//    }
//    
//    scrollView.addSubview(versionStackView)
//    versionStackView.snp.makeConstraints { make in
//      make.top.equalTo(scrollView).offset(15)
//      make.trailing.equalTo(scrollView).offset(-15)
//      make.leading.greaterThanOrEqualTo(consoleStackView.snp.trailing).offset(20).priority(999)
//    }
//    
//    scrollView.addSubview(usernameLabel)
//    usernameLabel.snp.makeConstraints { make in
//      make.top.equalTo(consoleStackView.snp.bottom).offset(15)
//      make.centerX.equalTo(scrollView)
//    }
//    
//    scrollView.addSubview(usernameTextField)
//    usernameTextField.snp.makeConstraints { make in
//      make.width.equalTo(180)
//      make.leading.greaterThanOrEqualTo(scrollView).offset(15).priority(999)
//      make.centerX.equalTo(scrollView)
//      make.top.equalTo(usernameLabel.snp.bottom).offset(10)
//    }
//    
//    scrollView.addSubview(filterButton)
//    filterButton.snp.makeConstraints { make in
//      make.centerY.equalTo(usernameTextField)
//      make.trailing.equalTo(usernameTextField.snp.leading).offset(-20)
//      make.leading.equalTo(scrollView).offset(15)
//      make.height.equalTo(34)
//    }
//    
//    scrollView.addSubview(searchButton)
//    searchButton.snp.makeConstraints { make in
//      make.leading.equalTo(usernameTextField.snp.trailing).offset(10)
//      make.width.equalTo(34)
//      make.height.equalTo(34)
//      make.centerY.equalTo(usernameTextField)
//    }
//    
//    scrollView.addSubview(loadingIndicator)
//    loadingIndicator.snp.makeConstraints { make in
//      make.centerY.equalTo(usernameLabel)
//      make.centerX.equalTo(filterButton)
//      make.height.equalTo(34)
//      make.width.equalTo(34)
//    }
//    
//    scrollView.addSubview(infoLabel)
//    infoLabel.snp.makeConstraints { make in
//      make.top.equalTo(usernameTextField.snp.bottom).offset(15)
//      make.leading.equalTo(scrollView).offset(15)
//      make.trailing.equalTo(scrollView).offset(-15)
//    }
//    
//    scrollView.addSubview(statsStackView)
//    statsStackView.snp.makeConstraints { make in
//      make.top.equalTo(infoLabel.snp.bottom).offset(15)
//      make.centerX.equalTo(scrollView)
//      make.leading.equalTo(scrollView).offset(15)
//      make.trailing.equalTo(scrollView).offset(-15)
//    }
//    
//    scrollView.addSubview(recentPlayersStackView)
//    recentPlayersStackView.snp.makeConstraints { make in
//      make.top.equalTo(statsStackView.snp.bottom).offset(15)
//      make.centerX.equalTo(scrollView)
//      make.bottom.equalTo(scrollView).offset(-20)
//      make.width.equalTo(160)
//    }
//    
//    
//    // link reactive variables from the model to the view
//    // Sublcass
//    api.subclass.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.subclassHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: subclassDetailLabel.rx.text).disposed(by: disposeBag)
//    // Light Level
//    api.lightLevel.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.lightLevelHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: lightLevelDetailLabel.rx.text).disposed(by: disposeBag)
//    // Primary
//    api.primary.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.primaryHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: primaryDetailLabel.rx.text).disposed(by: disposeBag)
//    // Special
//    api.special.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.specialHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: specialDetailLabel.rx.text).disposed(by: disposeBag)
//    // Heavy
//    api.heavy.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.heavyHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: heavyDetailLabel.rx.text).disposed(by: disposeBag)
//    // Combat Rating
//    api.overallCombatRating.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.overallCombatRatingHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: overallCombatRatingDetailLabel.rx.text).disposed(by: disposeBag)
//    // Win Loss
//    api.overallWinLossRatio.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.overallWinLossRatioHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: overallWinLossRatioDetailLabel.rx.text).disposed(by: disposeBag)
//    // KD
//    api.overallKD.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.overallKDHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: overallKDDetailLabel.rx.text).disposed(by: disposeBag)
//    // KDA
//    api.overallKDA.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.overallKDAHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: overallKDADetailLabel.rx.text).disposed(by: disposeBag)
//    // Best Weapon
//    api.weaponBestType.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.weaponBestTypeHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: weaponBestTypeDetaiLabel.rx.text).disposed(by: disposeBag)
//    // Hours Played
//    api.hoursPlayed.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.timePlayedHeaderLabel.isHidden = !(string.count > 0)
//      }}).bind(to: timePlayedDetailLabel.rx.text).disposed(by: disposeBag)
//    // Info
//    api.info.asObservable().do(onNext: { string in
//      DispatchQueue.main.async {
//        self.infoLabel.isHidden = !(string.count > 0)
//      }}).bind(to: infoLabel.rx.text).disposed(by: disposeBag)
//    
//    // start / stop animating the activity indicator when loading
//    api.isLoading.asObservable().subscribe(onNext: { isLoading in
//      if isLoading {
//        DispatchQueue.main.async {
//          self.loadingIndicator.startAnimating()
//        }
//      }
//      else {
//        DispatchQueue.main.async {
//          self.loadingIndicator.stopAnimating()
//        }
//      }
//    }).disposed(by: disposeBag)
//    
//    // update the recent players list for quick search
//    api.recentPlayers.asObservable().subscribe(onNext: { list in
//      var players = list
//      players.keepLast(3)
//      for (index, element) in players.enumerated() {
//        switch index {
//        case 0:
//          DispatchQueue.main.async {
//            self.recentPlayersHeaderLabel.isHidden = false
//            self.recentPlayer1Button.layer.borderWidth = 2.0
//            self.recentPlayer1Button.layer.borderColor = UIColor.white.cgColor
//            self.recentPlayer1Button.setTitle(element, for: .normal)
//            self.recentPlayer1Button.isHidden = false
//          }
//        case 1:
//          DispatchQueue.main.async {
//            self.recentPlayer2Button.layer.borderWidth = 2.0
//            self.recentPlayer2Button.layer.borderColor = UIColor.white.cgColor
//            self.recentPlayer2Button.setTitle(element, for: .normal)
//            self.recentPlayer2Button.isHidden = false
//          }
//        case 2:
//          DispatchQueue.main.async {
//            self.recentPlayer3Button.layer.borderWidth = 2.0
//            self.recentPlayer3Button.layer.borderColor = UIColor.white.cgColor
//            self.recentPlayer3Button.setTitle(element, for: .normal)
//            self.recentPlayer3Button.isHidden = false
//          }
//        default:
//          return
//        }
//      }
//    }).disposed(by: disposeBag)
//  }
//  
//  // creates a gradient for the view background
//  private func setUpGradient() {
//    let gradientLayer = CAGradientLayer()
//    gradientLayer.frame = view.bounds
//    view.backgroundColor = UIColor.truthBlue
//    gradientLayer.colors = [UIColor.truthBlue.cgColor, UIColor.black.cgColor]
//    gradientLayer.locations = [0, 1.0]
//    view.layer.sublayers?.insert(gradientLayer, at: 0)
//  }
//  
//  // MARK: Outlet Methods
//  
//  @objc func platformChanged() {
//    UserDefaults.standard.set(platformSwitch.selectedSegmentIndex, forKey: "platform")
//    if platformSwitch.selectedSegmentIndex == 0 {
//      console = .Xbox
//    } else if platformSwitch.selectedSegmentIndex == 1 {
//      console = .PlayStation
//    } else {
//      console = .PC
//    }
//    if var username = usernameTextField.text {
//      // trim any trailing whitespace for autocomplete
//      username = username.trimmingCharacters(in: .whitespaces)
//      // send the API request
//      sendAPIRequest(for: username)
//    }
//  }
//  
//  @objc func versionChanged() {
//    UserDefaults.standard.set(versionSwitch.selectedSegmentIndex, forKey: "version")
//    if versionSwitch.selectedSegmentIndex == 0 {
//      destiny2Enabled = false
//    } else {
//      destiny2Enabled = true
//    }
//    if var username = usernameTextField.text {
//      // trim any trailing whitespace for autocomplete
//      username = username.trimmingCharacters(in: .whitespaces)
//      // send the API request
//      sendAPIRequest(for: username)
//    }
//  }
//  
//  @objc func searchTapped() {
//    if var username = usernameTextField.text {
//      // trim any trailing whitespace for autocomplete
//      username = username.trimmingCharacters(in: .whitespaces)
//      // send the API request
//      sendAPIRequest(for: username)
//    }
//  }
//  
//  @objc func recentPlayer1Tapped() {
//    // analytics
//    Flurry.logEvent("QuickSearch Tapped")
//    if var username = recentPlayer1Button.titleLabel?.text {
//      // trim any trailing whitespace for autocomplete
//      username = username.trimmingCharacters(in: .whitespaces)
//      // set the search text field to the correct user
//      usernameTextField.text = username
//      // send the API request
//      sendAPIRequest(for: username)
//    }
//  }
//  
//  @objc func recentPlayer2Tapped() {
//    // analytics
//    Flurry.logEvent("QuickSearch Tapped")
//    if var username = recentPlayer2Button.titleLabel?.text {
//      // trim any trailing whitespace for autocomplete
//      username = username.trimmingCharacters(in: .whitespaces)
//      // set the search text field to the correct user
//      usernameTextField.text = username
//      // send the API request
//      sendAPIRequest(for: username)
//    }
//  }
//  @objc func recentPlayer3Tapped() {
//    // analytics
//    Flurry.logEvent("QuickSearch Tapped")
//    if var username = recentPlayer3Button.titleLabel?.text {
//      // trim any trailing whitespace for autocomplete
//      username = username.trimmingCharacters(in: .whitespaces)
//      // set the search text field to the correct user
//      usernameTextField.text = username
//      // send the API request
//      sendAPIRequest(for: username)
//    }
//  }
//  
//  @objc func filterTapped() {
//    // analytics
//    Flurry.logEvent("Filter Tapped")
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    guard let filterVC = storyboard.instantiateViewController(withIdentifier: "Info") as? FilterViewController else { assertionFailure("\(#function) Could not present InfoVC"); return }
//    filterVC.modalTransitionStyle = .flipHorizontal
//    filterVC.delegate = self
//    present(filterVC, animated: true, completion: nil)
//  }
//  
//  // MARK: API Methods
//  
//  private func sendAPIRequest(for username: String) {
//    // drop request if no username entered
//    if username.count == 0 { return }
//    // analytics
//    let searchParams = ["gamertag" : username, "console" : String(describing: console), "destiny2?" : String(describing: destiny2Enabled)]
//    Flurry.logEvent("Search", withParameters: searchParams)
//    // dismiss keyboard
//    view.endEditing(true)
//    // send API request
//    api.fetchAccountId(for: username, console: console, destiny2Enabled: destiny2Enabled)
//    
//    // after 10 seconds, if the app has been launched 5 times or more, show rating popup
//    let timer = DispatchTime.now() + .seconds(10)
//    DispatchQueue.main.asyncAfter(deadline: timer) {
//      if UserDefaults.standard.integer(forKey: "launchCount") > 4 {
//        if #available(iOS 10.3, *) {
//          SKStoreReviewController.requestReview()
//        }
//      }
//    }
//  }
//  
//  // MARK: Helper Methods
//  
//  private func createStatStackView(with views: [UIView]) -> UIStackView {
//    let stackView = UIStackView(arrangedSubviews: views)
//    stackView.alignment = .center
//    stackView.axis = .horizontal
//    stackView.spacing = 15
//    return stackView
//  }
//}
//
//// MARK: InfoViewControllerDelegate
//extension ViewController: FilterViewControllerDelegate {
//  func setEnabled(to bool: Bool, for stat: Stat) {
//    guard let statsStackView = statsStackView else { assertionFailure("statsStack not found"); return }
//    switch stat {
//    case .subclass:
//      bool ? statsStackView.insertArrangedSubview(subclassStackView, at: 0) : statsStackView.removeArrangedSubview(subclassStackView)
//      UserDefaults.standard.set(bool, forKey: "subclassEnabled")
//    case .primary:
//      bool ? statsStackView.insertArrangedSubview(primaryStackView, at: min(statsStackView.arrangedSubviews.count, 1)) : statsStackView.removeArrangedSubview(primaryStackView)
//      UserDefaults.standard.set(bool, forKey: "primaryEnabled")
//    case .special:
//      bool ? statsStackView.insertArrangedSubview(specialStackView, at: min(statsStackView.arrangedSubviews.count, 2)) : statsStackView.removeArrangedSubview(specialStackView)
//      UserDefaults.standard.set(bool, forKey: "specialEnabled")
//    case .heavy:
//      bool ? statsStackView.insertArrangedSubview(heavyStackView, at: min(statsStackView.arrangedSubviews.count, 3)) : statsStackView.removeArrangedSubview(heavyStackView)
//      UserDefaults.standard.set(bool, forKey: "heavyEnabled")
//    case .lightLevel:
//      bool ? statsStackView.insertArrangedSubview(lightLevelStackView, at: min(statsStackView.arrangedSubviews.count, 4)) : statsStackView.removeArrangedSubview(lightLevelStackView)
//      UserDefaults.standard.set(bool, forKey: "lightLevelEnabled")
//    case .overallKD:
//      bool ? statsStackView.insertArrangedSubview(overallKDStackView, at: min(statsStackView.arrangedSubviews.count, 5)) : statsStackView.removeArrangedSubview(overallKDStackView)
//      UserDefaults.standard.set(bool, forKey: "overallKDEnabled")
//    case .overallKDA:
//      bool ? statsStackView.insertArrangedSubview(overallKDAStackView, at: min(statsStackView.arrangedSubviews.count, 6)) : statsStackView.removeArrangedSubview(overallKDAStackView)
//      UserDefaults.standard.set(bool, forKey: "overallKDAEnabled")
//    case .overallWinLoss:
//      bool ? statsStackView.insertArrangedSubview(overallWinLossRatioStackView, at: min(statsStackView.arrangedSubviews.count, 7)) : statsStackView.removeArrangedSubview(overallWinLossRatioStackView)
//      UserDefaults.standard.set(bool, forKey: "overallWinLossEnabled")
//    case .overallCombatRating:
//      bool ? statsStackView.insertArrangedSubview(overallCombatRatingStackView, at: min(statsStackView.arrangedSubviews.count, 8)) : statsStackView.removeArrangedSubview(overallCombatRatingStackView)
//      UserDefaults.standard.set(bool, forKey: "overallCombatRatingEnabled")
//    case .weaponBestType:
//      bool ? statsStackView.insertArrangedSubview(weaponBestTypeStackView, at: min(statsStackView.arrangedSubviews.count, 9)) : statsStackView.removeArrangedSubview(weaponBestTypeStackView)
//      UserDefaults.standard.set(bool, forKey: "weaponBestTypeEnabled")
//    case .timePlayed:
//      bool ? statsStackView.insertArrangedSubview(timePlayedStackView, at: min(statsStackView.arrangedSubviews.count, 10)) : statsStackView.removeArrangedSubview(timePlayedStackView)
//      UserDefaults.standard.set(bool, forKey: "timePlayedEnabled")
//    }
//  }
//}
//
//// MARK: UITextFieldDelegate
//
//extension ViewController: UITextFieldDelegate {
//  // when users press return on the keyboard, start the search
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    if var username = usernameTextField.text {
//      // trim any trailing whitespace for autocomplete
//      username = username.trimmingCharacters(in: .whitespaces)
//      // send the API request
//      sendAPIRequest(for: username)
//    }
//    return false
//  }
//}
//
