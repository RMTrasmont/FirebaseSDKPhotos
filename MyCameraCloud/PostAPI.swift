//
//  PostAPI.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/29/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

//HANDLE ALL API TASKS RELATED TO OUR FIREBASE POSTS ONLY

import Foundation
import FirebaseDatabase

class PostAPI {
    
    //1. Have property that access database loc. of all post
    
    var REF_POSTS = Database.database().reference().child("posts")
    
            ////OBSERVE ALL POST
    //2. Have something to query post data, and observe ALL POSTS in the database, if we have data create post
        //@escaping execute after we have instance of Post
    
    func observePosts(completion:@escaping (Post)-> Void){
        REF_POSTS.observe(.childAdded, with: { (snapshot) in
            if let dataDict = snapshot.value as? [String:Any]{
             let newPost = Post.transformPost(dict: dataDict, key: snapshot.key)
                completion(newPost)
            }
        })
        
    }
    
        //OBSERVE SINGLE POST
    //3. Method to get post from database and transform it into an object of the Post.swift Class using the ID of the post in the database as parameter
    
    func observePost(withID id:String, completion: @escaping (Post) -> Void){
        //"observe" grabs data and returns a shapshot
        REF_POSTS.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                let post = Post.transformPost(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    //METHOD TO FETCH MOST POPULAR POSTS
    //query returns data that is sorted increasingly based on input i.e. sort by "likeCount". Least to Most counts ...reverse below
    //then fetch(observe) data
    
    func observeTopPosts(completion: @escaping (Post) -> Void){
        REF_POSTS.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: { (snapshot) in
            //convert the one large snapshot array of data into an array of multiple of snapshot objects
            let arrayOfSnapshots = (snapshot.children.allObjects as! [DataSnapshot]).reversed()   // <--- reversed here* Most to least
            //loop through the array to get each element
            for child in  arrayOfSnapshots {
                //convert into post object
                if let dict = child.value as? [String: Any] {
                    let post = Post.transformPost(dict: dict, key: child.key)
                    //return a post
                    completion(post)
                }
            }
        })
    }
    
/////
}  ///
/////
