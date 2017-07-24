//
//  PeopleViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 7/3/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {
    
    var usersArray:[User] = []
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUsers()

        // Do any additional setup after loading the view.
    }

    
    
    
    //GET USERS FROM DATABASE AND CACHE INTO ARRAY
    func loadUsers(){
        SharedAPI.User.observeUsers { (user) in
            self.isFollowing(userID: user.id!, completed: { (value) in
                user.isFollowing = value
                self.usersArray.append(user)
                self.tableView.reloadData()
            })
 
        }
    }
    
    
    //CHECK IF CURRENT-USER IS FOLLOWING THE VIEWED USER
    func isFollowing(userID: String,completed:@escaping (Bool) -> Void){
        SharedAPI.Follow.isFollowing(userId: userID, completed: completed)
    }
    
    //PREPARE SEGUE TO THE USER PROFILE TO VISIT & PASS DATA TO UPCOMMING VIEW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSegue"{
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId  = sender as! String
            profileUserVC.userID = userId
            profileUserVC.delegate = self
        }
    }
    
/////
}   ////
/////

extension PeopleViewController:UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Note: cast cell as our custom "PeopleTableViewcell" for more customization
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleVCTableViewCell", for: indexPath) as! PeopleVCTableViewCell
        let user = usersArray[indexPath.row]
        
        cell.user = user
        
        //set cell property peopleVC as self/"PeopleViewController" To visit user profile
        //cell.peopleVC = self
        
        //set cell as delegate of this view
        cell.delegate = self
        
        return cell
        
        
    }
    
    
}

//Extension to let this View adopt the custom protocolof the subview "PeopleVCTableViewCell"

extension PeopleViewController:PeopleVCTableViewCellDelegate{
    //define the delegate method
    func goToProfileUserVC(userID:String){
        performSegue(withIdentifier: "ProfileSegue", sender: userID)
    }
}


//Extension adopting HeaderProfileCollectionReusableViewDelegate to know the status of the un/follow button
extension PeopleViewController:HeaderProfileCollectionReusableViewDelegate{
    
    func updateFollowButton(forUser user: User) {
        for aUser in self.usersArray{
            if aUser.id == user.id{
                aUser.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}
