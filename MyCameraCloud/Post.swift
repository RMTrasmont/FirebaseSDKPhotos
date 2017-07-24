//
//  Post.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/24/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

//EACH INSTANCE OF THIS CLASS HOLDS THE DATA OF A POST FROM DATABASE

import Foundation
import FirebaseAuth
class Post {
    var photoURL:String?
    var photo_caption:String?
    var uid:String?
    var id:String?
    var likeCount: Int?
    var likes:Dictionary<String,Any>?
    var isLiked:Bool?
    var timeStamp: Int?
}


extension Post {
    
    //NOTE: Static allows calling this method W/O a Post-instance
    
    static func transformPost(dict:[String:Any],key:String) -> Post{
        let post = Post()
        post.id = key
        post.photoURL = dict["photoURL"] as? String
        post.photo_caption = dict["photo_caption"] as? String
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String,Any>
        post.timeStamp = dict["timeStamp"] as? Int
        //Handle isLiked Variable
        if let currentUserID = Auth.auth().currentUser?.uid {
            if post.likes != nil{
                if post.likes? [currentUserID] != nil{    //<--- check if user liked the Post
                    post.isLiked = true
                } else {
                    post.isLiked = false
                }
            }
        }
        
        
        return post
    }
    
    
    
}
