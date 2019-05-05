//
//  ExercisesTableViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 04/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

class ExercisesTableViewController: UITableViewController {

    var routine : Routine?

    @IBAction func activityButtonTapped(_ sender: UIBarButtonItem) {

        guard let routine = routine else { return }

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

        view.bringSubviewToFront(floatingActionButton)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        view.insertSubview(floatingActionButton, at: 0)
        view.bringSubviewToFront(floatingActionButton)

        NSLayoutConstraint.activate([
            floatingActionButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            floatingActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        (view as! UITableView).contentInset.bottom = 32 * 2 + 32
        (view as? UIScrollView)?.delegate = self

        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.red
        ]

        tableView.reloadData()

        guard let routine = routine else { return }

        var title : String = routine.name!

        if let summary = routine.summary {
            title = title + ", " + summary
        }

        navigationItem.title = title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let routine = routine else { return 0 }

        let count = routine.items?.count ?? 0

        if count == 0 {
            setEmptyState(identifier: "Empty State", intoContainer: tableView)
        } else {
            removeEmptyState()
        }

        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let routine = self.routine, let cell = tableView.dequeueReusableCell(withIdentifier: "Exercise"),
            let item = routine.items?[indexPath.row] as? Item else {
            return UITableViewCell()
        }

        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.repetitions)/\(item.numberOfSeries)\t\(item.weightLoad)kg"

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        guard routine != nil else { return nil }

        let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in

            guard let routine = self.routine else { return }

            tableView.beginUpdates()

            let item = routine.items![indexPath.row] as! Item

            routine.removeFromItems(item)

            CoreDataManager.shared.context.delete(item)
            try! CoreDataManager.saveContext()

            tableView.deleteRows(at: [indexPath], with: .top)
            tableView.endUpdates()
        })

        let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in

            guard let routine = self.routine else { return }

            let item = routine.items![indexPath.row]

            self.performSegue(withIdentifier: "Edit Item", sender: item)
        })

        edit.backgroundColor = .blue
        
        return [edit, delete]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "Edit Item",
            let navigation = segue.destination as? UINavigationController,
            let editItem = navigation.topViewController as? EditExercisesTableViewController {

            editItem.item = sender as? Item
            editItem.routine = routine
        }
    }

    // MARK: - Empty State View Controller

    var emptyStateViewController : UIViewController?
}
