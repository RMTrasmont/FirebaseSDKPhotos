//
//  User_PostAPI.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/1/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

//THIS FILE TIES UP POSTS WITH ITS USER

import Foundation
import FirebaseDatabase
class User_PostsAPI{
    
    var REF_USER_POSTS = Database.database().reference().child("user-posts")

    func fetchMyPost(userId: String, completion:@escaping (String) -> Void){
        
        //observe for child.added to actively listen for changes
       
        REF_USER_POSTS.child(userId).observe(.childAdded, with: { (snapshot) in
            
            //get posts keys/IDs return as completion
            
            completion(snapshot.key)
        })
        
    }
 
    func fetchCountUserPosts(userId:String,completion:@escaping (Int) -> Void){
        
        //observe for .value grabs all values(postID) in the node
        REF_USER_POSTS.child(userId).observe(.value, with: { (snapshot) in
            
            //get number of posts by that user
            let count = Int(snapshot.childrenCount)
            
            completion(count)
        })
    }


}
