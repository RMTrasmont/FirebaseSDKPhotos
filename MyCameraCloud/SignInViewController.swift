//
//  SignInViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/17/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    //var authenticationErrorCode:AuthErrorCode!
    
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleTextfield()
        signInButton.isEnabled = false
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        //AUTO LOG USER THAT HAVENT SIGNED OUT
        if Auth.auth().currentUser != nil {
                self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        }
    
    }
    
    //DELEGATE METHOD TO DETECT TOUCHES ON THE VIEW ...USE TO DISMISS KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //DISMISS KEYBOARD
        view.endEditing(true)
        
    }
    
    
    //METHOD TO SEGUE TO SIGN UP VIEW
    
    @IBAction func createAccountButton_tapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToCreateAccount", sender: nil)
    }
    
    //I.METHOD TO ADD ACTION TO TEXTFIELDS
    func handleTextfield(){
        emailTextField.addTarget(self, action: #selector(self.textfieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textfieldDidChange), for: .editingChanged)
    }
    
    //II.METHOD TO ALLOW THE THE SIGN-IN BUTTON TO BE CLICKED WHEN THE TEXTFIELDS ARE ALL FILLED
    func textfieldDidChange(){
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                //CASES INVALID
                signInButton.setTitleColor( .red, for: .normal)
                signInButton.isEnabled = false
                return
        }
        //CASES VALID
        signInButton.setTitleColor(UIColor.green, for: .normal)
        signInButton.isEnabled = true
    }
    
    //METHOD TO HANDLE SIGN-IN
    @IBAction func signInButton_Touched(_ sender: UIButton) {
        //DISMISS KEYBOARD
        view.endEditing(true)
        
        activityIndicatorView.startAnimating()
        
        //AUTHENTICATE & SIGN-IN  
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
        
            
            //ERROR
            if error != nil {
                print(error!.localizedDescription)
                print(error.debugDescription)
                
                
                return
            }
        }
        
        
        //NO ERROR
        //SEGEUE TO TAB BAR VIEWS
        self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        
        activityIndicatorView.stopAnimating()
        
        
    }

//    //I.METHOD TO SHOW ALERT VIEW FOR ERRORS DURING SIGN UP
//    func errorAlert(errorDescription:String){
//        let alert = UIAlertController(title:"MAJOR ERROR, SON", message: errorDescription, preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        alert.addAction(ok)
//        alert.addAction(cancel)
//        
//        present(alert, animated: true, completion: nil)
//    }
//    
//    //II.METHOD TO HANDLE ERROR CODES
//    func handleErrorResponse(){
//        
//        if let errorCode = authenticationErrorCode{
//            switch errorCode {
//            case .networkError:
//                self.errorAlert(errorDescription: "network error occurred during the operation")
//            case .userNotFound :
//                self.errorAlert(errorDescription: "no known user")
//            case .invalidEmail:
//                self.errorAlert(errorDescription: "the email address is malformed")
//            case .wrongPassword:
//                self.errorAlert(errorDescription: "password is wrong")
//            default:
//                self.errorAlert(errorDescription: "I Dunno WTF is up")
//            }
//        }
//        
//    }

    
///////
}   ///END
///////
