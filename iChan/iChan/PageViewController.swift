//
//  PageViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/17/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPopoverPresentationControllerDelegate {
    
    private(set) lazy var orderedViewControllers: [UITableViewController] = {
        return [self.newPageTableViewController(),
                self.newPageTableViewController(),
                self.newPageTableViewController()]
    }()
    
    private func newPageTableViewController() -> UITableViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "PageTableViewController") as! UITableViewController
    }
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var boardButton: UIBarButtonItem!
    
    @IBAction func changeBoard(_ sender: Any) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "BoardTableViewController") as! UITableViewController
        popoverContent.modalPresentationStyle = .popover
        
        if let popover = popoverContent.popoverPresentationController {
            
//            let viewForSource = sender as! UIButton
//            popover.sourceView = viewForSource
//            
//            // the position of the popover where it's showed
//            popover.sourceRect = viewForSource.bounds
            
            // the size you want to display
            popoverContent.preferredContentSize = CGSize(width: 200,height: 300)
            
            popover.barButtonItem = boardButton
            popover.delegate = self
        }
        
        self.present(popoverContent, animated: true, completion: nil)
    }
    
   func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        pageControl.numberOfPages = orderedViewControllers.count
        pageControl.currentPage = 0
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
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! UITableViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        pageControl.currentPage = previousIndex
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! UITableViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            pageControl.currentPage = 0
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        pageControl.currentPage = nextIndex
        return orderedViewControllers[nextIndex]
    }
}
