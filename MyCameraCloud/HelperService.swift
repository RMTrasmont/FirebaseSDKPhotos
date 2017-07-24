//
//  HelperService.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/4/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

//HANDLE DATA & STORAGES AND THE LIKES IN THIS CLASS

import Foundation
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
class HelperService {
    
    static func uploadDataToServer(data: Data, caption: String, onSuccess: @escaping ()->Void){
        
        //create random ID for objects
        let photoIDString = NSUUID().uuidString
        
        //create storage
        let storageRef = Storage.storage().reference(forURL:ConfigStorage.STORAGE_ROOF_REF).child("posts").child(photoIDString)
        
        //put in storge
        storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
            
            //error
            if error != nil {
                return
            }
            
            //no error
            //URL for database access
            let photoURL = metadata?.downloadURL()?.absoluteString
            
            //sends photo from storage to database
            self.sendDataToDataBase(photoURL: photoURL!, caption:caption, onSuccess: onSuccess )
        })
    
    
    }
    
    static func sendDataToDataBase(photoURL:String, caption: String, onSuccess:@escaping()->Void){
        //create new post id using autoID as key
        let newPostID = SharedAPI.Post.REF_POSTS.childByAutoId().key
        
        //set new info at this location
        let newPostReference = SharedAPI.Post.REF_POSTS.child(newPostID)
        
        //get the Current-User
        guard let currentUser = Auth.auth().currentUser else {return}
        let currentUserID = currentUser.uid
        
        //add Time Stamp
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        //set values for newpost
        newPostReference.setValue(["uid":currentUserID, "photoURL":photoURL,"photo_caption":caption,"timeStamp":timeStamp,"likeCount":0],withCompletionBlock: { (error, ref) in
            //IF ERROR
            if error != nil {
                print(error!.localizedDescription)
                print(error.debugDescription)
            }
            
            //Store this post-id to the "feed" node of current-user
            SharedAPI.Feed.REF_FEED.child(currentUser.uid).child(newPostID).setValue(true)
            
            
            //IF SUCCESS(succesfully stored into database)
            //tie up user to post relation "Mapping Data"...
            let userPostRef = SharedAPI.User_Posts.REF_USER_POSTS.child(currentUserID).child(newPostID)
            userPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error.debugDescription)
                    return
                }
            })
            
            onSuccess()
        })
        
    }
    
    

////
} ///
///


//SEND DATTA METHOD PHOTOVIEWCONTROLLER
//let ref = Database.database().reference()
//let postRef = ref.child("posts")
//let newPostID = postRef.childByAutoId().key
//let newPostRef = postRef.child(newPostID)
//guard let currentUser = Auth.auth().currentUser else {return}
//let currentUserID = currentUser.uid
//newPostRef.setValue(["uid":currentUserID, "photoURL":photoURL,"photo_caption":captionTextView.text!]) { (error, ref) in
//    //IF ERROR
//    if error != nil {
//        print(error!.localizedDescription)
//        print(error.debugDescription)
//    }
//    
//    //IF SUCCESS(succesfully stored into database)
//    //tie up user to post relation "Mapping Data"...
//    let userPostRef = SharedAPI.User_Posts.REF_USER_POSTS.child(currentUserID).child(newPostID)
//    userPostRef.setValue(true, withCompletionBlock: { (error, ref) in
//        if error != nil {
//            print(error.debugDescription)
//            return
//        }
//    })
//    
//    //clear input
//    self.captionTextView.text = ""
//    self.photo.image = UIImage(named: "default-photo-icon")
//    //reset selected image after it's sent to database, so share button is disabled
//    self.selectedImage = nil
//    //switch back to home view
//    self.tabBarController?.selectedIndex = 0
//}

//SHARE BUTTON TOUCHED PHOTOVIEWCONTROLLER
////create ID
//let photoIDString = NSUUID().uuidString  //<---ios method creates random ID for objects
////create storage
//let storageRef = Storage.storage().reference(forURL:"gs://mycameracloud.appspot.com").child("posts").child(photoIDString)
////put in storge
//storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
//    if error != nil {
//        return
//    }
//    //needed for database access
//    let photoURL = metadata?.downloadURL()?.absoluteString
//    
//    //sends photo from storage to database
//    self.sendDataToDataBase(photoURL: photoURL!)
//})

