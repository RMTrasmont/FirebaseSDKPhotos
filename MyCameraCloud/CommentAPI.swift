//
//  CommentAPI.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/29/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//
//HANDLE ALL API TASKS RELATED TO OUR FIREBASE COMMENTS ONLY

import Foundation
import FirebaseDatabase

class CommentAPI {
    
    //1. Have property that access database loc. of all comments
    
    var REF_COMMENTS = Database.database().reference().child("comments")
    
    //Get Child at this location, Observe for event of type value to get all values [key:value]. If successful we get a snapshot back, conver that to a user and escape the function w/ instance of new comment// //@escaping execute after we have instance of new comment
    
    func observeComments(withPostID id:String, completion: @escaping (Comment)-> Void ){
        REF_COMMENTS.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String :Any]{
                let newComment = Comment.transformComment(dict: dict)
                completion(newComment)
            }
            
        })
    }








}
