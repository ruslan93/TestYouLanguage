//
//  WordListViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/21/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import RealmSwift
import MGSwipeTableCell

class WordListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
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
        cell.rightButtons = [MGSwipeButton(title: "Удалить", backgroundColor: UIColor.redColor())
            ,MGSwipeButton(title: "Изменить",backgroundColor: UIColor.lightGrayColor())]
        cell.rightSwipeSettings.transition = MGSwipeTransition.ClipCenter
        let expansionSettings = MGSwipeExpansionSettings()
        expansionSettings.buttonIndex = 0
        expansionSettings.fillOnTrigger = false;
        cell.rightExpansion = expansionSettings
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool{
        if index == 0{
            self.deleteWord(self.tableView.indexPathForCell(cell)!)
        } else {
            self.editWord(self.tableView.indexPathForCell(cell)!)
        }
        return true
    }
    
    //MARK: - Actions
    
    @IBAction func addLanguageBarButtonPressed(sender: AnyObject) {
        let alert = UIAlertController.init(title: "Добавить новое слово", message: "Введите слово и его перевод", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (wordTextField) in
            wordTextField.placeholder = "Слово"
        }
        alert.addTextFieldWithConfigurationHandler { (translatedTextField) in
            translatedTextField.placeholder = "Перевод"
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

    //MARK: - Actions

    func addWordToLanguage(word: String, translatedWord: String){
        let newWord = Word()
        newWord.word = word
        newWord.translatedWord = translatedWord
        if self.words!.isEmpty {
            newWord.ID = 0
        } else {
            newWord.ID = (self.words!.max("ID") as Int!)+1
        }
        try! self.realm!.write({
            self.words?.append(newWord)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath.init(forRow: self.words!.count - 1, inSection: 0)], withRowAnimation: .Right)
        })
    }

    func deleteWord(indexPath: NSIndexPath){
        let selectedWord = self.words![indexPath.row]
        try! self.realm!.write({
            realm?.delete(selectedWord)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        })
    }
    
    func editWord(indexPath: NSIndexPath){
        let selectedWord = self.words![indexPath.row]
        let alert = UIAlertController.init(title: "Редактировать слово", message:nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (wordTextField) in
            wordTextField.placeholder = "Слово"
            wordTextField.text = selectedWord.word
        }
        alert.addTextFieldWithConfigurationHandler { (translatedTextField) in
            translatedTextField.placeholder = "Перевод"
            translatedTextField.text = selectedWord.translatedWord
        }

        let editAction = UIAlertAction.init(title: "Сохранить", style: .Default) { (action:UIAlertAction!) in
            let wordTextField = alert.textFields![0]
            let translatedTextField = alert.textFields![1]
            guard let name = wordTextField.text where !name.isEmpty else{
                return
            }
            guard let name2 = translatedTextField.text where !name2.isEmpty else{
                return
            }
            try! self.realm!.write({
                selectedWord.word = wordTextField.text!
                selectedWord.translatedWord = translatedTextField.text!
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
            })
        }
        let cancelAction = UIAlertAction.init(title: "Отменить", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(editAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
