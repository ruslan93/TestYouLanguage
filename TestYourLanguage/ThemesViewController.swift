//
//  ThemesViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/27/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import RealmSwift
import MGSwipeTableCell

class ThemesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var themesTableView: UITableView!
    
    var realm: Realm? = nil
    
    var language: Language!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = try! Realm()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        let selectedIndexPath = self.themesTableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            self.themesTableView.deselectRowAtIndexPath(selectedIndexPath!, animated: false)
        }
        self.themesTableView.reloadData()
    }

    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.language.themes.isEmpty{
            return 1
        } else {
            return self.language.themes.count + 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ThemeTableViewCell") as! ThemeTableViewCell!
        if indexPath.row == 0 {
            cell.themeNameLabel!.text = "Все слова"
            cell.startTestButton.enabled = self.language.words.count > 4
        } else {
            cell.themeNameLabel!.text = self.language.themes[indexPath.row-1].name
            cell.startTestButton.enabled = self.language.themes[indexPath.row-1].words.count > 4
        }
        cell.startTestButton.tag = indexPath.row
        if indexPath.row != 0 {
            cell.rightButtons = [MGSwipeButton(title: NSLocalizedString("delete", comment: ""), backgroundColor: UIColor.redColor())
                ,MGSwipeButton(title:  NSLocalizedString("edit", comment: ""), backgroundColor: UIColor.lightGrayColor())]
            cell.rightSwipeSettings.transition = MGSwipeTransition.ClipCenter
            let expansionSettings = MGSwipeExpansionSettings()
            expansionSettings.buttonIndex = 0
            expansionSettings.fillOnTrigger = false;
            cell.rightExpansion = expansionSettings
            cell.delegate = self
        }
        cell.backgroundColor = UIColor.clearColor()
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
            self.deleteTheme(self.themesTableView.indexPathForCell(cell)!)
        } else {
            self.editTheme(self.themesTableView.indexPathForCell(cell)!)
        }
        return true
    }
    
    //MARK: - Actions
    
    
    @IBAction func startTestButtonPressed(sender: UIButton) {
        let testController = self.storyboard?.instantiateViewControllerWithIdentifier("TestViewController") as! TestViewController
        testController.language = self.language
        if sender.tag != 0 {
            testController.isTheme = true
            testController.theme = self.language.themes[sender.tag-1]
        }
        testController.modalTransitionStyle = .CrossDissolve
        self.presentViewController(testController, animated: true, completion: nil)
    }
    
    @IBAction func addThemeBarButtonPressed(sender: AnyObject) {
        let alert = UIAlertController.init(title: NSLocalizedString("addNewThemeTitle", comment: ""), message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (themeTextField) in
            themeTextField.placeholder = NSLocalizedString("theme", comment: "")
        }
        let addAction = UIAlertAction.init(title: NSLocalizedString("add", comment: ""), style: .Default) { (action:UIAlertAction!) in
            let themeTextField = alert.textFields![0]
            guard let name = themeTextField.text where !name.isEmpty else{
                return
            }
            self.addThemeToLanguage(name)
        }
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    
    func addThemeToLanguage(name: String){
        let theme = Theme()
        theme.name = name
        theme.owner = self.language
        try! self.realm!.write({
            self.language!.themes.append(theme)
            self.themesTableView.insertRowsAtIndexPaths([NSIndexPath.init(forRow: self.language!.themes.count, inSection: 0)], withRowAnimation: .Right)
        })
    }
    
    func deleteTheme(indexPath: NSIndexPath){
        let selectedTheme = self.language!.themes[indexPath.row - 1]
        try! self.realm!.write({
            realm?.delete(selectedTheme)
            self.themesTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        })
    }
    
    func editTheme(indexPath: NSIndexPath){
        let selectedTheme = self.language!.themes[indexPath.row - 1]
        let alert = UIAlertController.init(title: NSLocalizedString("edit", comment: ""), message:nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (themeTextField) in
            themeTextField.placeholder = "Тема"
            themeTextField.text = selectedTheme.name
        }
        let editAction = UIAlertAction.init(title: NSLocalizedString("save", comment: ""), style: .Default) { (action:UIAlertAction!) in
            let themeTextField = alert.textFields![0]
            guard let name = themeTextField.text where !name.isEmpty else{
                return
            }
            try! self.realm!.write({
                selectedTheme.name = name
                self.themesTableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: indexPath.row - 1, inSection: 0)], withRowAnimation: .Right)
            })
        }
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(editAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "wordsSegue"{
            let selectedIndexPath = self.themesTableView.indexPathForSelectedRow
            if selectedIndexPath != nil {
                if selectedIndexPath?.row == 0{
                    let newController = segue.destinationViewController as! WordListViewController
                    newController.language = self.language
                } else {
                    let newController = segue.destinationViewController as! WordListViewController
                    newController.language = self.language
                    newController.isTheme = true
                    newController.theme = self.language.themes[selectedIndexPath!.row - 1]
                }
            }
            
//            if segue.identifier == "runTestSegue" {
//                let testController = segue.destinationViewController as! TestViewController
//                testController.language = self.languages[self.selectedLanguageIndexPath!.row]
//            }

        }
    }
}
