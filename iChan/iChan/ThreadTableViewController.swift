//
//  ThreadTableViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/20/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

protocol ThreadLoadDelegate {
    func didFetchPost(index: Int, cell: ThreadTableViewCell)
    func didFetchImage(index: Int, cell: ThreadTableViewCell)
}

class ThreadTableViewController: UITableViewController, ThreadLoadDelegate {
    
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")
    
    var thread: Thread = Thread()
    var threadID: String!
    var threadLen: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // first add all the dummy values so the tableview is functional
        for _ in 1...threadLen {
            thread.posts.append(Post())
        }
        
        // here, we start to lazy load the entire thread
        loadThread()
    }
    
    func loadThread() {
        
        // sort based off of date
        let query = ref.child(threadID).queryOrdered(byChild: "date")
        
        // get all posts
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // go through each post
            var index: Int = 0
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                
                // create the post and add to the page
                let post = Post(snapshot: rest)
                self.thread.posts[index] = post
                
                // have to update cell at specified index
                let indexPath : IndexPath = IndexPath(item: index, section: 0)
                let cell = self.tableView.cellForRow(at: indexPath) as! ThreadTableViewCell
                
                cell.titleLabel.text = post.title
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
                cell.dateLabel.text = dateFormatter.string(from: post.date)
                
                cell.userIDLabel.text = post.userID
                cell.postTextLabel.text = post.text
                
                // since we cant get the image yet, we have to download it!
                self.didFetchPost(index: index, cell: cell)
                
                index = index + 1
            }
        }) { (error) in
            print(error.localizedDescription)
            // after everything is fully loaded, call the segue
        }
    }
    
    func didFetchPost(index: Int, cell: ThreadTableViewCell) {
        // grab the image just for the specific index
        downloadImage(index: index, cell: cell)
    }
    
    func downloadImage(index: Int, cell: ThreadTableViewCell) {
        let post = thread.posts[index]
        
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("images/\(post.userID).jpg")
        print("trying to get \(post.userID)")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                print("we in here")
                post.image = UIImage(data: data!)!
            }
            self.didFetchImage(index: index, cell: cell)
        }
    }
    
    func didFetchImage(index: Int, cell: ThreadTableViewCell) {
        cell.postImageView.image = thread.posts[index].image
        thread.posts[index].isEmpty = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return thread.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadCell", for: indexPath) as! ThreadTableViewCell
        
        // Configure the cell...
        let post = thread.posts[indexPath.row]
        
        if post.isEmpty == 1 {
            return cell
        }
        
        cell.titleLabel.text = post.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        cell.dateLabel.text = dateFormatter.string(from: post.date)
        
        cell.userIDLabel.text = post.userID
        cell.postTextLabel.text = post.text
        cell.postImageView.image = post.image
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
