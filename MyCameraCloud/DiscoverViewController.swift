//
//  DiscoverViewController.swift
//  MyCameraCloud
//
//  Created by Rafael M. Trasmontero on 6/21/17.
//  Copyright © 2017 TurnToTech. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var postsArray:[Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //loadTopPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTopPosts()
    }

    //Load Posts with most likes
    func loadTopPosts(){
        //first remove all cached data tha might be in postsArray
        self.postsArray.removeAll()
        self.collectionView.reloadData()
        //get most popular posts
        SharedAPI.Post.observeTopPosts { (post) in
            //cache to array
            self.postsArray.append(post)
            self.collectionView.reloadData()
        }
    }
    
    
    //PREPARE DATA(postID/userID) BEFORE SEGUE, THAT MIGHT BE NEEDED IN INCOMMING VIEW ie. postID for photo needed in Details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Discover_to_DetailSegue"{
            let detailVC = segue.destination as! DetailViewController
            let postId  = sender as! String
            detailVC.postID = postId
        }
        
    }
    
    
    
////
}  ///
////


//DATA-SOURCE PROTOCOL FOR UICOLLECTIONVIEW
extension DiscoverViewController: UICollectionViewDataSource {
    
    //Delegate method to handle number of items in section for the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    //Delegate Method to handle what goes in to to which cell...Note: cast to our custom cell class
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Cast cell to our custom PhotoCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        //Get posts from the array
        let post = postsArray[indexPath.row]
        cell.post = post
        
        //set cell(PhotoCollectionViewCell) delegate  as self(DiscoverViewController)
        cell.delegate = self
        
        return cell
    }
        
}

//DELEGATE-PROTOCOL OF THE COLLECTIONVIEW FOR CUSTOMIZING THE LAYOUT
extension DiscoverViewController :UICollectionViewDelegateFlowLayout{
    
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

//EXTENTION TO ADOPT CUSTOM PROTOCOL FOR SWITCHING VIEWS FROM PHOTO CELL IN THE SUB-VIEW  TO  DETAILS OF PHOTO

extension DiscoverViewController:PhotoCollectionViewCellDelegate{
    
    //implement protocol methods for swithcing to photo details page and send(er) with it the info postID ...prepare for segue next
    func goToPhotoDetailVC(postID: String) {
        performSegue(withIdentifier: "Discover_to_DetailSegue", sender: postID)
    }
    
    
    
}
