//
//  ProfileUserViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/5/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//
//COPIED FROM PROFILE VIEW CONTROLLER W/ SOME CHANGES

import UIKit
import FirebaseAuth
class ProfileUserViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var user: User!
    var postsArray: [Post] = []
    var userID = ""   //<--- set at Segue
    
    var delegate:HeaderProfileCollectionReusableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("USERID** \(userID)")
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        fetchUserPosts()
    }

    func fetchUser(){
        
        //IF Theres a user, create instance of a user with values from database, then set that usr as our global var
        
        SharedAPI.User.observeUser(withID: userID) { (user) in
            
            //And Check is current user follows this user(value=bool)
            self.isFollowing(userID: user.id!, completed: { (value) in
                user.isFollowing = value
                self.user = user
                self.navigationItem.title = user.username
                self.collectionView.reloadData()
            })
        }
    }
        
    
    //CHECK IF CURRENT-USER IS FOLLOWING THE VIEWED USER
    func isFollowing(userID: String,completed:@escaping (Bool) -> Void){
        SharedAPI.Follow.isFollowing(userId: userID, completed: completed)
    }
    
    
    func fetchUserPosts(){
        
        //Get user key/ID to user-Posts database
        
        SharedAPI.User_Posts.fetchMyPost(userId: userID) { (key) in
            
            //Use the posts data and convert to post objects
            
            SharedAPI.Post.observePost(withID: key, completion: { (post) in
                print(post.id as Any)
                //Add posts to the array
                self.postsArray.append(post)
                self.collectionView.reloadData()
            })
        }
    }
    
    //PREPARE DATA(postID/userID) BEFORE SEGUE, THAT MIGHT BE NEEDED IN INCOMMING VIEW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ProfileUser_to_DetailSegue"{
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postID = postId
        }
        
    }

    
/////
}  ///
/////


//DATA-SOURCE PROTOCOL FOR UICOLLECTIONVIEW
extension ProfileUserViewController: UICollectionViewDataSource {
    
    //Delegate method to handle number of items in section for the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    //Delegate Method to handle what goes in to to which cell...Note: cast to our custom cell class
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Cast cell to our custom PhotoCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        //Get posts from the array
        let post = postsArray[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
    
    //Supply Header to Collection View Delegate Method then cast it to our custom HeaderProfileCollectionReusableView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        
        //check if the viewer of the profile is the current-user
        if let user = self.user {
            headerViewCell.user = user
            headerViewCell.delegate = self.delegate
            headerViewCell.delegateTwo = self   //<--- Delegate method to go to profile settings
        }
        
        
        return headerViewCell
    }
    
}

//DELEGATE-PROTOCOL OF THE COLLECTIONVIEW FOR CUSTOMIZING THE LAYOUT
extension ProfileUserViewController:UICollectionViewDelegateFlowLayout{
    
    //Size of each cell (about 1/3 of screen width, display 3 on each row) "sizeForItemAt"
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width)/3
        let height = (collectionView.frame.size.width)/3  //<--- use width b/c making a Square
        return CGSize(width: width - 1 , height: height)  //<--- subtract the spacings to adjust b/c View w&h are diff.
    }
    
    //Distance vertically from ceach cell "minimumLineSpacingForSectionAt"
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    
    //Distance horizinatally from each cell "minimumInteritemSpacingForSectionAt"
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

//DELEGATE going from Current user's profile to settings page
extension ProfileUserViewController:HeaderProfileCollectionReusableViewGoSettingsVCDelegate{
    func goToSettingsVC() {
        performSegue(withIdentifier: "ProfileUser_to_SettingsSegue", sender: nil)  //<--- nil b/c we/re not sending anything to that view
    }
}

//DELEGATE going from NonCurrent-User-Profile-Post to Post-Detail
extension ProfileUserViewController:PhotoCollectionViewCellDelegate{
    func goToPhotoDetailVC(postID: String) {
        performSegue(withIdentifier: "ProfileUser_to_DetailSegue", sender: postID)
    }
}
    





