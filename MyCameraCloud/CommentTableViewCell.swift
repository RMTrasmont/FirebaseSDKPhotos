//
//  CommentTableViewCell.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/27/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit

//Declare Custom Delegate Protocol for switching view
protocol CommentTableViewCellDelegate {
    
    func goToProfileUserVC(userID: String)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    //Setup Delegate Property
    var delegate:CommentTableViewCellDelegate?
    
    var comment: Comment?{
        didSet{
            updateView()
        }
    }
    
    var user: User? {
        didSet{
            setupUserInfo()
        }
    }
    
    func updateView(){
        commentLabel.text = comment?.commentText
    }
    
    func setupUserInfo(){
        nameLabel.text = user?.username
        if let photoURLString = user?.profileImageURL{
            let photoURL = URL(string: photoURLString)
            profileImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "default_avatar"))
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //place holders for cell for safety while awaiting for data to load for first time
        nameLabel.text = ""
        commentLabel.text = ""
        
        //ADD TAP GESTURE TO NAME LABEL IN THE CELL
        let tapGesture_NameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_Touched))
        nameLabel.addGestureRecognizer(tapGesture_NameLabel)
        nameLabel.isUserInteractionEnabled = true
    }
    
    //HANDLE METHOD FOR TOUCHING NAME LABEL
    func nameLabel_Touched(){
        //get user id of user in the cell, then segue to that user's Profile view
        if let id = user?.id{
            //implement custom Delegate Method
            delegate?.goToProfileUserVC(userID: id)
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //place holders for cell for safety while awaiting for data to load for first time
        profileImageView.image = UIImage(named: "default_avatar")
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
