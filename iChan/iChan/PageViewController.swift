//
//  PageViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/17/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPopoverPresentationControllerDelegate, BoardTableViewControllerDelegate, LaunchAppDelegate {
    
    var pages: [Page]?
    var orderedViewControllers: [PageTableViewController]?

    var eagarPageLoader: EagarPageLoader?
    
    var boardDict: [String : String] = ["tv" : "Television", "fit" : "Fitness", "pol" : "Politics"]
    
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
    
    func newPageTableViewController() -> PageTableViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "PageTableViewController") as! PageTableViewController
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    // we changed the board, so we consequently call the refresh method (lazy loading)
    func didFinishTask(sender: BoardTableViewController, newBoard: String) {
        // do stuff like updating the UI
        boardButton.title = newBoard
        refreshBoard()
    }
    
    func refreshBoard() {
        // fully load the users chosen board
        eagarPageLoader = EagarPageLoader()
        eagarPageLoader!.launchAppDelegate = self
        eagarPageLoader!.mainFetchLoop()
    }
    
    func didFinishLoading() {
        // clear our current pages, and get the new ones
        orderedViewControllers!.removeAll()
        let newPages = eagarPageLoader!.generatePages()
        print("size of newPages: \(newPages.count)")

        // remake all pages and put new page in each VC
        for i in 0..<newPages.count {
            orderedViewControllers!.append(newPageTableViewController())
            orderedViewControllers![i].page = newPages[i]
        }
        print("get here")
        // setup left/right swipe logic again
        self.setViewControllers([orderedViewControllers!.first!], direction: .forward, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        orderedViewControllers = []
        
        // get required # of pages
        for i in 0..<pages!.count {
            orderedViewControllers!.append(newPageTableViewController())
            orderedViewControllers![i].page = pages![i]
        }
        
        // setup left/right swiping logic
        if let firstViewController = orderedViewControllers!.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        // set initial board setting
        let defaults = UserDefaults.standard
        if let userBoard = defaults.string(forKey: "board") {
            boardButton.title = "/\(userBoard)/ - \(boardDict[userBoard]!)"
        }
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
        guard let viewControllerIndex = orderedViewControllers!.index(of: viewController as! PageTableViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers!.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers![previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers!.index(of: viewController as! PageTableViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers!.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers![nextIndex]
    }
}
