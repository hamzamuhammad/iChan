//
//  PageViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/17/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

protocol RefreshBoardDelegate {
    func didFetchPosts()
    func didFetchImage(index: Int)
}

class PageViewController: UIPageViewController, UIPopoverPresentationControllerDelegate, BoardTableViewControllerDelegate, RefreshBoardDelegate {
    
    let ref = FIRDatabase.database().reference()
    
    // Create a storage reference from our storage service
    let storageRef = FIRStorage.storage().reference(forURL: "gs://ichan-ec477.appspot.com")
    
    var pages: [Page] = []
    var tempPosts: [Post] = []
    
    private var boardDict: [String : String] = ["tv" : "Television", "fit" : "Fitness", "pol" : "Politics"]
    
    var orderedViewControllers: [PageTableViewController] = []
    
    private func newPageTableViewController() -> PageTableViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "PageTableViewController") as! PageTableViewController
    }
    
    @IBOutlet var boardButton: UIBarButtonItem!
    
    @IBAction func changeBoard(_ sender: Any) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "BoardTableViewController") as! BoardTableViewController
        popoverContent.boardTableViewControllerDelegate = self
        popoverContent.modalPresentationStyle = .popover
        
        if let popover = popoverContent.popoverPresentationController {
            
            popoverContent.preferredContentSize = CGSize(width: 200,height: 300)
            
            popover.barButtonItem = boardButton
            popover.delegate = self
        }
        
        self.present(popoverContent, animated: true, completion: nil)
    }
    
    @IBAction func refreshCurrentBoard(_ sender: Any) {
        refreshBoard()
    }
    
    func refreshBoard() {
        
        var currentBoard: String = ""
        let defaults = UserDefaults.standard
        if let userBoard = defaults.string(forKey: "board") {
            currentBoard = userBoard
        }
        
        // now, with this board, grab the data:
        // sort based off of date
        let query = ref.child("pages").child(currentBoard).queryOrdered(byChild: "date")
        
        // get the newest 5 posts for a certain board
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // go through each post
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                
                // create the post and add to the page
                let post = Post(snapshot: rest)
                self.tempPosts.append(post)
            }
            
            // after everything is fully loaded, notify delegate
            if self.tempPosts.count > 0 {
                self.didFetchPosts()
            }
        }) { (error) in
            print(error.localizedDescription)
            // after everything is fully loaded, call the segue
        }
    }
    
    func didFetchPosts() {
        // loop through each post
        downloadImage(index: 0)
    }
    
    func didFetchImage(index: Int) {
        if index + 1 < self.tempPosts.count {
            downloadImage(index: index + 1)
        }
        else if index + 1 == self.tempPosts.count {
            orderedViewControllers.removeAll()
            let newPages = generatePages()
            self.tempPosts.removeAll()
            if newPages.count > 0 {
                for i in 0..<newPages.count {
                    orderedViewControllers.append(newPageTableViewController())
                    orderedViewControllers[i].page = newPages[i]
                }
            }
            self.setViewControllers(orderedViewControllers, direction: .forward, animated: true, completion: nil)
        }
    }
    
    func downloadImage(index: Int) {
        let post = self.tempPosts[index]
        
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("images/\(post.userID).jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                post.image = UIImage(data: data!)!
            }
            self.didFetchImage(index: index)
        }
    }
    
    func generatePages() -> [Page] {
        var numPages: Int = 0
        
        if self.tempPosts.count % 5 == 0 {
            numPages = self.tempPosts.count / 5
        }
        else {
            numPages = self.tempPosts.count / 5 + 1
        }
        
        var pages: [Page] = []
        
        var index: Int = self.tempPosts.count - 1
        for i in 0..<numPages {
            pages.append(Page())
            
            var lim: Int = 5
            // add to a page
            while index >= 0 && lim > 0 {
                pages[i].threadPreviews.append(self.tempPosts[index])
                index = index - 1
                lim = lim - 1
            }
        }
        return pages
    }

    // we changed the board, so we consequently call the refresh method (lazy load)
    func didFinishTask(sender: BoardTableViewController, newBoard: String) {
        // do stuff like updating the UI
        boardButton.title = newBoard
        refreshBoard()
    }
    
   func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        
        // get required # of pages
        for i in 0..<pages.count {
            orderedViewControllers.append(newPageTableViewController())
            orderedViewControllers[i].page = pages[i]
        }
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        let defaults = UserDefaults.standard
        if let userBoard = defaults.string(forKey: "board") {
            boardButton.title = "/\(userBoard)/ - \(boardDict[userBoard]!)"
        }
        
        print("got here with: \(pages.count)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! PageTableViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! PageTableViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
