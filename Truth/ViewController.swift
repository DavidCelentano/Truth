//
//  ViewController.swift
//  Truth
//
//  Created by David Celentano on 10/5/17.
//  Copyright © 2017 David Celentano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    let api = BungieAPIService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGradient()
        print(view.layer.sublayers?.count)
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
        if let username = usernameTextField.text {
            api.fetchAccountId(for: username)
        }
        // TODO else return feedback to enter a username
    }
    
}

