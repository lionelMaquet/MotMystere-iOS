//
//  GameViewController.swift
//  MotMystere
//
//  Created by Lionel Maquet on 20/07/2020.
//  Copyright © 2020 Lionel Maquet. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import UITextField_Shake_Swift_

class GameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var reaminingTimeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var textfieldsStack: UIStackView!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var hiddenTextField: UITextField!
    
    
    var delegate: GameViewControllerDelegate?
    var difficulty: String?
    var currentQuestionIndex: Int = 0
    var remainingTime = GameOptions.totalTimeForOneGame
    var currentQuestionTimer = 0
    var currentScore = 0
    
    
    
    
    var wordsUnfound:[String] = []
    
    var player: AVAudioPlayer?
    
    var listOfQuestions: [[String]] {
        if difficulty == "easy" {
            return ListOfQuestions.easyWords
        }
        
        else if difficulty == "medium" {
            return ListOfQuestions.mediumWords
        }
        
        else if difficulty == "hard" {
            return ListOfQuestions.hardWords
        }
        
        else if difficulty == "expert" {
            return ListOfQuestions.expertWords
        }
            
        else {
            return [["",""]]
        }
        
    }
    
    var shuffledListOfQuestions : [[String]]?
    var currentQuestion:[String]{
        return shuffledListOfQuestions![currentQuestionIndex]
    }
    
    var currentDefinition:String{
        return currentQuestion[0]
    }
    
    var currentWord:String {
        return currentQuestion[1]
    }
    
    var currentWordNumberOfLetters: Int {
        return currentWord.count
    }
    
    var textfields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shuffledListOfQuestions = listOfQuestions.shuffled()
        displayQuestion()
        reaminingTimeLabel.text = "\(GameOptions.totalTimeForOneGame)sec"
        
        // MIGHT BE DELETED
        addIndice()
        addIndice()
        
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.updateRemainingTime()
            if self.remainingTime == 0 {
                timer.invalidate()
                self.performSegue(withIdentifier: "GoToFinalScore", sender: self)
            }
            
            if self.remainingTime <= 5 {
                
                self.playClockTic()
            }
            
            self.updateCurrentQuestionTimer()
        }
    }
    
    
    @IBAction func passerButtonPressed(_ sender: UIButton) {
        wordsUnfound.append(currentWord)
        hiddenTextField.text = ""
        currentQuestionIndex += 1
        currentScore -= GameOptions.pointsLostForPassing
        currentQuestionTimer = 0
        updateScore()
        displayQuestion()
        addIndice()
        addIndice()
    }
    
    func updateCurrentQuestionTimer(){
        currentQuestionTimer += 1
        if currentQuestionTimer % GameOptions.timeBetweenIndices == 0 {
            self.addIndice()
        }
    }
    
    func addIndice(){
        
        var numberOfPlaceholders = 0
        
        for textfield in textfields {
            if textfield.placeholder != nil {
                numberOfPlaceholders += 1
            }
        }
        
        if numberOfPlaceholders < currentWordNumberOfLetters - GameOptions.minNumberOfLettersToGuess {
            
            var randomPosition = Int.random(in: 0...textfields.count - 1)
            while textfields[randomPosition].placeholder != nil {
                randomPosition = Int.random(in: 0...textfields.count - 1)
            }
            textfields[randomPosition].attributedPlaceholder = NSAttributedString(string: currentWord[randomPosition].uppercased(),
                                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(named: "indiceColor")!])
        }
    }
    
    func updateRemainingTime(){
        remainingTime -= 1
        reaminingTimeLabel.text = "\(remainingTime)sec"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hiddenTextField.becomeFirstResponder()
        hiddenTextField.isHidden = true
    }
    
    
    
    @IBAction func userPressedLetter(_ sender: UITextField) {
        
        for (index, _) in textfields.enumerated() {
            if index <= hiddenTextField.text!.count - 1 {
                let currentText = hiddenTextField.text
                textfields[index].text = currentText![index].uppercased()
            }
            
            else {
                textfields[index].text = ""
            }
        }
        
        if hiddenTextField.text!.count == textfields.count {
            checkForAnswerValidation()
        }
          
    }
    
    func numberOfFoundLetters() -> Int {
        var i = 0
        for tf in textfields {
            if tf.placeholder == nil {
                i += 1
            }
        }
        return i
    }
    
    func checkForAnswerValidation(){
        var guess = ""
        let currentWordWithoutAccents = currentWord.folding(options: .diacriticInsensitive, locale: .current)
        
        
        for tf in textfields {
            guess += tf.text!.lowercased()
        }
        
        if guess == currentWord || guess == currentWordWithoutAccents || guess == currentWord.lowercased() || guess == currentWordWithoutAccents.lowercased() {
            print("RIGHT")
            playSound()
            currentScore += numberOfFoundLetters()
            hiddenTextField.text = ""
            currentQuestionIndex += 1
            currentQuestionTimer = 0
            updateScore()
            displayQuestion()
            
            // MIGHT BE DELETED
            addIndice()
            addIndice()
        }
        
        else {
            print("WRONG")
            shakeAllTextFields()
            hiddenTextField.text = ""
            for tf in textfields {
                tf.text = ""
            }
        }
    }
    
    func shakeAllTextFields(){
        for tf in textfields {
            tf.shake(times: 3, delta: 5, speed: 0.05)
        }
    }
    
    func updateScore(){
        scoreLabel.text = "\(currentScore)"
    }
    
    func displayQuestion(){
        populateArrayOfTextfields(numberOfTf: currentWordNumberOfLetters)
        displayTextFields()
        definitionLabel.text = currentDefinition
    }
    
    func getGlobalScoreUpdate() -> Int {
        
        var score = 0
        
        switch difficulty {
        case "easy":
            score = (currentScore / 10)
        case "medium":
            score = (currentScore / 5)
            
        case "hard":
            score = (currentScore / 3)
            
        case "expert" :
            score = (currentScore / 2)
            
        default:
            score = 0
        }
        
        print("score = \(score)")
        return score
        
        
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "correctSoundMotMystere", withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playClockTic() {
       
        let data = NSDataAsset(name: "clock_tick")!.data

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.wav.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}




extension GameViewController {
    // For all things related to textfields
    
    func createTextfield() -> UITextField {
    
        
        let sampleTextField =  UITextField(frame: CGRect(x: 10.0, y: 1.0, width: 20.0, height: 20.0))
        sampleTextField.font = UIFont.systemFont(ofSize: 16)
        sampleTextField.textAlignment = .center
        sampleTextField.borderStyle = .none
        sampleTextField.textColor = UIColor.init(named: "textColor")
        sampleTextField.backgroundColor = UIColor.init(named: "tileColor")
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        sampleTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        sampleTextField.delegate = self
        let widthConstraint = NSLayoutConstraint(item: sampleTextField, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 28)
        let heightConstraint = NSLayoutConstraint(item: sampleTextField, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 28)
        sampleTextField.addConstraints([widthConstraint, heightConstraint])
        return sampleTextField
        
        
    }
    
    func populateArrayOfTextfields(numberOfTf:Int){
        textfields = []
        
        for _ in 1...numberOfTf {
            
            textfields.append(createTextfield())

        }
    }
    
    func displayTextFields(){
        for view in self.textfieldsStack.subviews {
            view.removeFromSuperview()
        }
       
        for tf in self.textfields {
            self.textfieldsStack.addArrangedSubview(tf)
        }
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FinalScoreViewController
        destinationVC.finalScore = currentScore
        destinationVC.wordsUnfound = wordsUnfound
        destinationVC.globalScoreUpdate = getGlobalScoreUpdate()
    }
}


extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}


protocol GameViewControllerDelegate {
    func updateRank()
}
