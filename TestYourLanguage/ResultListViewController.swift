//
//  ResultListViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/22/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import RealmSwift

class ResultListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Properties

    @IBOutlet weak var tableView: UITableView!
    
    var realm: Realm? = nil
    
    var user: User? {
        get {
            if self.realm == nil {
                return nil
            }
            let users = self.realm!.objects(User).filter("ID == %@", NSUserDefaults.standardUserDefaults().valueForKey("ID")!)
            if users.isEmpty {
                return nil
            } else {
                return users[0]
            }
        }
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = try! Realm()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if self.user == nil{
            return 0
        }
        return (self.realm?.objects(Language).filter("results.@count > 0 && owner == %@", self.user!).count)!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.realm?.objects(Language).filter("results.@count > 0 && owner == %@", self.user!))![section].results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultTableViewCell") as! ResultTableViewCell!
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! ResultTableViewCell
        let result = (self.realm?.objects(Language).filter("results.@count > 0 && owner == %@", self.user!))![indexPath.section].results[indexPath.row]
        cell.dateLabel.text = "\(result.date)"
        cell.resultLabel.text = "\(result.percent)%"
        cell.rightAnswerLabel.text = "\(result.rightQuestion)/\(result.totalQuestion)"
        if result.percent >= 50{
            cell.resultLabel.textColor = UIColor.greenColor()
        } else {
            cell.resultLabel.textColor = UIColor.redColor()
        }
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultHeaderTableViewCell") as! ResultHeaderTableViewCell!
        let language = self.realm?.objects(Language).filter("results.@count > 0 && owner == %@", self.user!)[section]
        cell.languageLabel.text = "\(language!.name)"
        cell.flagImageView.image = UIImage.init(named: "\(language!.name)")
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
}
