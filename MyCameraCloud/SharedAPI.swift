//
//  SharedAPI.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/29/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import Foundation

struct SharedAPI {
    static var Post = PostAPI()
    static var User = UserAPI()
    static var Comment = CommentAPI()
    static var Post_Comment = Post_CommentAPI()
    static var User_Posts = User_PostsAPI()
    static var Follow = FollowAPI()
    static var Feed = FeedAPI()
}
