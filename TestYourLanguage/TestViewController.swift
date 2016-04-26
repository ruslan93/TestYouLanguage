//
//  TestViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/24/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import LTMorphingLabel
import RealmSwift
import IBAnimatable
import AVFoundation;

class TestViewController: UIViewController, AVSpeechSynthesizerDelegate {

    var realm: Realm = try! Realm()
    var random = 0
    var language: Language!
    var currentQuestion = 1
    var rightAnswer = 0
    var wordsList: [Word] = []
    
    var synthesizer = AVSpeechSynthesizer.init()
    
    var textToSpeech: AVSpeechUtterance {
        get {
//            return AVSpeechUtterance.init(string: self.wordsList[self.random].word)
            return AVSpeechUtterance.init(string: "how are you")

        }
    }
    
    var voice: AVSpeechSynthesisVoice {
        get {
            if self.language!.name == "English" {
                return AVSpeechSynthesisVoice.init(language: "en-EN")!
            }
            if self.language!.name == "Deutsch" {
                return AVSpeechSynthesisVoice.init(language: "de-DE")!
            }
            return AVSpeechSynthesisVoice.init(language: "en-EN")!
        }
    }

    
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var wordLabel: LTMorphingLabel!
    
    @IBOutlet var buttonsArray: [AnimatableButton]!
    
    @IBOutlet var reusultView: AnimatableView!

    @IBOutlet weak var answerResultView: AnimatableView!
    
    @IBOutlet weak var answerStatusLabel: UILabel!
    
    @IBOutlet weak var answerStatusImageView: UIImageView!
    
    @IBOutlet weak var answerWordLabel: UILabel!
    
    @IBOutlet weak var answerTranslatedWordLabel: UILabel!
    
    @IBOutlet weak var testResultView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reusultView.hidden = true
        self.wordLabel.morphingEffect = .Sparkle
        self.wordLabel.text = ""
        self.fillWordsList()
        self.synthesizer.delegate = self
    }
    
    func fillWordsList(){
        for _ in self.buttonsArray{
            let random = Int(arc4random_uniform(uint(self.language.words.count as Int!)))
            let word = self.language.words[random]
            if self.wordsList.isEmpty {
                self.wordsList.insert(word, atIndex: 0)
            } else {
                var isExist = false
                for existWord in self.wordsList {
                    if word == existWord {
                        isExist = true
                    }
                }
                if isExist == false {
                    self.wordsList.insert(word, atIndex: 0)
                }
            }
            if self.wordsList.count < 4 {
                self.fillWordsList()
            } else {
                self.fillButtonsInfo()
            }
        }
    }
    
    func fillButtonsInfo(){
        var index = 0
        for button in self.buttonsArray{
            button.fadeOutDown()
        }
        for button in self.buttonsArray{
            button.setTitle(self.wordsList[index].translatedWord, forState: .Normal)
            index = index + 1
        }
        let random = Int(arc4random_uniform(3))
        self.random = random
        for button in self.buttonsArray{
            button.fadeInUp()
        }
        self.wordLabel.text = self.wordsList[random].word
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closeTestButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func buttonPressed(sender: UIButton) {
        
        if sender.tag == self.random {
            self.rightAnswer = self.rightAnswer + 1
            self.answerStatusLabel.text = "Правильно"
            self.answerResultView.backgroundColor = UIColor(red: 0.000, green: 0.678, blue: 0.322, alpha: 1.00)
            self.answerStatusImageView.image = UIImage.init(named: "happy")
        } else {
            self.answerStatusLabel.text = "Неправильно"
            self.answerResultView.backgroundColor = UIColor(red: 0.875, green: 0.000, blue: 0.000, alpha: 1.00)
            self.answerStatusImageView.image = UIImage.init(named: "sad")
            try! self.realm.write({
                self.wordsList[self.random].falseAnswerCount = self.wordsList[self.random].falseAnswerCount + 1
            })
        }
        self.answerWordLabel.text = self.wordsList[self.random].word
        self.answerTranslatedWordLabel.text = self.wordsList[self.random].translatedWord
        self.showAnswerResult()
    }
    
    func showResult(){
        try! self.realm.write({
            let result = Result()
            result.date = NSDate.init()
            result.rightQuestion = self.rightAnswer
            result.totalQuestion = self.currentQuestion
            result.percent = (self.rightAnswer * 100) / self.currentQuestion
            self.language.results.append(result)
        })
        self.testResultView.hidden = false
        self.progressView.totalBall = 20
        self.progressView.setValue(CGFloat(self.rightAnswer)*100/CGFloat(self.currentQuestion), animateWithDuration: 3)
    }
    func showAnswerResult(){
        self.currentQuestion = self.currentQuestion + 1
        self.resultLabel.text = "\(self.currentQuestion)/20"
        self.reusultView.hidden = false
        self.answerResultView.hidden = false
    }
    
    @IBAction func continueButtonPressed(sender: AnyObject) {
        self.answerResultView.hidden = true
        if self.currentQuestion < 20 {
            self.reusultView.hidden = true
            self.wordsList = []
            self.fillWordsList()
        } else {
            self.showResult()
        }
    }
    
    @IBAction func slowSpeechTextButtonPressed(sender: AnyObject) {
        if self.synthesizer.speaking {
            return
        }
        let speech = AVSpeechSynthesizer.init()
        speech.delegate = self
        let textToSpeech = AVSpeechUtterance.init(string: self.wordLabel.text)
        textToSpeech.voice = self.voice
        textToSpeech.rate = 0.2
        speech.speakUtterance(textToSpeech)
    }
    
    @IBAction func speechTextButtonPressed(sender: AnyObject) {
        if self.synthesizer.speaking {
            return
        }
        let speech = AVSpeechSynthesizer.init()
        speech.delegate = self
        let textToSpeech = AVSpeechUtterance.init(string: self.wordLabel.text)
        textToSpeech.voice = self.voice
        textToSpeech.rate = 0.5
        speech.speakUtterance(textToSpeech)

    }
}
