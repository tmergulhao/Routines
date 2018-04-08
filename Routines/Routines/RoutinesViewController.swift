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

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        if Routine.active.isEmpty && Routine.archived.isEmpty {
            setEmptyState(identifier: "Empty State", intoContainer: tableView)
        } else {
            removeEmptyState()
        }

        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return Routine.active.count
        default:
            return Routine.archived.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Routine") as? RoutineTableViewCell else {
            return UITableViewCell()
        }

        var routine : Routine?

        switch indexPath.section {
        case 0:
            routine = Routine.active[indexPath.row]
        default:
            routine = Routine.archived[indexPath.row]
        }

        cell.configure(with: routine!)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if section == 1 && !Routine.archived.isEmpty { return "Archived" }
        return ""
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        switch indexPath.section {
        case 0:
            let archive = UITableViewRowAction(style: .default, title: "Archive", handler: { (action, indexPath) in

                tableView.beginUpdates()

                let routine = Routine.active[indexPath.row]
                CoreDataManager.shared.archive(routine)

                tableView.deleteRows(at: [indexPath], with: .top)
                tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .top)
                tableView.endUpdates()
            })

            archive.backgroundColor = .lightGray

            let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in

                let routine = Routine.active[indexPath.row]

                self.performSegue(withIdentifier: "Edit Routine", sender: routine)
            })

            edit.backgroundColor = UIColor(named: "blue")

            return [edit, archive]
        default:
            let unarchive = UITableViewRowAction(style: .default, title: "Unarchive", handler: { (action, indexPath) in

                tableView.beginUpdates()

                let routine = Routine.archived[indexPath.row]
                CoreDataManager.shared.unarchive(routine)

                tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                tableView.endUpdates()
            })

            unarchive.backgroundColor = .lightGray

            let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in

                tableView.beginUpdates()

                let routine = Routine.archived[indexPath.row]
                CoreDataManager.shared.remove(routine)

                tableView.deleteRows(at: [indexPath], with: .top)
                tableView.endUpdates()
            })
            
            return [unarchive,delete]
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell), indexPath.section == 1 {

            return false
        }

        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let exercises = segue.destination as? ExercisesTableViewController {

            exercises.routine = Routine.active[indexPath.row]
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
