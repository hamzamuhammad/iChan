//
//  ThreadTableViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/20/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class ThreadTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, PostLoadDelegate {
    
    var thread: Thread?
    
    @IBOutlet weak var replyButton: UIBarButtonItem!
    
    @IBAction func newPost(_ sender: Any) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        // this should be used to call update maybe?
        popoverContent.thread = self.thread
        popoverContent.modalPresentationStyle = .popover
        
        if let popover = popoverContent.popoverPresentationController {
            
            popoverContent.preferredContentSize = CGSize(width: 270, height: 300)
            
            popover.barButtonItem = replyButton
            popover.delegate = self
        }
        
        self.present(popoverContent, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        

        
        thread!.postLoadDelegate = self
        
        // first add all the dummy values so the tableview is functional
        for _ in 1...thread!.len {
            thread!.posts!.append(Post())
        }
        
        // here, we start to lazy load the entire thread
        thread!.lazyLoad()
        
        // also, listen for new changes
        thread!.updateThread()
    }
    
    func reloadTable() {
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [
            IndexPath(item: self.thread!.posts!.count - 1, section: 0)
            ], with: .automatic)
        self.tableView.endUpdates()
        let indexPath : IndexPath = IndexPath(item: thread!.posts!.count - 1, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    
    func didLoadPost(index: Int) {
        let indexPath : IndexPath = IndexPath(item: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    
    func didLoadImage(index: Int) {
        let indexPath : IndexPath = IndexPath(item: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
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
        return thread!.posts!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadCell", for: indexPath) as! ThreadTableViewCell
        
        // Configure the cell...
        let post = thread!.posts![indexPath.row]
        
        cell.titleLabel.text = post.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        cell.dateLabel.text = dateFormatter.string(from: post.date)
        
        cell.userIDLabel.text = post.userID
        cell.postTextLabel.text = post.text
        
        // if the image hasn't been loaded, don't try to put it there!
        if post.isEmpty == 1 {
            return cell
        }
        
        if post.image != nil {
            // create tap gesture recognizer
            let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.imageTapped(_:)))
            
            // add it to the image view;
            cell.postImageView.addGestureRecognizer(tapGesture)
            
            // make sure imageView can be interacted with by user
            cell.postImageView.isUserInteractionEnabled = true
        }
        
        cell.postImageView.image = post.image
        
        return cell
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if let imageView = sender.view as? UIImageView {
            print("Image Tapped")
            
            //Here you can initiate your new ViewController
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "View Photo", style: .default, handler: { alertAction in
                // Handle View Photo here
                // perform segue to VC
                self.performSegue(withIdentifier: "ShowImageSegue", sender: imageView.image)
            }))
            alertController.addAction(UIAlertAction(title: "Save Photo", style: .default, handler: { alertAction in
                // Handle Save Photo
                UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { alertAction in
                // Cancel
            }))
            
            alertController.modalPresentationStyle = .popover
            alertController.preferredContentSize = CGSize(width: 200,height: 300)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
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
        if segue.identifier == "ShowImageSegue" {
            let imageViewController = segue.destination as! ImageViewController
            let image = sender as! UIImage
            imageViewController.currentImage = image
        }
    }

}
