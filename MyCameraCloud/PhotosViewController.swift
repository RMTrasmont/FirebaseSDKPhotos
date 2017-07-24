//
//  PhotosViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/17/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
//import FirebaseStorage
//import FirebaseDatabase
//import FirebaseAuth
class PhotosViewController: UIViewController {

    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    var selectedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ADD TAP GESTURE TO IMAGE VIEW
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handlePhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        
        //DISABLE SHARE BUTTON
        shareButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handleShareButton()
    }
    
    
    //METHOD OT ENABLE SHARE BUTTON
    func handleShareButton(){
        if selectedImage != nil {
            self.shareButton.isEnabled = true
            self.shareButton.setTitleColor( .white , for: .normal)
        } else {
            self.shareButton.isEnabled = false
            self.shareButton.setTitleColor( UIColor.lightGray, for: .normal)
        }
    }
    
    
    
    //DELEGATE METHOD TO DETECT TOUCHES ON THE VIEW ...USE TO DISMISS KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Method Causes the view (or one of its embedded text fields) to resign the first responder status thus hiding the keyboard.
        
        view.endEditing(true)
        
    }
    
    
    func handlePhoto(){
      //SHOW PICKER WHEN PHOTO TAPPED
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    
        
    }


    @IBAction func shareButtonTouched(_ sender: UIButton) {
        //TAKE PHOTO AND PUSH TO FIREBASE STORAGE
        //convert
        if let photoImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(photoImg, 0.1){
        
        //*REFEACTORED TO HELPER
        HelperService.uploadDataToServer(data: imageData, caption: captionTextView.text!, onSuccess: { 
            
            //clear view inputs
            self.clearView()
            //switch back to home view
            self.tabBarController?.selectedIndex = 0
        })
            
        }
            print("SHARE BUTTON TAPPED")
    }
    
    func sendDataToDataBase(photoURL:String){
            //REFACTORED* TO HELPER
    }
    
    //METHOD TO CANCEL SHARE POST
    @IBAction func cancel_touched(_ sender: UIBarButtonItem) {
        //RESET VARIABLES
        self.captionTextView.text = ""
        self.photo.image = UIImage(named:"default-photo-icon")
        self.selectedImage = nil
        self.shareButton.isEnabled = false
        self.shareButton.setTitleColor(.red, for: .normal)
    }
    
    func clearView(){
        //clear input
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "default-photo-icon")
        //reset selected image after it's sent to database, so share button is disabled
        self.selectedImage = nil
  
    }
    
///////
} //END
///////

//EXTENSION FOR UIPICKER DELEGATE METHODS
extension PhotosViewController:UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    //DELEGATE METHOD FOR AFTER A PHOTO IS SELECTED FROM PICKERVIEW
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //test
        print("IMAGE SELECTED")
        print(info)
        //EXTRACT IMAGE FROM "info" AND ASSIGN SELECTED IMAGE TO THE IMAGE VIEW
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image  //<--- send to Firebase Storage
            photo.image = image
        }
        
        //DISMISS PICKER CONTROLLER AFTER IMAGE IS SELECTED
        dismiss(animated: true, completion: nil)
    }

}



