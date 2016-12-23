//
//  PageTableViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/17/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class PageTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, PreviewLoadDelegate {
    
    var page: Page?
    var currentIndex: Int?
    var currentLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        page!.previewLoadDelegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
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
        return page!.numPreviewThreads()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadCell", for: indexPath) as! ThreadTableViewCell

        // Configure the cell...
        let post = page!.getPost(index: indexPath.row)
        cell.titleLabel.text = post.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        cell.dateLabel.text = dateFormatter.string(from: post.date)
        
        cell.userIDLabel.text = post.userID
        cell.postTextLabel.text = post.text
        cell.postImageView.image = post.image
        
        currentIndex = indexPath.row
        
        // create tap gesture recognizer
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.textTapped(_:)))
        
        // add it to the image view;
        cell.postTextLabel.addGestureRecognizer(tapGesture)
        
        // make sure label can be interacted with by user
        cell.postTextLabel.isUserInteractionEnabled = true

        return cell
    }
    
    func textTapped(_ sender: UITapGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if let textLabel = sender.view as? UILabel {
            print("text tapped")
            currentLabel = textLabel
            page!.getPreviewPosts(index: currentIndex!)
        }
    }
    
    func didLoadPreviews(posts: [String]) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "PreviewTableViewController") as! PreviewTableViewController
        popoverContent.previews = posts
        popoverContent.modalPresentationStyle = .popover
        
        if let popover = popoverContent.popoverPresentationController {
            
            popoverContent.preferredContentSize = CGSize(width: 200,height: 250)
            
            popover.sourceView = currentLabel
            popover.delegate = self
        }
        
        self.present(popoverContent, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ThreadSegue" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let threadTableViewController = segue.destination as! ThreadTableViewController
                let newThread = Thread(pagePostIndex: row, threadID: page!.getPost(index: row).threadID, threadLen: page!.getPost(index: row).threadLen, mainPostID: page!.getPost(index: row).userID, currentPageView: self)
                threadTableViewController.thread = newThread
            }
        }
    }
}
