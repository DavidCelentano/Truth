//
//  InfoViewController.swift
//  Truth
//
//  Created by dcelentano on 11/9/17.
//  Copyright © 2017 David Celentano. All rights reserved.
//

import UIKit
import SnapKit

enum Stat {
    case subclass
    case primary
    case special
    case heavy
    case lightLevel
    case overallKD
    case overallKDA
    case overallWinLoss
    case overallCombatRating
    case timePlayed
}

protocol InfoViewControllerDelegate: class {
    func setEnabled(to bool: Bool, for stat: Stat)
}

class InfoViewController: UIViewController {
    
    // MARK: Properties
    
    var delegate: InfoViewControllerDelegate?
    
    // used to properly layout views on all devices (including iPhone X)
    @IBOutlet weak var topBumperView: UIView!
    
    private var dismissButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        b.tintColor = .white
        b.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        return b
    }()
    
    private var subclassLabel = UILabel.whiteLabel()
    private var subclassButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "subclassEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(subclassTapped), for: .touchUpInside)
        return b
    }()

    private var primaryLabel = UILabel.whiteLabel()
    private var primaryButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "primaryEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        return b
    }()
    
    private var specialLabel = UILabel.whiteLabel()
    private var specialButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "specialEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(specialTapped), for: .touchUpInside)
        return b
    }()
    
    private var heavyLabel = UILabel.whiteLabel()
    private var heavyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "heavyEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(heavyTapped), for: .touchUpInside)
        return b
    }()
    
    private var lightLevelLabel = UILabel.whiteLabel()
    private var lightLevelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "lightLevelEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(lightLevelTapped), for: .touchUpInside)
        return b
    }()
    
    private var overallKDLabel = UILabel.whiteLabel()
    private var overallKDButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "overallKDEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(overallKDTapped), for: .touchUpInside)
        return b
    }()
    
    private var overallKDALabel = UILabel.whiteLabel()
    private var overallKDAButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "overallKDAEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(overallKDATapped), for: .touchUpInside)
        return b
    }()
    
    private var overallWinLossLabel = UILabel.whiteLabel()
    private var overallWinLossButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "overallWinLossEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(overallWinLossTapped), for: .touchUpInside)
        return b
    }()
    
    private var overallCombatRatingLabel = UILabel.whiteLabel()
    private var overallCombatRatingButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "overallCombatRatingEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(overallCombatRatingTapped), for: .touchUpInside)
        return b
    }()
    
    private var timePlayedLabel = UILabel.whiteLabel()
    private var timePlayedButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "InfoIcon"), for: .normal) //TODO change icon
        let bool = UserDefaults.standard.value(forKey: "timePlayedEnabled") as? Bool ?? true
        b.tintColor = bool ? .green : .red
        b.addTarget(self, action: #selector(timePlayedTapped), for: .touchUpInside)
        return b
    }()
    
    
    // MARK: View Setup
    
    override func viewDidLoad() {
        setUpGradient()
        
        // set label text
        subclassLabel.text = "Class | Subclass: (Destiny 1 only shows subclass)"
        primaryLabel.text = "Primary Weapon"
        specialLabel.text = "Special Weapon"
        heavyLabel.text = "Heavy Weapon"
        lightLevelLabel.text = "Light Level"
        overallKDLabel.text = "Kills / Deaths ratio for all characters"
        overallKDALabel.text = "Kills + [Assists / 2] / Deaths ratio for all characters"
        overallWinLossLabel.text = "Wins / Losses ratio for all characters"
        overallCombatRatingLabel.text = "Combat Rating is an assessment of skill" //TODO
        timePlayedLabel.text = "Hours played on current character"
        
        // button sizing
        subclassButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        primaryButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        specialButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        heavyButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        lightLevelButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        overallKDButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        overallKDAButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        overallWinLossButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        overallCombatRatingButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        timePlayedButton.snp.makeConstraints { make in
            make.size.equalTo(34)
        }
        
        // setup stack views
        let subclassStackView = UIStackView(arrangedSubviews: [subclassButton, subclassLabel])
        subclassStackView.alignment = .center
        subclassStackView.axis = .horizontal
        subclassStackView.spacing = 15
        
        let primaryStackView = UIStackView(arrangedSubviews: [primaryButton, primaryLabel])
        primaryStackView.alignment = .center
        primaryStackView.axis = .horizontal
        primaryStackView.spacing = 15
        
        let specialStackView = UIStackView(arrangedSubviews: [specialButton, specialLabel])
        specialStackView.alignment = .center
        specialStackView.axis = .horizontal
        specialStackView.spacing = 15
        
        let heavyStackView = UIStackView(arrangedSubviews: [heavyButton, heavyLabel])
        heavyStackView.alignment = .center
        heavyStackView.axis = .horizontal
        heavyStackView.spacing = 15
        
        let lightLevelStackView = UIStackView(arrangedSubviews: [lightLevelButton, lightLevelLabel])
        lightLevelStackView.alignment = .center
        lightLevelStackView.axis = .horizontal
        lightLevelStackView.spacing = 15
        
        let overallKDStackView = UIStackView(arrangedSubviews: [overallKDButton, overallKDLabel])
        overallKDStackView.alignment = .center
        overallKDStackView.axis = .horizontal
        overallKDStackView.spacing = 15
        
        let overallKDAStackView = UIStackView(arrangedSubviews: [overallKDAButton, overallKDALabel])
        overallKDAStackView.alignment = .center
        overallKDAStackView.axis = .horizontal
        overallKDAStackView.spacing = 15
        
        let overallWinLossStackView = UIStackView(arrangedSubviews: [overallWinLossButton, overallWinLossLabel])
        overallWinLossStackView.alignment = .center
        overallWinLossStackView.axis = .horizontal
        overallWinLossStackView.spacing = 15
        
        let overallCombatRatingStackView = UIStackView(arrangedSubviews: [overallCombatRatingButton, overallCombatRatingLabel])
        overallCombatRatingStackView.alignment = .center
        overallCombatRatingStackView.axis = .horizontal
        overallCombatRatingStackView.spacing = 15
        
        let timePlayedStackView = UIStackView(arrangedSubviews: [timePlayedButton, timePlayedLabel])
        timePlayedStackView.alignment = .center
        timePlayedStackView.axis = .horizontal
        timePlayedStackView.spacing = 15
        
        
        
        let statsStackView = UIStackView(arrangedSubviews: [subclassStackView, primaryStackView, specialStackView, heavyStackView, lightLevelStackView, overallKDStackView, overallKDAStackView, overallWinLossStackView, overallCombatRatingStackView, timePlayedStackView])
        statsStackView.alignment = .fill
        statsStackView.axis = .vertical
        statsStackView.spacing = 15
        statsStackView.distribution = .equalSpacing
        
        // constraints
        view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(topBumperView).offset(15)
            make.leading.equalTo(view).offset(15)
            make.size.equalTo(34)
        }
        
        view.addSubview(statsStackView)
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(15)
            make.trailing.equalTo(view).offset(-15)
        }
        
        
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
    
    // set status bar to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Button Actions
    @objc private func dismissTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func subclassTapped() {
        let bool = UserDefaults.standard.value(forKey: "subclassEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .subclass)
        subclassButton.tintColor = bool ? .red : .green
    }
    @objc private func primaryTapped() {
        let bool = UserDefaults.standard.value(forKey: "primaryEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .primary)
        primaryButton.tintColor = bool ? .red : .green
    }
    @objc private func specialTapped() {
        let bool = UserDefaults.standard.value(forKey: "specialEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .special)
        specialButton.tintColor = bool ? .red : .green
    }
    @objc private func heavyTapped() {
        let bool = UserDefaults.standard.value(forKey: "heavyEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .heavy)
        heavyButton.tintColor = bool ? .red : .green
    }
    @objc private func lightLevelTapped() {
        let bool = UserDefaults.standard.value(forKey: "lightLevelEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .lightLevel)
        lightLevelButton.tintColor = bool ? .red : .green
    }
    @objc private func overallKDTapped() {
        let bool = UserDefaults.standard.value(forKey: "overallKDEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .overallKD)
        overallKDButton.tintColor = bool ? .red : .green
    }
    @objc private func overallKDATapped() {
        let bool = UserDefaults.standard.value(forKey: "overallKDAEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .overallKDA)
        overallKDAButton.tintColor = bool ? .red : .green
    }
    @objc private func overallWinLossTapped() {
        let bool = UserDefaults.standard.value(forKey: "overallWinLossEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .overallWinLoss)
        overallWinLossButton.tintColor = bool ? .red : .green
    }
    @objc private func overallCombatRatingTapped() {
        let bool = UserDefaults.standard.value(forKey: "overallCombatRatingEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .overallCombatRating)
        overallCombatRatingButton.tintColor = bool ? .red : .green
    }
    @objc private func timePlayedTapped() {
        let bool = UserDefaults.standard.value(forKey: "timePlayedEnabled") as? Bool ?? false
        delegate?.setEnabled(to: !bool, for: .timePlayed)
        timePlayedButton.tintColor = bool ? .red : .green
    }
}
