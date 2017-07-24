//
//  ProfileViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/21/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import FirebaseAuth
class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    var postsArray: [Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        fetchUserPosts()
    }


    func fetchUser(){
        
        //IF Theres a current user, create instance of a user with values from database, then set that usr as our global var
        
        SharedAPI.User.observeCurrentUser { (user) in
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
            }
        }
    
    
    func fetchUserPosts(){
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
         //Get snapshot using current-User ID
        SharedAPI.User_Posts.REF_USER_POSTS.child(currentUser.uid).observe(.childAdded, with: { (snapshot) in
          
            //Use a snapshot key to return a post belonging to current-user
            SharedAPI.Post.observePost(withID: snapshot.key, completion: { (post) in
                print(post.id as Any)
                self.postsArray.append(post)
                self.collectionView.reloadData()
            })
        })
        
    }
    
    
    //PREPARE DATA(postID/userID) BEFORE SEGUE, THAT MIGHT BE NEEDED IN INCOMMING VIEW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile_to_SettingsSegue"{
            let settingsVC = segue.destination as! SettingsTableViewController
            settingsVC.delegate = self
        }
        
        if segue.identifier == "Profile_to_DetailSegue"{
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postID = postId
        }
        
    }
    
    
////
} ///
////

//DATA-SOURCE PROTOCOL FOR UICOLLECTIONVIEW
extension ProfileViewController: UICollectionViewDataSource {
    
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
        
        if let user = self.user {
            headerViewCell.user = user
            headerViewCell.delegateTwo = self   //<--- Delegate method to go to profile settings
        }
        
        
        return headerViewCell
    }
    
}



//DELEGATE-PROTOCOL OF THE COLLECTIONVIEW FOR CUSTOMIZING THE LAYOUT
extension ProfileViewController:UICollectionViewDelegateFlowLayout{
    
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

//DELEGATE Extension for delegate2
extension ProfileViewController:HeaderProfileCollectionReusableViewGoSettingsVCDelegate{
    func goToSettingsVC() {
        performSegue(withIdentifier: "Profile_to_SettingsSegue", sender: nil)  //<--- nil b/c we/re not sending anything to that view
    }
}

//DELEGATE Extensioin for ADOPTING SettingsViewControllerDelegate so we can update display of username & image after leavig settings
extension ProfileViewController:SettingsTableViewControllerDelegate{
    func updateUserInfos() {
        self.fetchUser()
    }
}

//DELEGATE Extension for Moving from  ProfilePhotos to DetailView of photo
extension ProfileViewController:PhotoCollectionViewCellDelegate{
    func goToPhotoDetailVC(postID: String){
        performSegue(withIdentifier: "Profile_to_DetailSegue", sender: postID)
    }
}
