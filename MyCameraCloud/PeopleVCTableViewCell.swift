//
//  PeopleVCTableViewCell.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/3/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
//import FirebaseAuth

//Declare custom Protocol
protocol PeopleVCTableViewCellDelegate{
    func goToProfileUserVC(userID:String)
}

class PeopleVCTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    
    //Create Delegate
    var delegate:PeopleVCTableViewCellDelegate?
    
    //var peopleVC:PeopleViewController?
    
    var user:User? {
        didSet{
          updateView()
        }
    }
    
    func updateView(){
        nameLabel.text = user?.username
        if let photoURLString = user?.profileImageURL {
            let photoURL = URL(string: photoURLString)
            profileImage.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "default_avatar"))
        }
        
//        //See if viewed user is being followed by current user

//        SharedAPI.Follow.isFollowing(userId: user!.id!) { (value) in
//            if value == true {
//               self.configureUnFollowButton()
//            } else {
//                self.configureFollowButton()
//            }
//        }
//     
        //See if user in cell is being followed by current user
        if user!.isFollowing! {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
        

    }
    
    
    func configureFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
//        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        followButton.backgroundColor = UIColor(red: 0.44, green: 0.44, blue: 0.57, alpha: 1)
        followButton.setTitle("Follow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureUnFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.clear
        followButton.setTitle("Unfollow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    func followAction() {
        if user!.isFollowing! == false {
            SharedAPI.Follow.followAction(withUser: user!.id!) // @FollowAPI set Follow/Following
            configureUnFollowButton()
            user!.isFollowing! = true
        }
    }
    
    func unFollowAction() {
        if user!.isFollowing! == true {
            SharedAPI.Follow.unfollowAction(withUser: user!.id!) // @FollowAPI remove Follow/Followin
            configureFollowButton()
            user!.isFollowing! = false
        }
    }

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //ADD TAP GESTURE TO NAME LABEL IN THE CELL
        let tapGesture_Comment = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_Touched))
        nameLabel.addGestureRecognizer(tapGesture_Comment)
        nameLabel.isUserInteractionEnabled = true
        
    }
    
    func nameLabel_Touched(){
        //get user id of user in the cell, then segue to that user's Profile view
        if let id = user?.id{
            //implement custom Delegate Method
            delegate?.goToProfileUserVC(userID: id)
            
            //peopleVC?.performSegue(withIdentifier: "ProfileSegue", sender: id)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
