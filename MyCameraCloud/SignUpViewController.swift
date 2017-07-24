//
//  SignUpViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/17/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var selectedImage:UIImage?
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleProfileImageView()
        
        handleTextfield()
        
        //DISABLE SIGN-UP BUTTON, ENABLED ONLY WHEN TEXTFIELD INPUTS ARE MET
        signUpButton.isEnabled = false
        
    }
    
    //DELEGATE METHOD TO DETECT TOUCHES ON THE VIEW ...USE TO DISMISS KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Method Causes the view (or one of its embedded text fields) to resign the first responder status thus hiding the keyboard.
        
        view.endEditing(true)
        
    }
    
    
    //I.METHOD TO ADD ACTION TO TEXTFIELDS
    func handleTextfield(){
        usernameTextField.addTarget(self, action: #selector(self.textfieldDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textfieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textfieldDidChange), for: .editingChanged)
    }
    
    //II.METHOD TO ALLOW THE THE SIGN-UP BUTTON TO BE CLICKED WHEN THE TEXTFIELDS ARE ALL FILLED
    func textfieldDidChange(){
        guard let username = usernameTextField.text, !username.isEmpty,
        let email = emailTextField.text, !email.isEmpty,
        let password = passwordTextField.text, !password.isEmpty else {
            //CASES INVALID
            signUpButton.setTitleColor( .red, for: .normal)
            signUpButton.isEnabled = false
            return
        }
        //CASES VALID
        signUpButton.setTitleColor(UIColor.green, for: .normal)
        signUpButton.isEnabled = true
    }
    
    //I.METHOD TO HANDLE PROFILEIMAGEVIEW
    func handleProfileImageView(){
        //MAKE IMAGEVIEW INTO A CIRCLE (MAKE CORNER RADIUS HALF OF WIDTH)
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        
        //ADD GESTURE TO PROFILE IMAGE TO RESPOND TO TAP
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.handleSelectProfileImage))
        profileImageView.addGestureRecognizer(tapGesture)
        
        profileImageView.isUserInteractionEnabled = true    }
    
    //II.METHOD TO PRESENT PHOTO PICKER LIBRARY ON PHONE TO USER WHEN PHOTO VIEW CLICKED 
    func handleSelectProfileImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    
    //METHOD TO DISMISS THE VIEW BUTTON IS IN
    @IBAction func dismiss_view(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    //METHOD TO HANDLE SIGN-UP BUTTON & CREATE A USER IN FIREBASE   LEFT OFF*
    @IBAction func signUpButton_Pressed(_ sender: UIButton) {
        //DISMISS KEYBOARD
        self.view.endEditing(true)
        
        activityIndicatorView.startAnimating()
        
        //**AUTHENTICATION******
        //AUTHENTICATE & CREATE USER
        Auth.auth().createUser(withEmail:emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil{
                print("ERROR FOUND \(error!.localizedDescription)")
                print("ERROR DESCRIPTION \(error.debugDescription)")
                
                return
            }
            
            //DEFINE USER ID
            let userID = user?.uid

            //**CLOUD STORAGE FOR MEDIA*******
            //DEFINE & CREATE REFERENCE TO FIREBASE STORAGE // ALT TO STEPS 2,3,4,5,
            let storageRef = Storage.storage().reference(forURL: "gs://mycameracloud.appspot.com").child("profileImage").child(userID!)
            
            //PUSH THE SELECTED IMAGE TO FIREBASE STORAGE IN JPEG FORMAT WHICH IS USED IN FIREBASE/JSON
            if let profileImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImage , 0.1){
                
                //PUT THE IMAGE DATA TO FIREBASE STORAGE
                storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
                    
                    //CHECK ERROR
                    if error != nil {
                        print("ERROR: \(error!.localizedDescription)")
                        print("ERROR DEBUG: \(error.debugDescription)")
                        return
                    }
                    
                    //GET THE URL OF THE IMAGE METADATA FROM STORAGE TO BE USED IN DATABASE TO SET PROFILE IMAGE
                    let profileImageURL = metaData?.downloadURL()?.absoluteString
                    
                    //**DATABASE FOR STRING INFO*********
                    //DEFINE & CREATE REFERENCE TO FIREBASE DATABASE
                    let databaseRef = Database.database().reference()
                    
                    //CREATE A NODE IN THE DATABASE FOR USERS
                    let usersRef = databaseRef.child("users")
                    
                    //CREATE A "NEW-USER-NODE" WITHIN THE "USERS-NODE" & USE ITS USER ID AS PATHSTRING TO DATABASE
                    let newUserRef = usersRef.child(userID!)
                    
                    //STORE "NEW-USER-INFO" IN THE "NEW-USER-NODE".. USE DICTIONARY FORMAT IN DATABASE
                    newUserRef.setValue(["username": self.usernameTextField.text! ,"email": self.emailTextField.text!, "profileImageURL":profileImageURL])
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    //SEGEUE TO TAB BAR VIEWS
                    self.performSegue(withIdentifier: "signUpToTabbarVC", sender: nil)
                    
                })
            }
            
        }
    
    }

    
////////
}  //END
////////


//EXTENSION FOR UIPICKER DELEGATE METHODS
extension SignUpViewController:UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    //DELEGATE METHOD FOR AFTER A PHOTO IS SELECTED FROM PICKERVIEW
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //test
        print("IMAGE SELECTED")
        print(info)
        
        //EXTRACT IMAGE FORM "info" AND ASSIGN SELECTED IMAGE TO THE IMAGE VIEW
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image  //<--- send to Firebase Storage
            profileImageView.image = image
        }

        
        //DISMISS PICKER CONTROLLER AFTER IMAGE IS SELECTED
        dismiss(animated: true, completion: nil)
    }


}


