//
//  User.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/26/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import Foundation
class User {
    var email:String?
    var profileImageURL: String?
    var username:String?
    var id: String?
    var isFollowing: Bool?
}

//Note: "key" is from snapshot...the key is the user id in "users"

extension User {
    
    static func transformUser(dict:[String:Any],key:String) -> User{
        let user = User()
        user.email = dict["email"] as? String
        user.profileImageURL = dict["profileImageURL"] as? String
        user.username = dict["username"] as? String
        user.id = key
        return user
    }
}
