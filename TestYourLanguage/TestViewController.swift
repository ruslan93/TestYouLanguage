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

class TestViewController: UIViewController {

    var realm: Realm = try! Realm()
    var random = 0
    var language: Language!
    var currentQuestion = 1
    var rightAnswer = 0
    var wordsList: [Word] = []
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var wordLabel: LTMorphingLabel!
    @IBOutlet var buttonsArray: [AnimatableButton]!
    @IBOutlet var reusultView: AnimatableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reusultView.hidden = true
        self.wordLabel.morphingEffect = .Sparkle
        self.wordLabel.text = ""
        self.fillWordsList()
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
        } else {
            try! self.realm.write({
                self.wordsList[self.random].falseAnswerCount = self.wordsList[self.random].falseAnswerCount + 1
            })
        }
        if self.currentQuestion < 20 {
            self.currentQuestion = self.currentQuestion + 1
            self.resultLabel.text = "\(self.currentQuestion)/20"
            self.wordsList = []
            self.fillWordsList()
        } else {
            self.showResult()
        }
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
        self.reusultView.hidden = false
        self.progressView.totalBall = 20
        self.progressView.setValue(CGFloat(self.rightAnswer)*100/CGFloat(self.currentQuestion), animateWithDuration: 3)
    }
}
