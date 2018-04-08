//
//  ExercisesTableViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 04/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

class ExercisesTableViewController: UITableViewController {

    var routine : Routine!

    override func viewDidLoad() {

        super.viewDidLoad()

        var title : String = routine.name!

        if let summary = routine.summary {
            title = title + ", " + summary
        }

        navigationItem.title = title
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let count = routine.items?.count ?? 0

        if count == 0 {
            setEmptyState(identifier: "Empty State", intoContainer: tableView)
        } else {
            removeEmptyState()
        }

        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Exercise"),
            let item = routine.items?[indexPath.row] as? Item else {
            return UITableViewCell()
        }

        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.repetitions)/\(item.numberOfSeries)"

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in

            tableView.beginUpdates()

            let item = self.routine.items![indexPath.row] as! Item
            CoreDataManager.shared.remove(item, from: self.routine)

            tableView.deleteRows(at: [indexPath], with: .top)
            tableView.endUpdates()
        })

        let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in

            let item = self.routine.items![indexPath.row]

            self.performSegue(withIdentifier: "Edit Item", sender: item)
        })

        edit.backgroundColor = UIColor(named: "blue")
        
        return [edit, delete]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "Edit Item",
            let item = sender as? Item,
            let navigation = segue.destination as? UINavigationController,
            let editItem = navigation.topViewController as? EditExercisesTableViewController {

            editItem.item = item
        }
    }

    // MARK: - Table view data source

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

    // MARK: - Empty State View Controller

    var emptyStateViewController : UIViewController?
}
