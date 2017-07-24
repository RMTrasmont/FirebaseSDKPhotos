//
//  Comment.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/28/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import Foundation

class Comment {
    var commentText:String?
    var uid: String?
}

extension Comment{
    static func transformComment(dict:[String:Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}
