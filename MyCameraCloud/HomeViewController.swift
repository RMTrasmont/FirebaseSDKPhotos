//
//  HomeViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/17/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import FirebaseAuth
//import FirebaseDatabase
import SDWebImage
class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
   
    var postsArray = [Post]()
    var usersArray = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //HANDLE DYNAMIC CELL SIZE ADJUST
        tableView.estimatedRowHeight = 523 //<-est. max
        tableView.rowHeight = UITableViewAutomaticDimension
        //
        tableView.dataSource = self
        
        //Slight Delay on Load or else stuck on loading.
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            //self.loadPosts()  // <---CHANGE WITH LOAD FEED*
            self.loadFeeds()
        }
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //***REPLACED WITH loadFeeds()***
    
//    //Show all Posts
//    func loadPosts(){
//        //self.activityIndicatorView.startAnimating()
//        
//        SharedAPI.Post.observePosts { (post) in
//            
//            guard let postUID = post.uid else {
//                return
//            }
//            
//            //LOOK UP THE USER THAT LOADED POST
//            self.fetchUser(uid:postUID, completed: {
//                self.postsArray.append(post)
//                //self.activityIndicatorView.stopAnimating()
//                self.tableView.reloadData()
//            })
//        }
//    }
    
    //Show only followed Posts// "feed" database
    func loadFeeds(){
        
        guard let currentUser = Auth.auth().currentUser else {return}
        
        //get posts form feed database of current-user to show in homeview
       SharedAPI.Feed.observeFeed(withID: currentUser.uid) { (post) in
        
            guard let postUID = post.uid else {
                return
            }
            
            //LOOK UP THE USER THAT LOADED POST
            self.fetchUser(uid:postUID, completed: {
                self.postsArray.insert(post, at: 0)   //<---newest post First/Top
                self.tableView.reloadData()
            })
        }
        
        //Get the posts that need not be shown
        SharedAPI.Feed.observeFeedRemoved(withID: currentUser.uid) { (post) in
            //test
            print(post)
            
            //**Remove those posts&users from the postsArray & usersArray using Filter***
            //filter-out posts(visible) & users(non visible) we're not following refer "feed" in database
            self.postsArray = self.postsArray.filter{ $0.id != post.id}
            self.usersArray = self.usersArray.filter{ $0.id != post.uid}
            self.tableView.reloadData()
        }
    }
    
    func fetchUser(uid:String, completed: @escaping()-> Void){
     SharedAPI.User.observeUser(withID: uid) { (user) in
        self.usersArray.insert(user, at: 0)   //<---newest post First/Top
        completed()
        }
    }
    
    
    //METHOD TO HANDLE LOGGING OUT
    @IBAction func logOutButton_Pressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInView")
            self.present(signInVC, animated: true, completion: nil)
            
        } catch let logoutError {
            print(logoutError)
        }
    
    }
    
    //PREPARE DATA(postID/userID) BEFORE SEGUE, THAT MIGHT BE NEEDED IN INCOMMING VIEW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue"{
          let commentVC = segue.destination as! CommentViewController
          let postID  = sender as! String
            commentVC.postID = postID
        }
        
        if segue.identifier == "Home_to_ProfileSegue"{
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId  = sender as! String
            profileUserVC.userID = userId
        }

    }
    
    
/////
} //END
/////

extension HomeViewController:UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Note: cast cell as our custom "HomeTableViewcell" for more customization
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        
        //GET POST&USERS FROM ARRAY
        let post = postsArray[indexPath.row]
        let user = usersArray[indexPath.row]
        cell.post = post
        cell.user = user
        //cell.homeVC = self
        cell.delegate = self
        return cell

    
    }
    
    
}

//EXTENTION TO ADOPT CUSTOM PROTOCOL FOR SWITCHING VIEWS FROM CELLS IN THE SUB-VIEW "HomeTableViewCell" 
extension HomeViewController:HomeTableViewCellDelegate{
    //implement protocol methods for swithcing view
    
    func goToCommentVC(postID: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postID)
    }
    
    func goToProfileUserVC(userID: String) {
        performSegue(withIdentifier: "Home_to_ProfileSegue", sender: userID)
    }
    
}

