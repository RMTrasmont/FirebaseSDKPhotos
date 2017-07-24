//
//  UserAPI.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/29/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

////HANDLE ALL API TASKS RELATED TO OUR FIREBASE USER ONLY


import Foundation
import FirebaseDatabase
import FirebaseAuth
class UserAPI{
    

    //. Have property that access database location of all users
    
    var REF_USERS = Database.database().reference().child("users")
    
    //
    
    //GET SINGLE USER INCLUDING RECENTLY ADDED
    func observeUser(withID uid:String, completion:@escaping (User)-> Void){

        REF_USERS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    //GET ALL USERS, NOte: Don't show user on list to Follow
    func observeUsers(completion: @escaping (User) -> Void){
        REF_USERS.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                let user = User.transformUser(dict: dict, key: snapshot.key)
                guard let currentUser = Auth.auth().currentUser else {return}
                if user.id! != currentUser.uid{
                  completion(user)
                    
                }
            }
        })
    }
    
    
    //FUNC TO OBSERVE CURRENT USER
    func observeCurrentUser(completion:@escaping (User)-> Void){
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                let newUser = User.transformUser(dict: dict, key: snapshot.key)
                completion(newUser)
            }
        })
    }
    
    
    //SETUP A PROPERTY TO QUERY CURRENT USER ANYTIME
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return REF_USERS.child(currentUser.uid)
    }


}
