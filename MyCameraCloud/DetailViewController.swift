//
//  DetailViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/8/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import FirebaseAuth
class DetailViewController: UIViewController {
    
    var postID = ""
    var thePost = Post()
    var theUser = User()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //test post ID is being passed from DiscoverVC
        print("DISCOVER TO DETAILS PASS POST ID: \(postID)")
        
        tableView.dataSource = self

       loadPostInfo()
        
        
        
    }

    func loadPostInfo(){
        
        SharedAPI.Post.observePost(withID: postID) { (post) in
            
            guard let postUID = post.uid else { return }
            
            
            self.fetchUser(uid:postUID, completed:{
                self.thePost = post
                self.tableView.reloadData()
            })
        }
    }
    
    
    
    
    func fetchUser(uid:String, completed: @escaping() -> Void){
        SharedAPI.User.observeUser(withID: uid) { (user) in
            self.theUser = user
            completed()
        }
    }

    
    
    
/////
}   ///
////

extension DetailViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Note: cast cell as our custom "HomeTableViewcell" for more customization
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell

        cell.post = self.thePost
        cell.user = self.theUser
        cell.delegate = self
        return cell

    }

    
    //PREPARE DATA(postID/userID) BEFORE SEGUE, THAT MIGHT BE NEEDED IN INCOMMING VIEW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_to_CommentSegue"{
            let commentVC = segue.destination as! CommentViewController
            let postID  = sender as! String
            commentVC.postID = postID
        }
        
        if segue.identifier == "Detail_to_ProfileUserSegue"{
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId  = sender as! String
            profileUserVC.userID = userId
        }
        
    }
    
    
/////
}  ///
////

//EXTENTION TO ADOPT CUSTOM PROTOCOL FOR SWITCHING VIEWS FROM CELLS IN THE SUB-VIEW "HomeTableViewCell"
extension DetailViewController:HomeTableViewCellDelegate{
    //implement protocol methods for swithcing view
    
    func goToCommentVC(postID: String) {
        performSegue(withIdentifier: "Detail_to_CommentSegue", sender: postID)
    }
    
    func goToProfileUserVC(userID: String) {
        performSegue(withIdentifier: "Detail_to_ProfileUserSegue", sender: userID)
    }
    
}
