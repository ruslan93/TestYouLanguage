//
//  TestSettingViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/24/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import IBAnimatable
import RealmSwift

class TestSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var languagesTableView: UITableView!
    @IBOutlet weak var startTestButton: AnimatableButton!
    var realm: Realm? = nil
    var user: User?{
        get {
            let users = self.realm!.objects(User).filter("ID == %@", NSUserDefaults.standardUserDefaults().valueForKey("ID")!)
            if users.isEmpty {
                return nil
            } else {
                return users[0]
            }
        }
    }
    
    var languages: Results<Language> {
        get {
            return self.realm!.objects(Language).filter("words.@count > 10 && owner == %@", self.user!)
        }
    }
    
    var selectedLanguageIndexPath: NSIndexPath? {
        get {
            return self.languagesTableView.indexPathForSelectedRow
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = try! Realm()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.languages.count == 0 {
            self.startTestButton.enabled = false
        } else {
            self.startTestButton.enabled = true
        }
        self.languagesTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareView(){
        
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TestTableViewCell") as! TestTableViewCell!
        cell.languageLabel.text = self.languages[indexPath.row].name
        cell.flagImageView?.image = UIImage.init(named: "\(indexPath.row + 1)")
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "runTestSegue" {
            let testController = segue.destinationViewController as! TestViewController
            testController.language = self.languages[self.selectedLanguageIndexPath!.row]
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "runTestSegue" {
            if self.selectedLanguageIndexPath != nil {
                return true
            }
            return false
        }
        return false
    }
}
