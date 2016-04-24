//
//  WordListViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/21/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import RealmSwift

class WordListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var words: List<Word>?
    @IBOutlet weak var tableView: UITableView!
    var realm: Realm? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = try! Realm()
        let result = Result()
        result.rightQuestion = 10
        result.percent = 50
        result.totalQuestion = 20
        result.date = NSDate.init()
        let user = self.realm?.objects(User)[0]
        let results = self.realm?.objects(Result)
        print(results)
        try! self.realm!.write({
//            user!.languages[1].results.append(result)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.words!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WordTableViewCell") as! WordTableViewCell!
        let word = self.words![indexPath.row]
        cell.wordLabel.text = word.word
        cell.translatedWordLabel.text = word.translatedWord
        cell.wordNumber.text = "\(indexPath.row + 1)"
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

    @IBAction func addLanguageBarButtonPressed(sender: AnyObject) {
        let alert = UIAlertController.init(title: "Добавить новое слово", message: "Введите название языка, который вы хотите добавить в свой список", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (wordTextField) in
            wordTextField.placeholder = "Название языка"
        }
        alert.addTextFieldWithConfigurationHandler { (translatedTextField) in
            translatedTextField.placeholder = "Название языка"
        }
        let addAction = UIAlertAction.init(title: "Добавить", style: .Default) { (action:UIAlertAction!) in
            let wordTextField = alert.textFields![0]
            let translatedTextField = alert.textFields![1]
            guard let name = wordTextField.text where !name.isEmpty else{
                return
            }
            guard let name2 = translatedTextField.text where !name2.isEmpty else{
                return
            }
            self.addWordToLanguage(name, translatedWord: name2)
        }
        let cancelAction = UIAlertAction.init(title: "Отменить", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func addWordToLanguage(word: String, translatedWord: String){
        let newWord = Word()
        newWord.word = word
        newWord.translatedWord = translatedWord
        newWord.ID = 0
//        if self.user == nil{
//            print("nil")
//        } else {
//            print(self.user!)
//        }
//        if self.user!.languages.isEmpty {
//            language.ID = 0
//        } else {
//            let maxID = self.realm?.objects(Language).filter("owner == %@", self.user!).max("ID") as Int!
//            language.ID = maxID + 1
//        }
//        language.owner = self.user!
        try! self.realm!.write({
            self.words?.append(newWord)
//            self.user!.languages.append(language)
        })
        self.tableView.reloadData()
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
