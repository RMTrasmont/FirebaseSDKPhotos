//
//  SettingsTableViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/6/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//Protocol to let all other views that use username/image/email to reload to update changes in settings
protocol SettingsTableViewControllerDelegate{
    func updateUserInfos()
}

class SettingsTableViewController: UITableViewController{


    var delegate:SettingsTableViewControllerDelegate?
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var currentUserID:String = ""
    var currentUSER:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Edit Profile"
        
        userNameTextField.delegate = self   //<--- dismiss keyboard only
        emailTextField.delegate = self    //<--- dismiss keyboard only
        
        
        fetchCurrentUser()
        
    }


    func fetchCurrentUser(){
       SharedAPI.User.observeCurrentUser { (user) in
        //test
//        print(user.username)
//        print(user.email)
//        print(user.profileImageURL)
        self.currentUSER = user
        self.currentUserID = user.id!
        self.userNameTextField.text = user.username
        self.emailTextField.text = user.email
        if let profileImageURL = URL(string: user.profileImageURL!){
            self.profileImageView.sd_setImage(with: profileImageURL)
            }
        }
    }
    
    
    //Saving button updates all info changed in settings, similar to sign-up, updates in database, storage and authentication by calling the updateUserInfo Method below
    @IBAction func saveButton_Touched(_ sender: UIButton) {
        if let profileIMG = self.profileImageView.image,let imgData = UIImageJPEGRepresentation(profileIMG, 0.1){
            
            updateUserInfo(userName: userNameTextField.text!, email: emailTextField.text!, imageData: imgData, onSuccess: { 
                print("SUCCESSFULLY SAVED NEW DATA")
                self.delegate?.updateUserInfos()
            }, onError: { (error) in
                
                print("ERROR SAVING NEW DATA:\(error!)")
            })
            
        }
    }
    

    @IBAction func changeProfilePhoto_Touched(_ sender: UIButton) {
        //Init & present  photopicker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    //[REFACTOR FROM AUTHSERVICE*] Update User Info for Database Storage & Authentication, Taken from AuthService Before Refactor*
    func updateUserInfo(userName: String, email:String, imageData:Data, onSuccess:@escaping ()-> Void, onError:@escaping (_ errorMessage:String?) -> Void){
        
        let currentUser = Auth.auth().currentUser
        
        //UPDATE CHANGE IN EMAIL/USERNAME IN FIREBASE AUTHENTICATION
        currentUser?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                //Update User INfo
                let uid = self.currentUSER?.id
                
                //HANDLE IMAGE FIREBASE STORAGE
                let storageRef = Storage.storage().reference(forURL: ConfigStorage.STORAGE_ROOF_REF).child("profileImage").child(uid!)
                storageRef.putData(imageData, metadata: nil) { (metaData, error) in
                    
                    if error != nil{
                        return
                    }
                    
                    let profileImageURL = metaData?.downloadURL()?.absoluteString
                    
                    
                    //UPDATE MODIFIED DATA IN FIREBASE DATABASE
                    self.updateDatabase(profileImageURL: profileImageURL!, userName: userName, email: email, onSuccess: onSuccess, onError: onError)
                    
                }
                
            }
        })
        
    }

//    //[REFACTOR FROM AUTHSERVICE*] Method to to set user info to database Refactored from AuthService*
//    func setUserInformation(profileImageURL:String, userName:String, email:String, uid:String, onSuccess:@escaping ()-> Void){
//        let dataRef = Database.database().reference()
//        let userRef = dataRef.child("users")
//        let newUserRef = userRef.child(uid)
//        newUserRef.setValue(["username": userName,"email": email, "profileImageURL":profileImageURL])
//        onSuccess()
//    }
    
    //[REFACTOR FROM AUTHSERVICE*] Only Overrite Modified Data in Database
    func updateDatabase(profileImageURL:String, userName:String, email:String, onSuccess:@escaping ()-> Void,onError:@escaping (_ errorMessage:String?) -> Void){
        let dict = ["username": userName,"email": email, "profileImageURL":profileImageURL]
        SharedAPI.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
            
            
        })
    }
    
    
////
} ///
////


//EXTENSION FOR UIPICKER DELEGATE METHODS
extension SettingsTableViewController :UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    //DELEGATE METHOD FOR AFTER A PHOTO IS SELECTED FROM PICKERVIEW
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //test
        print("IMAGE SELECTED")
        print(info)
        
        //EXTRACT IMAGE FORM "info" AND ASSIGN SELECTED IMAGE TO THE IMAGE VIEW
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImageView.image = image
        }
        
        
        //DISMISS PICKER CONTROLLER AFTER IMAGE IS SELECTED
        dismiss(animated: true, completion: nil)
    }
    
    
}

//EXTENSION TO HANDLE KEYBOARD DISMISS WHEN CLICKING RETURN
extension SettingsTableViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

