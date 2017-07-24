//
//  HomeTableViewCell.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/25/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

//Declare Custom Delegate Protocol for switching view
protocol HomeTableViewCellDelegate {
    
    func goToCommentVC(postID:String)
    func goToProfileUserVC(userID: String)
}

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel:UILabel!
    
    //Setup Delegate Property
    var delegate:HomeTableViewCellDelegate?
    
    //var homeVC: HomeViewController?
    
    var postRef:DatabaseReference!
    
    
    
    //Note: call method whenever we assign to a "post"/"user" Variable
    var post: Post? {
        didSet{
            updateView()
        }
    }
    
    var user:User? {
        didSet{
            setUpUserInfo()
        }
    }
    
    //METHOD USED IN HOMEVIEWCONTROLLER EXTENSION "CELL FOR ROW AT INDEX PATH"
    func updateView(){
        
        //print(post?.id)
        
        //UPDATE PHOTO-POSTED AND CAPTION
        captionLabel.text = post?.photo_caption
        if let photoURLString = post?.photoURL {
            let photoURL = URL(string: photoURLString)
            postImageView.sd_setImage(with: photoURL)  //*SDWebImage
        }
        
        
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (timer) in
            //UPDATE LIKE ICON AFTER OBSERVING POST DATA, IF OBSERVER SEE CHANGE IT WILL RETURN A SNAPSHOT
            
            SharedAPI.Post.REF_POSTS.child(self.post!.id!).observe(.value, with: { (snapshot) in
                if let dict = snapshot.value as? [String:Any]{
                    let post = Post.transformPost(dict: dict, key: snapshot.key)
                    self.updateLikes(post: post)
                }
            })
            
            
            //Detect changes in database and let cell actively observe the post and update itself for likes, note that if there are changes we will recieve a snapshot back reflecting the change,then use the changes to update the likes view
            
            SharedAPI.Post.REF_POSTS.child(self.post!.id!).observe(.childChanged, with: { (snapshot) in
                if let dataValue = snapshot.value as? Int{
                    self.likeCountButton.setTitle("\(dataValue) likes", for:  UIControlState.normal)
                }
            })
        }
        

        
        //HANDLE TIME-STAMP
        if let timeStamp = post?.timeStamp{
            print(timeStamp)
            let timeStampDate = Date(timeIntervalSince1970: Double(timeStamp))
            let nowDate = Date()
            let timeStampComponents = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let timeDiff = Calendar.current.dateComponents(timeStampComponents, from: timeStampDate, to: nowDate)
            //test
            //print("TIME DIFF: \(timeDiff)")
            //print("SEC TIME: String(describing: \(timeDiff.seco)nd) ")
            
            var timeText = ""
            
            if timeDiff.second! <= 0 {
                timeText = "Now"
            }
            
            if timeDiff.second! > 0 && timeDiff.minute! == 0{
                timeText = (timeDiff.second == 1) ? "\(timeDiff.second!) seconds ago" : "\(timeDiff.second!) seconds ago"
            }
            
            if timeDiff.minute! > 0 && timeDiff.hour! == 0{
                timeText = (timeDiff.minute == 1) ? "\(timeDiff.minute!) minutes ago" : "\(timeDiff.minute!) minutes ago"
            }
            
            if timeDiff.hour! > 0 && timeDiff.day! == 0{
                timeText = (timeDiff.hour == 1) ? "\(timeDiff.hour!) hours ago" : "\(timeDiff.hour!) hours ago"
            }
            
            if timeDiff.day! > 0 && timeDiff.weekOfMonth! == 0{
                timeText = (timeDiff.day == 1) ? "\(timeDiff.day!) days ago" : "\(timeDiff.day!) days ago"
            }
            
            if timeDiff.weekOfMonth! > 0 {
                timeText = (timeDiff.weekOfMonth == 1) ? "\(timeDiff.weekOfMonth!) weeks ago" : "\(timeDiff.weekOfMonth!) weeks ago"
            }
            
            
            timeStampLabel.text = timeText
            
        }
        
    
    
    }
    
    func updateLikes(post:Post){
        //test
        print(post.isLiked as Any)
       
        //let imageName bet set "like" if either/or the the two post cases are true, if not its set to "likeSelected"
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImageView.image = UIImage(named: imageName)
        
        //Extract like count from post and check if its not zero, we only want to show non zero for like count
        guard let count = post.likeCount else {return}
        if count != 0 {
           likeCountButton.setTitle("\(count) likes 🤘🏼", for: UIControlState.normal)
        } else {
            likeCountButton.setTitle("Yo, No one likes your post, Son! 😂", for: UIControlState.normal)
        }
        
    }
    
    //METHOD TO PROFILE IMAGE AND LABELS
    func setUpUserInfo(){
        nameLabel.text = user?.username
        if let photoURLString = user?.profileImageURL {
            let photoURL = URL(string: photoURLString)
            profileImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "default_avatar"))
        }
    }
    
    // NOTE: awakeFromNib works like viewDidLoad for tableViewCells...also things inside can't be called when cells are reused, such as setting initial blank string values
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //SET INITIAL CONTENT OF NAME LABEL AND CAPTION LABEL
        nameLabel.text = ""
        captionLabel.text = ""
        
        //ADD TAP GESTURE TO COMMENT IMAGE VIEW SYMBOL
        let tapGesture_Comment = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_Touched))
        commentImageView.addGestureRecognizer(tapGesture_Comment)
        commentImageView.isUserInteractionEnabled = true
        
        //ADD TAP GESTURE TO LIKE IMAGE VIEW SYMBOL
        let tapGesture_Like = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_Touched))
        likeImageView.addGestureRecognizer(tapGesture_Like)
        likeImageView.isUserInteractionEnabled = true
        
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
    
    
    
    //HANDLE COMMENTS ICON PRESSED
    func commentImageView_Touched(){
        print("TEST commentImageView_Touched")

        if let id = post?.id{
            //let Delegate implement switching view
            delegate?.goToCommentVC(postID: id)
        }
    }
    
    
    //HANDLE LIKE ICON PRESSED
    func likeImageView_Touched(){
        
        //SET LIKE ICON IF CURRENT USER HAS ALREADY* LIKED A POST .(SCALABLE WAY) USING Firebase .runTransactionBlock
        //Go to the Particular Post in database
        
        postRef = SharedAPI.Post.REF_POSTS.child(post!.id!)
        incrementLikes(forRef: postRef)
        
        
        
    }
    
    
    func incrementLikes(forRef ref: DatabaseReference){
        //FIREBASE METHOD FOR "TRANSACTION OPERATION" TO HANDLE LIKES
        //Replace "stars"&"starCount" to "likes"&"likeCount"
        
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                print("VALUE BEFORE: \(post)")
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            print("VALUE AFTER: \(String(describing: snapshot?.value))")
            //Extract Value for likes After to Update the likes in Post
            if let dataDict = snapshot?.value as? [String:Any]{
                let post = Post.transformPost(dict: dataDict, key: snapshot!.key)
                self.updateLikes(post: post)
            }
        }
    

///////
    } ////
///////
    
    
    
    //NOTE:prepareForReuse() preps a reusable cell for reuse/display data before deque
    
    override func prepareForReuse() {
        super .prepareForReuse()
        
        profileImageView.image = UIImage(named: "default_avatar")
        
    }
    


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
