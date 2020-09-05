//
//  FinalScoreViewController.swift
//  MotMystere
//
//  Created by Lionel Maquet on 20/07/2020.
//  Copyright © 2020 Lionel Maquet. All rights reserved.
//

import UIKit

class FinalScoreViewController: UIViewController {
    
    var userManager = UserManager()
    @IBOutlet weak var globalScoreUpdateLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    var finalScore: Int?
    var wordsUnfound:[String] = []
    @IBOutlet weak var wordsUnfoundTitleLabel: UILabel!
    
    @IBOutlet weak var finalScoreLabel: UILabel!
    
    @IBOutlet weak var wordsUnfoundStack: UIStackView!
    private var presentingController: UIViewController?
    
    var globalScoreUpdate:Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        finalScoreLabel.text = "Votre score final est de \(finalScore!)"
        
        if wordsUnfound.count > 0 {
            wordsUnfoundTitleLabel.text = "Voici les mots que vous n'avez pas trouvés :"
        } else {
            wordsUnfoundTitleLabel.text = ""
        }
        
        for word in wordsUnfound {
            createLabel(word: word)
            
        }
        
        if globalScoreUpdate! > 0 {
            globalScoreUpdateLabel.text = "Rang global : +\(globalScoreUpdate!)points"
        }
        
        else if globalScoreUpdate! == 0 {
            globalScoreUpdateLabel.text = "Votre rang global ne change pas."
        }
        
        else if globalScoreUpdate! < 0 {
            globalScoreUpdateLabel.text = "Rang global : \(globalScoreUpdate!)points"
        }
        
        userManager.updateGlobalRank(by: globalScoreUpdate!)
        
        
        
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentingController = presentingViewController
        
        
        
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        

        self.dismiss(animated: false, completion: {
            let vc = self.presentingController as! GameViewController
            vc.delegate?.updateRank()
            self.presentingController?.dismiss(animated: true, completion: {
                
            })
        })
        
        
        
    }
    
    func createLabel(word:String){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = word

        self.wordsUnfoundStack.addArrangedSubview(label)
    }
    
}

extension UINavigationController {

  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
      popToViewController(vc, animated: animated)
    }
  }

  func popViewControllers(viewsToPop: Int, animated: Bool = true) {
    if viewControllers.count > viewsToPop {
      let vc = viewControllers[viewControllers.count - viewsToPop - 1]
      popToViewController(vc, animated: animated)
    }
  }

}
