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
import IBAnimatable
import AVFoundation;

class LanguageListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (NSUserDefaults.standardUserDefaults().valueForKey("login") == nil) {
            self.performSegueWithIdentifier("loginSegue", sender: self)
        } else {
            self.update()
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
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
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
        if segue.identifier! == "wordsSegue"{
            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            if selectedIndexPath != nil {
                let newController = segue.destinationViewController as! WordListViewController
                newController.words = self.laguagies![selectedIndexPath!.row].words
            }
        }
    }
}
