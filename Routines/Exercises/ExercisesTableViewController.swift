//
//  ExercisesTableViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 04/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit
import CoreData

class ExercisesTableViewController: UITableViewController {

    var fetchedResultsController : NSFetchedResultsController<Item>!

    var routine : Routine!

    @IBAction func activityButtonTapped(_ sender: UIBarButtonItem) {

        let manager = FileManager.default
        let directory = manager.urls(for: .documentDirectory, in: .userDomainMask)

        guard let fileUrl = directory.first?.appendingPathComponent(routine.name! + ".routine") else {
            print("Unable to get file directory url")
            return
        }

        do {
            let data = try CoreDataManager.serialize(routine)
            try data.write(to: fileUrl)

            let descriptiveMessage = "Here goes my \(routine.name!) routine."

            let activity = UIActivityViewController(
                activityItems: [descriptiveMessage, fileUrl],
                applicationActivities: nil)

            activity.popoverPresentationController?.barButtonItem = sender

            present(activity, animated: true)

        } catch {

            print(error.localizedDescription)
        }
    }

    @IBOutlet weak var floatingActionButton : FloatingActionButton!

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        view.bringSubview(toFront: floatingActionButton)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        fetchedResultsController = setupResultsController(for: routine)

        view.insertSubview(floatingActionButton, at: 0)

        NSLayoutConstraint.activate([
            floatingActionButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            floatingActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        (view as! UITableView).contentInset.bottom = 32 * 2 + 32
        (view as? UIScrollView)?.delegate = self

        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true

        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        view.bringSubview(toFront: floatingActionButton)

        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.red
        ]

        var title : String = routine.name!

        if let summary = routine.summary {
            title = title + ", " + summary
        }

        navigationItem.title = title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let count = fetchedResultsController.fetchedObjects?.count, count > 0 else {

            navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = false
            setEmptyState(identifier: "Empty State", intoContainer: tableView)
            return 0
        }

        navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true

        removeEmptyState()
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Exercise") as? ExercisesTableViewCell else {
            return UITableViewCell()
        }

        let item : Item = fetchedResultsController.fetchedObjects![indexPath.row]

        cell.configure(item: item)

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return !routine.archived }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        guard !routine.archived else { return nil }

        let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in

            let item : Item = self.fetchedResultsController.fetchedObjects![indexPath.row]

            CoreDataManager.shared.context.delete(item)
            try! CoreDataManager.saveContext()
        })

        let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in

            let item : Item = self.fetchedResultsController.fetchedObjects![indexPath.row]

            self.performSegue(withIdentifier: "Edit Item", sender: item)
        })

        edit.backgroundColor = .blue
        
        return [edit, delete]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return false }

    // MARK: - Empty State View Controller

    var emptyStateViewController : UIViewController?
}
