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

    lazy var fetchedResultsController = setupFetchResultsController()

    override func viewDidLoad() {

        super.viewDidLoad()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        guard let sections = fetchedResultsController.sections, sections.count != 0 else {

            setEmptyState(identifier: "Empty State", intoContainer: tableView)
            return 0
        }

        removeEmptyState()
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let info = fetchedResultsController.sections?[section] else { return 0 }

        return info.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Routine") as? RoutineTableViewCell else {
            return UITableViewCell()
        }

        let routine : Routine = fetchedResultsController.object(at: indexPath)

        print(routine.archived)

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

                try! CoreDataManager.shared.saveContext()
            })

            archive.backgroundColor = .lightGray

            let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in

                let routine = self.fetchedResultsController.object(at: indexPath)

                self.performSegue(withIdentifier: "Edit Routine", sender: routine)
            })

            edit.backgroundColor = UIColor(named: "blue")

            return [edit, archive]
        case .archived:
            let unarchive = UITableViewRowAction(style: .default, title: "Unarchive", handler: { (action, indexPath) in

                let routine = self.fetchedResultsController.object(at: indexPath)

                routine.archived = false
                routine.archival = nil

                try! CoreDataManager.shared.saveContext()
            })

            unarchive.backgroundColor = .lightGray

            let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in

                let routine = self.fetchedResultsController.object(at: indexPath)
                CoreDataManager.shared.context.delete(routine)

                try! CoreDataManager.shared.saveContext()
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
            let exercises = segue.destination as? ExercisesTableViewController {

            let routine = self.fetchedResultsController.object(at: indexPath)

            exercises.routine = routine
        }

        if segue.identifier == "Show Routine",
            let routine = sender as? Routine,
            let exercises = segue.destination as? ExercisesTableViewController {

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

    // MARK: - Empty State View Controller

    var emptyStateViewController : UIViewController?
}
