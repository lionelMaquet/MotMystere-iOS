//
//  PickLevelViewController.swift
//  MotMystere
//
//  Created by Lionel Maquet on 20/07/2020.
//  Copyright © 2020 Lionel Maquet. All rights reserved.
//

import UIKit
import Firebase

class PickLevelViewController: UIViewController {

    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var userManager = UserManager()
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var expertButton: UIButton!
    
    
    
    var chosenDifficulty: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        userManager.delegate = self
        
        
        
        let buttonsCornerRadius = CGFloat(20)
        easyButton.layer.cornerRadius = buttonsCornerRadius
        mediumButton.layer.cornerRadius = buttonsCornerRadius
        hardButton.layer.cornerRadius = buttonsCornerRadius
        expertButton.layer.cornerRadius = buttonsCornerRadius
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("hey")
        userManager.loadCurrentUserUsernameAndNotifyDelegate()
        userManager.getCurrentUserRank()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    @IBAction func easyDifficultyPicked(_ sender: UIButton) {
        chosenDifficulty = "easy"
        self.performSegue(withIdentifier: "GoToGame", sender: self)
    }
    
    @IBAction func mediumDifficultyPicked(_ sender: UIButton) {
        chosenDifficulty = "medium"
        self.performSegue(withIdentifier: "GoToGame", sender: self)
    }
    
    @IBAction func hardDifficultyPicked(_ sender: UIButton) {
        chosenDifficulty = "hard"
        self.performSegue(withIdentifier: "GoToGame", sender: self)
    }
    @IBAction func expertDifficultyPicked(_ sender: UIButton) {
        chosenDifficulty = "expert"
        self.performSegue(withIdentifier: "GoToGame", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! GameViewController
        destinationVC.delegate = self
        destinationVC.difficulty = chosenDifficulty
    }
}


extension PickLevelViewController: UserManagerDelegate {
    func userRankWasLoaded(rank: Int) {
        rankLabel.text = "Points : \(rank)"
        print("rank of the user is \(rank)")
    }
    
    func currentUserUsernameWasLoaded(username: String) {
        nameLabel.text = username
    }
    
}

extension PickLevelViewController : GameViewControllerDelegate{
    func updateRank(){
        userManager.getCurrentUserRank()
    }
}

