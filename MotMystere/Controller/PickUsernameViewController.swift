//
//  PickUsernameViewController.swift
//  MotMystere
//
//  Created by Lionel Maquet on 19/07/2020.
//  Copyright © 2020 Lionel Maquet. All rights reserved.
//

import UIKit

class PickUsernameViewController: UIViewController {
    
    let userManager = UserManager()

    @IBOutlet weak var usernameLabel: UITextField!
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated: true);
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func validateUsernameButtonTapped(_ sender: UIButton) {
        userManager.createUserCustomDbEntry(username: usernameLabel.text!)
    }
}
