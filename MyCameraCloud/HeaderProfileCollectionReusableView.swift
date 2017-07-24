//
//  HeaderProfileCollectionReusableView.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/1/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import FirebaseAuth

//Set up Delegate for this view so Any View wanting to know of FollowButton status,simply needs to be a delegate of HeaderProfileCollectionReusableView and implement its protocol

protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user:User)
}

//Set protocol that will make delegate call method to segue to settings view
protocol HeaderProfileCollectionReusableViewGoSettingsVCDelegate{
    func goToSettingsVC()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    //Connected to BOTH edit/follow button in Profile AND Edit Profile
    @IBOutlet weak var followOrEditButton: UIButton!
    
    var delegate:HeaderProfileCollectionReusableViewDelegate?
    var delegateTwo: HeaderProfileCollectionReusableViewGoSettingsVCDelegate?
    
    
    var user:User?{
        didSet{
           updateView()
        }
    }
    
    
    
    func updateView(){
        
        //Update PorifilePhoto & Name
        self.nameLabel.text = user!.username
        if let photoURLString = user!.profileImageURL{
            let photoURL = URL(string: photoURLString)
            self.profileImage.sd_setImage(with: photoURL)
        }
        
        //Update Post-Count
        SharedAPI.User_Posts.fetchCountUserPosts(userId: user!.id!) { (count) in
            self.postCountLabel.text = "\(count)"
        }
        
        //Update Following Count
        SharedAPI.Follow.fetchFollowingCount(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        
        //Update Follower Count
        SharedAPI.Follow.fetchFollowerCount(userId: user!.id!) { (count) in
            self.followersCountLabel.text = "\(count)"
        }
        
        
        //If Current-User views own profile show "editButton" , if NOT Show "Follow/UnFollow" Button
        guard let currentUser = Auth.auth().currentUser else {return}
        
        if user?.id == currentUser.uid {
            followOrEditButton.setTitle("Edit Profile", for: .normal)
            
            //Action to go to current-user settings when button is "edit button" and not "un/follow"
            followOrEditButton.addTarget(self, action: #selector(self.goToSettingsVC), for: .touchUpInside)
            
        }else{
            //updateState to show follow or unfollow
            updateStatusFollowButton()
        }
        
        
    
    }
    
    
    func goToSettingsVC(){
        delegateTwo?.goToSettingsVC()
    }
    
    

    func updateStatusFollowButton(){
        //See if the user profile being is followed by current user
        
        if user!.isFollowing! {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
    
    }
    
    func configureFollowButton() {
        followOrEditButton.layer.borderWidth = 1
        followOrEditButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followOrEditButton.layer.cornerRadius = 5
        followOrEditButton.clipsToBounds = true
        
        followOrEditButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followOrEditButton.backgroundColor = UIColor(red: 0.44, green: 0.44, blue: 0.57, alpha: 1)
        followOrEditButton.setTitle("Follow", for: UIControlState.normal)
        followOrEditButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureUnFollowButton() {
        followOrEditButton.layer.borderWidth = 1
        followOrEditButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followOrEditButton.layer.cornerRadius = 5
        followOrEditButton.clipsToBounds = true
        
        followOrEditButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followOrEditButton.backgroundColor = UIColor.clear
        followOrEditButton.setTitle("Unfollow", for: UIControlState.normal)
        followOrEditButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    func followAction() {
        if user!.isFollowing! == false {
            SharedAPI.Follow.followAction(withUser: user!.id!) // @FollowAPI set Follow/Following
            configureUnFollowButton()
            user!.isFollowing! = true
            //Let anyview know to update un/follow status
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    func unFollowAction() {
        if user!.isFollowing! == true {
            SharedAPI.Follow.unfollowAction(withUser: user!.id!) // @FollowAPI remove Follow/Followin
            configureFollowButton()
            user!.isFollowing! = false
            //Let any view know to update un/follow status
            delegate?.updateFollowButton(forUser: user!)
        }
    }

////
} ///
///
