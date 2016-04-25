//
//  LoginViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/20/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//
let emptyFieldsMessage = "Не заполнены все поля"
let loginExistMessage = "Пользователь с таким логином уже существует"
let incorrrectLoginDataMessage = "Неправильный логин или пароль"

import UIKit
import RealmSwift

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var enterButton: UIButton!
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for button in [self.registerButton] {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        textField.resignFirstResponder()
        return true
    }

    //MARK: - UITextFieldDelegate
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        guard let login = self.nameTextField.text where !login.isEmpty, let password = self.passwordTextField.text where !password.isEmpty else {
            self.showMessage("Some message")
            return
        }
        self.signIn(login, password: password)
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        guard let login = self.nameTextField.text where !login.isEmpty, let password = self.passwordTextField.text where !password.isEmpty else {
            self.showMessage("Some message")
            return
        }
        self.logIn(login, password: password)
    }
    
    func showMessage (message: String){
        let alert = UIAlertController.init(title: message, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler: nil
        )
        alert.addAction(okAction)
        self .presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Methods
    
    func logIn(login:String, password: String){
        let users = realm.objects(User).filter("password == %@ && login == %@", password, login)
        if !users.isEmpty {
            self.saveUser(login, password: password, ID: users[0].ID)
        } else {
            self.showMessage(incorrrectLoginDataMessage)
        }
    }
    
    func signIn(login:String, password: String){
        let users = realm.objects(User).filter("login == %@", login)
        if users.isEmpty {
            let newUser = User()
            newUser.login = login
            newUser.password = password
            if let maxUserID = self.realm.objects(User).max("ID") as Int!{
                newUser.ID = maxUserID + 1
            } else {
                newUser.ID = 0
            }
            try! realm.write({
                realm.add(newUser)
            })
            self.saveUser(login, password: password, ID: newUser.ID)
        } else {
            self.showMessage(loginExistMessage)
        }
    }
    
    func saveUser(login:String, password: String, ID: Int){
        NSUserDefaults.standardUserDefaults().setValue(login, forKey: "login")
        NSUserDefaults.standardUserDefaults().setValue(password, forKey: "password")
        NSUserDefaults.standardUserDefaults().setValue(ID, forKey: "ID")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
