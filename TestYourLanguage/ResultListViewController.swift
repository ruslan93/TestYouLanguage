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
    
    @IBOutlet weak var noneResultsLabel: UILabel!

    @IBOutlet weak var deleteResultsBarButton: UIBarButtonItem!
    
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
        self.noneResultsLabel.text = NSLocalizedString("noneResultsLabel", comment: "")
        self.deleteResultsBarButton.enabled = self.realm?.objects(Language).filter("results.@count > 0 && owner == %@", self.user!).count > 0
        self.noneResultsLabel.hidden = self.realm?.objects(Language).filter("results.@count > 0 && owner == %@", self.user!).count > 0
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
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .MediumStyle
        let dateString = formatter.stringFromDate(result.date)
        cell.dateLabel.text = "\(dateString)"
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
    @IBAction func clearResultsBarButtonPressed(sender: AnyObject) {
        let alert = UIAlertController.init(title: NSLocalizedString("deleteResultsTitle", comment: ""), message: nil, preferredStyle: .Alert)
        let deleteAction = UIAlertAction.init(title: NSLocalizedString("delete", comment: ""), style: .Default){ (action:UIAlertAction!) -> Void in
          self.deleteAllResults()
        }
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteAllResults(){
        let results = realm!.objects(Result)
        for result in results {
            try! self.realm!.write({
                self.realm?.delete(result)
            })
        }
        self.tableView.reloadData()
        self.noneResultsLabel.hidden = self.realm?.objects(Language).filter("results.@count > 0 && owner == %@", self.user!).count > 0
        self.deleteResultsBarButton.enabled = self.realm?.objects(Language).filter("results.@count > 0 && owner == %@", self.user!).count > 0
    }
}
