//
//  Post_CommentAPI.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/29/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//
//HANDLE ALL API TASKS RELATED TO OUR FIREBASE POST-COMMENTS DATA-MAP ONLY

import Foundation
import FirebaseDatabase
class Post_CommentAPI{
    
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
    func observePost_Comments(){
        
    }
    
    
    
}
