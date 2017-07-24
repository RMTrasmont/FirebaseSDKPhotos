//
//  FollowAPI.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/3/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class FollowAPI{
    
    var REF_FOLLOWERS = Database.database().reference().child("followers")
    
    var REF_FOLLOWING = Database.database().reference().child("following")
    
    func followAction(withUser id: String){
        
        guard let currentUser = Auth.auth().currentUser else {return}
        
        //After FOLLOWING a user, look up "user-post" to see all post made by the just-followed user
        SharedAPI.User_Posts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    //Access the feed database, then store the followed *user's key as a child of current-user. Set to true to say its there
                    
                    Database.database().reference().child("feed").child(currentUser.uid).child(key).setValue(true) //<--- "true it exists"
                }
            }
        })
        
        //Put Current-User in the in the Followed-User's list
        REF_FOLLOWERS.child(id).child(currentUser.uid).setValue(true)
        
        //Put the Followed-User in the Current-user's list
        REF_FOLLOWING.child(currentUser.uid).child(id).setValue(true)
        
    }
    
    func unfollowAction(withUser id: String){
        
        guard let currentUser = Auth.auth().currentUser else {return}
        
        //After UNFOLLOWING a user, look up "user-post" to see all post made by the just-unfollowed user
        SharedAPI.User_Posts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    //Access the feed database, then remove the followed *user's key as a child of current-user. removeValue() to remove it
                    
                    Database.database().reference().child("feed").child(currentUser.uid).child(key).removeValue()  //<--- Remove posts from feed
                }
            }
        })
        
        
        //Remove Current-User in the in the Followed-User's list
        REF_FOLLOWERS.child(id).child(currentUser.uid).setValue(NSNull())
        
        //Remove the Followed-User in the Current-user's list
        REF_FOLLOWING.child(currentUser.uid).child(id).setValue(NSNull())
        
    }
    
 
    //CHECK IF CURRENT-USER IS FOLLOWING THE VIEWED USER
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        
        guard let currentUser = Auth.auth().currentUser else {return}
        
        REF_FOLLOWERS.child(userId).child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let _ = snapshot.value as? NSNull {
                //current-user NOT in the list
                completed(false)
            } else {
                //current-user IS in the list
                completed(true)
            }
        })
    }
    
    //GET THE NUMBER OF USERS THE INDIVIDUAL FOLLOWS
    func fetchFollowingCount(userId:String, completion: @escaping (Int)-> Void){
        
        //observe for .value grabs all values(postID) in the node in a snapshot
        REF_FOLLOWING.child(userId).observe(.value, with: { (snapshot) in
            
            //the count is the number of children inside the following node under the user's ID
            let count = Int(snapshot.childrenCount)
            
            //return the count user is following
            completion(count)
        })
    }
    
    //GET THE NUMBER OF USERS THAT FOLLOW THIS INDIVIDUAL
    func fetchFollowerCount(userId:String, completion: @escaping (Int)-> Void){
        
        //observe for .value grabs all values(postID) in the node in a snapshot
        REF_FOLLOWERS.child(userId).observe(.value, with: { (snapshot) in
            
            //the count is the number of children inside the follower node under the user's ID
            let count = Int(snapshot.childrenCount)
            
            //return the count number of followers
            completion(count)
        })
    }
    
    
//////
}   ///
/////
