//
//  FeedAPI.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/5/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FeedAPI{
    var REF_FEED = Database.database().reference().child("feed")
    
    //METHOD TO RETURN POSTS FROM THE FEED THE CURRENT-USER FOLLOWS
    func observeFeed(withID id:String, completion:@escaping (Post)->Void){
        
        //observe function Returns a post
        REF_FEED.child(id).observe(.childAdded, with: { (snapshot) in
            
            //key is the ID of all posts
            let key = snapshot.key
            
            //get posts corresponding to the key above
            SharedAPI.Post.observePost(withID: key, completion: { (post) in
            
                //return gotten post as completion
                completion(post)
            })
        })
    }
    
    //METHOD TO RETURN POSTS THAT WERE REMOVED
    func observeFeedRemoved(withID id: String, completion: @escaping(Post)->Void){
        
        //Go to feed location listen for child removed from node... each removed post will be returned in a snapshot
        
        REF_FEED.child(id).observe(.childRemoved, with: { (snapshot) in
            //extract post key from snapshot
            let key = snapshot.key
            
            //extract and return post   <---need for removal postsArray HomeTableView
            SharedAPI.Post.observePost(withID: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    
///
} ///
///
