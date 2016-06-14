//
//  SettingsViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/22/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsViewController: UIViewController {

    //MARK: - Properties

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var languageNumberLabel: UILabel!
    
    @IBOutlet weak var wordsNumberLabel: UILabel!
    
    @IBOutlet weak var lastResultLabel: UILabel!
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var changePasswordButton: UIButton!
    
    var realm: Realm? = nil
    
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
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = try! Realm()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareView()
    }
    
    // MARK: - Methods

    func prepareView(){
        if self.user != nil {
            self.languageNumberLabel.text = "\(self.user!.languages.count)"
            var wordNumber = 0
            for language in self.user!.languages{
                wordNumber += language.words.count
            }
            self.wordsNumberLabel.text = "\(wordNumber)"
            
            if let averagePercent = self.realm!.objects(Result).average("percent") as Int?{
                if averagePercent >= 50 {
                    self.lastResultLabel.textColor = UIColor.greenColor()
                } else {
                    self.lastResultLabel.textColor = UIColor.redColor()
                }
                self.lastResultLabel.text = "\(averagePercent)%"
            }
            self.userNameLabel.text = self.user!.login
            if !(self.user?.profileImage.isEmpty)! {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                let profileImage = UIImage.init(contentsOfFile: "\(documentsPath)/\(self.user!.profileImage)")
                self.userImageView.image = profileImage
            } else {
                self.userImageView.image = UIImage.init(named: "profile")
            }
        }
    }

    @IBAction func changePasswordButtonPressed(sender: AnyObject) {
        let alert = UIAlertController.init(title: NSLocalizedString("changePasswordTitle", comment: ""), message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (oldPasswordTextField) in
            oldPasswordTextField.placeholder = NSLocalizedString("oldPassword", comment: "")
        }
        alert.addTextFieldWithConfigurationHandler { (newPasswordTextField) in
            newPasswordTextField.placeholder = NSLocalizedString("newPassword", comment: "")
        }
        let changeAction = UIAlertAction.init(title: NSLocalizedString("edit", comment: ""), style: .Default) { (action:UIAlertAction!) in
            let oldPasswordTextField = alert.textFields![0]
            let newPasswordTextField = alert.textFields![1]
            guard let oldPassword = oldPasswordTextField.text where !oldPassword.isEmpty else{
                return
            }
            guard let newPassword = newPasswordTextField.text where !newPassword.isEmpty else{
                return
            }
            self.changePassword(oldPassword, newPassword: newPassword)
        }
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(changeAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeNameButtonPressed(sender: AnyObject) {
        let alert = UIAlertController.init(title: NSLocalizedString("changeNameTitle", comment: ""), message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (newNameTextField) in
            newNameTextField.placeholder = NSLocalizedString("newName", comment: "")
        }
        let changeAction = UIAlertAction.init(title: NSLocalizedString("edit", comment: ""), style: .Default) { (action:UIAlertAction!) in
            let newNameTextField = alert.textFields![0]
            guard let newName = newNameTextField.text where !newName.isEmpty else{
                return
            }
            self.changeName(newName)
        }
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(changeAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func changeName (name: String){
        let currentUser = realm!.objects(User).filter("ID == %@", NSUserDefaults.standardUserDefaults().valueForKey("ID")!)[0]
        self.userNameLabel.text = name
        try! self.realm!.write({
            currentUser.login = name
        })
    }

    func changePassword (oldPassword: String, newPassword: String){
        let currentUser = realm!.objects(User).filter("ID == %@", NSUserDefaults.standardUserDefaults().valueForKey("ID")!)[0]
        if currentUser.password == oldPassword{
            try! self.realm!.write({
                currentUser.password = newPassword
            })
        } else {
            self.showMessage(NSLocalizedString("incorrrectPasswordMessage", comment: ""))
        }
    }

    func showMessage (message: String){
        let alert = UIAlertController.init(title: message, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler: nil
        )
        alert.addAction(okAction)
        self .presentViewController(alert, animated: true, completion: nil)
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logOutSegue" {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("login")
        }
    }
}
