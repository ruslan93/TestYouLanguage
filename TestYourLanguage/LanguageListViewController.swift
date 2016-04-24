//
//  LanguageListViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/20/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import RealmSwift
import MGSwipeTableCell

protocol UpdateLanguagies : class{
    func update()
}

class LanguageListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate,  UpdateLanguagies {
    @IBOutlet weak var tableView: UITableView!
    var realm: Realm? = nil
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = try! Realm()
        if (NSUserDefaults.standardUserDefaults().valueForKey("login") != nil) {
            self.update()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (NSUserDefaults.standardUserDefaults().valueForKey("login") == nil) {
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        let selectedIndexPath = self.tableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.laguagies != nil {
            if let count = self.laguagies!.count as Int! {
                return count
            }
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LanguageTableViewCell") as! LanguageTableViewCell!
        let language = self.user!.languages[indexPath.row]
        cell.languageNameLabel.text = language.name
        cell.languageImageView.image = UIImage.init(named: "\(indexPath.row + 1)")
        cell.wordsCountLabel.text = "\(language.words.count)"
        if language.results.isEmpty {
            cell.lastResultLabel.text = "-"
            cell.lastResultLabel.textColor = UIColor.blackColor()
        } else {
            if language.results.last!.percent >= 50 {
                cell.lastResultLabel.textColor = UIColor.greenColor()
            } else {
                cell.lastResultLabel.textColor = UIColor.redColor()
            }
            cell.lastResultLabel.text = "\(language.results.last!.percent)%"
        }
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
        return 100.0
    }
    
     func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool{
        if index == 0{
            self.deleteLanguage(self.tableView.indexPathForCell(cell)!)
        } else {
            self.editLanguage(self.tableView.indexPathForCell(cell)!)
        }
        return true
    }
    
    // MARK: - UpdadeLanguagies
    
    func update() {
        let users = self.realm?.objects(User).filter("ID == %@", NSUserDefaults.standardUserDefaults().valueForKey("ID")!)
        if users != nil && !users!.isEmpty {
            self.laguagies = users![0].languages
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "loginSegue"{
            let loginVC = segue.destinationViewController as! LoginViewController
            loginVC.delegate = self
        }
        if segue.identifier! == "wordsSegue"{
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            if selectedIndexPath != nil {
                let newController = segue.destinationViewController as! WordListViewController
                newController.words = self.laguagies![selectedIndexPath!.row].words
            }
        }
    }
    
    // MARK: - Methods

    @IBAction func addLanguageBarButtonPressed(sender: AnyObject) {
        let alert = UIAlertController.init(title: "Добавить язык", message: "Введите название языка, который вы хотите добавить в свой список", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (nameTextField) in
            nameTextField.placeholder = "Название языка"
        }
        let addAction = UIAlertAction.init(title: "Добавить", style: .Default) { (action:UIAlertAction!) in
            let nameTextField = alert.textFields![0]
            guard let name = nameTextField.text where !name.isEmpty else{
                return
            }
            self.addLanguageToUser(name)
        }
        let cancelAction = UIAlertAction.init(title: "Отменить", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addLanguageToUser(name: String){
        let language = Language()
        language.name = name
        if self.user!.languages.isEmpty {
            language.ID = 0
        } else {
            let maxID = self.realm?.objects(Language).filter("owner == %@", self.user!).max("ID") as Int!
            language.ID = maxID + 1
        }
        language.owner = self.user!
        try! self.realm!.write({
            self.user!.languages.append(language)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath.init(forRow: self.user!.languages.count - 1, inSection: 0)], withRowAnimation: .Right)
        })
    }
    
    func deleteLanguage(indexPath: NSIndexPath){
        let selectedLanguage = self.user!.languages[indexPath.row]
        try! self.realm!.write({
            realm?.delete(selectedLanguage)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        })
    }
    
    func editLanguage(indexPath: NSIndexPath){
        let selectedLanguage = self.user!.languages[indexPath.row]
        let alert = UIAlertController.init(title: "Редактировать язык", message:nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (nameTextField) in
            nameTextField.placeholder = "Название языка"
            nameTextField.text = selectedLanguage.name
        }
        let editAction = UIAlertAction.init(title: "Сменить", style: .Default) { (action:UIAlertAction!) in
            let nameTextField = alert.textFields![0]
            guard let name = nameTextField.text where !name.isEmpty else{
                return
            }
            try! self.realm!.write({
                selectedLanguage.name = nameTextField.text!
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
            })
        }
        let cancelAction = UIAlertAction.init(title: "Отменить", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(editAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
