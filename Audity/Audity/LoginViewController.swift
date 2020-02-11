//
//  LoginViewController.swift
//  Audity
//
//  Created by Julia Zamaitat on 06.09.19.
//  Copyright © 2019 Julia Zamaitat. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.connect()
    }
    
    
}

