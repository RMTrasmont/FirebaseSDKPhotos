//
//  CommentViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/27/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class CommentViewController: UIViewController {


    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    //FOR KEYBOARD-VIEW ADJUSTMENT
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    
    var postID:String!
    var commentsArray = [Comment]()
    var usersArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Comments"
        tableView.dataSource = self
        //HANDLE DYNAMIC CELL SIZE ADJUST
        tableView.estimatedRowHeight = 80 //<-est. max
        tableView.rowHeight = UITableViewAutomaticDimension
        emptyTextField()
        sendButton.isEnabled = false
        handleTextField()
        loadComments()

        
        //KEYBOARD SHOW NOTIFICATION
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:
             NSNotification.Name.UIKeyboardWillShow, object: nil)
        //KEYBOARD HIDE NOTIFICATION
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //SHOW TAB BAR
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //HIDE TAB BAR
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func keyboardWillShow(_ notification: Notification){
        print(notification)
        //Look for UIKeyboardFrameEndUserInfoKey in the print out. It infers height of keyboard when it shows up.
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        print(keyboardFrame as Any)
        
        //Adjust our Bottom-Constraint-IBOutlet of the UIUIView to the height of keyboard to not block view holding the comment textfield
        UIView.animate(withDuration: 0.5) {
            self.constraintToBottom.constant = keyboardFrame!.height
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(_ notification:Notification){
        print(notification)
        //push the view holing the comment textfield back to original location
        UIView.animate(withDuration: 0.5) {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
        }    }
    
    //DELEGATE METHOD TO DETECT TOUCHES ON THE VIEW ...USE TO DISMISS KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Method Causes the view (or one of its embedded text fields) to resign the first responder status thus hiding the keyboard.
        
        view.endEditing(true)
        
    }
    
    
    
    //METHOD LOAD ALL COMMENTS TO POST WHEN COMMENTS IS VIEWED USING
    func loadComments(){
        let post_comment_ref = SharedAPI.Post_Comment.REF_POST_COMMENTS.child(self.postID)
        
        post_comment_ref.observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            print(snapshot.key) //<--is commentID
            
            SharedAPI.Comment.observeComments(withPostID: snapshot.key, completion: { (comment) in
                self.fetchUser(uid:comment.uid!, completed: {
                    self.commentsArray.append(comment)
                    self.tableView.reloadData()
            })
                
            })
        })
        
    }
    
    func fetchUser(uid:String, completed: @escaping()-> Void){
        SharedAPI.User.observeUser(withID: uid) { (user) in
            self.usersArray.append(user)
            completed()
        }
    }
    
    
    //I.
    func handleTextField(){
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        
    }
    //II.
    func textFieldDidChange(){
        if let commentText = commentTextField.text , !commentText.isEmpty{
            sendButton.setTitleColor(UIColor.green , for: UIControlState.normal)
            sendButton.isEnabled = true
            return
        }
        sendButton.setTitleColor(UIColor.red , for: UIControlState.normal)
        sendButton.isEnabled = false
    }
    
    
    @IBAction func sendButton_Touched(_ sender: UIButton) {
        let commentsReference = SharedAPI.Comment.REF_COMMENTS
        let newCommentID = commentsReference.childByAutoId().key
        let newCommentReference = commentsReference.child(newCommentID)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserID = currentUser.uid
        newCommentReference.setValue(["uid": currentUserID, "commentText": commentTextField.text!], withCompletionBlock: {
            (error, ref) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            let postCommentRef = SharedAPI.Post_Comment.REF_POST_COMMENTS.child(self.postID).child(newCommentID)
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error.debugDescription)
                    return
                }
            })
            self.emptyTextField()
            self.view.endEditing(true)  //<--- dismiss keyboard
        })
        
    }
    
    func emptyTextField(){
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
        self.sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
    }
    
    
    //PREPARE DATA(postID/userID) BEFORE SEGUE, THAT MIGHT BE NEEDED IN INCOMMING VIEW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Comment_to_ProfileSegue"{
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId  = sender as! String
            profileUserVC.userID = userId
        }
        
    }


////
} ///END
////


extension CommentViewController:UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Note: cast cell as our custom "CommentTableViewcell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
    
    
        //GET COMMENTS&USERS FROM ARRAY
        let comment = commentsArray[indexPath.row]
        let user = usersArray[indexPath.row]
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        return cell
    }
    
}

extension CommentViewController:CommentTableViewCellDelegate{
    func goToProfileUserVC(userID: String) {
           performSegue(withIdentifier: "Comment_to_ProfileSegue", sender: userID)
    }
}


