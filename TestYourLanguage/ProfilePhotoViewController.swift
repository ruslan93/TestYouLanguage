//
//  ProfilePhotoViewController.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/25/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import UIKit
import RealmSwift

class ProfilePhotoViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Properties

    @IBOutlet weak var profileImageView: UIImageView!

    let realm = try! Realm()
    
    var user: User?{
        get {
            let users = self.realm.objects(User).filter("ID == %@", NSUserDefaults.standardUserDefaults().valueForKey("ID")!)
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
        if self.user != nil{
            if self.user!.profileImage.isEmpty {
                self.profileImageView.image = UIImage.init(named: "profile")
            } else {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                let profileImage = UIImage.init(contentsOfFile: "\(documentsPath)/\(self.user!.profileImage)")
                self.profileImageView.image = profileImage
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Actions

    @IBAction func takePhotoButtonPressed(sender: AnyObject) {
        let picker = UIImagePickerController.init()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .Camera
        picker.cameraDevice = .Rear
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func selectPhotoButtonPressed(sender: AnyObject) {
        let picker = UIImagePickerController.init()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if self.user != nil {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let destinationPath = "\(documentsPath)/profile\(self.user!.ID).jpg"
            UIImageJPEGRepresentation(self.profileImageView!.image!,1.0)!.writeToFile(destinationPath, atomically: true)
            try! realm.write({
                self.user!.profileImage = "profile\(self.user!.ID).jpg"
            })
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    //MARK: - UIImagePickerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        self.profileImageView.image = UIImage.cropToBounds(selectedImage!)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
