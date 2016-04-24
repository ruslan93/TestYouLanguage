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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = try! Realm()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareView()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for button in [self.exitButton, self.changePasswordButton] {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.blackColor().CGColor
        }
        self.userImageView.layer.borderWidth = 1
        self.userImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }

    
    func prepareView(){
        if self.user != nil {
            self.languageNumberLabel.text = "\(self.user!.languages.count)"
            var wordNumber = 0
            for language in self.user!.languages{
                wordNumber += language.words.count
            }
            self.wordsNumberLabel.text = "\(wordNumber)"
            self.userNameLabel.text = self.user!.login
        }
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
