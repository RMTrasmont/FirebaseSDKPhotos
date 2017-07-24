//
//  PhotoCollectionViewCell.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/2/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit


//Declare Custom Delegate Protocol for switching view
protocol PhotoCollectionViewCellDelegate {
    
    func goToPhotoDetailVC(postID: String)
}


class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    
    var delegate:PhotoCollectionViewCellDelegate?
    
    var post:Post? {
        didSet{
            updateView()
        }
    }
    
    //MeThod to display the data in the posts inside the collection cell
    func updateView(){
        if let photoURLString = post?.photoURL {
            let photoURL = URL(string: photoURLString)
            photo.sd_setImage(with: photoURL)  //*SDWebImage
        }
        
        
        //ADD TAP GESTURE TO PHOTOS
        let tapGesture_Photo = UITapGestureRecognizer(target: self, action: #selector(self.photo_Touched))
        photo.addGestureRecognizer(tapGesture_Photo)
        photo.isUserInteractionEnabled = true

    }
    
    //HANDLE METHOD FOR TOUCHING PHOTO IN DISCOVER COLLECTION VIEW
    func photo_Touched(){
        //get post id of photo, then segue to that user's Profile view
        if let id = post?.id{
            //implement custom Delegate Method
            delegate?.goToPhotoDetailVC(postID: id)
            
        }
    }

/////
} ///
/////


