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

class TestViewController: UIViewController {

    var realm: Realm? = nil
    var random = 0
    var currentQuestion = 1
    var rightAnswer = 0
    var laguagies: List<Language>? = nil
    var user: User? {
        get {
            let users = self.realm!.objects(User).filter("ID == %@", NSUserDefaults.standardUserDefaults().valueForKey("ID")!)
            if users.isEmpty {
                return nil
            } else {
                return users[0]
            }
        }
    }
    var wordsList: [Word] = []
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var wordLabel: LTMorphingLabel!
    @IBOutlet var buttonsArray: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wordLabel.morphingEffect = .Sparkle
        self.realm = try! Realm()
        self.wordLabel.text = ""
        self.fillWordsList()
        // Do any additional setup after loading the view.
    }
    
    func fillWordsList(){
        for _ in self.buttonsArray{
            let random = Int(arc4random_uniform(uint(self.user!.languages[0].words.count as Int!)))
            let word = self.user!.languages[0].words[random]
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
            button.setTitle(self.wordsList[index].translatedWord, forState: .Normal)
            index = index + 1
        }
        let random = Int(arc4random_uniform(3))
        self.random = random
        self.wordLabel.text = self.wordsList[random].word
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeTestButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func buttonPressed(sender: UIButton) {
//        if sender.tag == 0 {
//            self.wordLabel.text = "Appel"
//        }
//        if sender.tag == 1 {
//            self.wordLabel.text = "HTC"
//        }
//        if sender.tag == 2 {
//            self.wordLabel.text = "Samsung"
//        }
//        if sender.tag == 3 {
//            self.wordLabel.text = "Android"
//        }
        if sender.tag == self.random {
            self.rightAnswer = self.rightAnswer + 1
            print("yes")
        } else {
            print("no")
        }
        self.currentQuestion = self.currentQuestion + 1
        self.resultLabel.text = "\(self.currentQuestion)/20"
        self.wordsList = []
        self.fillWordsList()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
