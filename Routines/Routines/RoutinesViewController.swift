//
//  ViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit
import CoreData

class RoutinesViewController : UITableViewController {

    enum SectionIndex : String {
        case archived = "1", active = "0"
    }

    @IBAction func activityButtonTapped(_ sender: UIBarButtonItem) {

        let manager = FileManager.default
        let directory = manager.urls(for: .documentDirectory, in: .userDomainMask)

        guard let fileUrl = directory.first?.appendingPathComponent("Database.routine") else {
            print("Unable to get file directory url")
            return
        }

        do {
            let data = try CoreDataManager.serializeRoutines()
            try data.write(to: fileUrl)

            let descriptiveMessage = "Here goes all my routines."

            let activity = UIActivityViewController(
                activityItems: [descriptiveMessage, fileUrl],
                applicationActivities: nil)

            activity.popoverPresentationController?.barButtonItem = sender

            present(activity, animated: true)

        } catch {

            print(error.localizedDescription)
        }
    }

    lazy var fetchedResultsController = setupFetchResultsController()

    @IBOutlet weak var floatingActionButton : FloatingActionButton!

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        view.bringSubview(toFront: floatingActionButton)
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        view.insertSubview(floatingActionButton, at: 0)
        view.bringSubview(toFront: floatingActionButton)

        NSLayoutConstraint.activate([
            floatingActionButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            floatingActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        (view as! UITableView).contentInset.bottom = 32 * 2 + 32
        (view as? UIScrollView)?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }

        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.red
        ]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        let sections = fetchedResultsController.sections

        let isEmptyState = !(sections != nil && sections!.count > 0)

        navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = !isEmptyState

        guard !isEmptyState else {

            setEmptyState(identifier: "Empty State", intoContainer: tableView)
            return 0
        }

        removeEmptyState()
        return sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Routine") as? RoutineTableViewCell else {
            return UITableViewCell()
        }

        let routine : Routine = fetchedResultsController.object(at: indexPath)
        
        cell.configure(with: routine)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        guard let sectionIndex = SectionIndex(rawValue: fetchedResultsController.sectionIndexTitles[section]) else { return "" }

        switch sectionIndex {
        case .active: return ""
        case .archived: return "Archived"
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        guard let sectionIndex = SectionIndex(rawValue: fetchedResultsController.sectionIndexTitles[indexPath.section]) else { return nil }

        switch sectionIndex {
        case .active:
            let archive = UITableViewRowAction(style: .default, title: "Archive", handler: { (action, indexPath) in

                let routine = self.fetchedResultsController.object(at: indexPath)

                routine.archived = true
                routine.archival = Date()

                try! CoreDataManager.saveContext()
            })

            archive.backgroundColor = .lightGray

            let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in

                let routine = self.fetchedResultsController.object(at: indexPath)

                self.performSegue(withIdentifier: "Edit Routine", sender: routine)
            })

            edit.backgroundColor = .blue

            return [edit, archive]
        case .archived:
            let unarchive = UITableViewRowAction(style: .default, title: "Unarchive", handler: { (action, indexPath) in

                let routine = self.fetchedResultsController.object(at: indexPath)

                routine.archived = false
                routine.archival = nil

                try! CoreDataManager.saveContext()
            })

            unarchive.backgroundColor = .lightGray

            let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in

                let routine = self.fetchedResultsController.object(at: indexPath)
                routine.managedObjectContext?.delete(routine)

                try! CoreDataManager.saveContext()
            })
            
            return [unarchive,delete]
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        if let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let sectionIndex = SectionIndex(rawValue: fetchedResultsController.sectionIndexTitles[indexPath.section]),
            sectionIndex == .archived {

            return false
        }

        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let navigation = segue.destination as? UINavigationController,
            let exercises = navigation.topViewController as? ExercisesTableViewController {

            let routine = self.fetchedResultsController.object(at: indexPath)

            exercises.routine = routine
        }

        if segue.identifier == "Show Routine",
            let routine = sender as? Routine,
            let navigation = segue.destination as? UINavigationController,
            let exercises = navigation.topViewController as? ExercisesTableViewController {

            exercises.routine = routine
        }

        if segue.identifier == "Edit Routine",
            let routine = sender as? Routine,
            let navigation = segue.destination as? UINavigationController,
            let editRoutine = navigation.topViewController as? EditRoutineViewController {

            editRoutine.routine = routine
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section != 1 { return nil }

        return tableView.dequeueReusableCell(withIdentifier: "Archived header")?.contentView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if section != 1 { return 0 }

        return 71
    }

    // MARK: - Empty State View Controller

    var emptyStateViewController : UIViewController?
}
//
//extension RoutinesViewController {
//
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        super.scrollViewDidScroll(scrollView)
//
//        // view.bringSubview(toFront: floatingActionButton)
//    }
//}
