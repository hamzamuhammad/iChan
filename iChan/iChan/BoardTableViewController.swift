//
//  BoardTableViewController.swift
//  iChan
//
//  Created by Hamza Muhammad on 12/18/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

protocol BoardTableViewControllerDelegate: class {
    func didFinishTask(sender: BoardTableViewController, newBoard: String)
}

class BoardTableViewController: UITableViewController {
    
    var boards: [String] = ["tv", "fit", "pol"]
    var boardDescription: [String] = ["Television", "Fitness", "Politics"]
    var currentBoard: String = ""
    
    var selectedIndex: IndexPath?
    
    weak var boardTableViewControllerDelegate: BoardTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let defaults = UserDefaults.standard
        
        // set the current board
        if let userBoard = defaults.string(forKey: "board") {
            currentBoard = userBoard
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get the currently saved board
        let defaults = UserDefaults.standard
        
        // we do this whenever the board button is pressed
        defaults.set(boards[indexPath.row], forKey: "board")
        currentBoard = boards[indexPath.row]
        
        // put checkmark by selected value
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            // deselect previous cell
            if let oldCell = tableView.cellForRow(at: selectedIndex!) {
                oldCell.accessoryType = .none
            }
            selectedIndex = indexPath
        }
        
        let newBoard = "/\(boards[indexPath.row])/ - \(boardDescription[indexPath.row])"
        boardTableViewControllerDelegate?.didFinishTask(sender: self, newBoard: newBoard)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return boards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = "/\(boards[indexPath.row])/ - \(boardDescription[indexPath.row])"
        
        if currentBoard == boards[indexPath.row] {
            cell.accessoryType = .checkmark
            selectedIndex = indexPath
        }

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
