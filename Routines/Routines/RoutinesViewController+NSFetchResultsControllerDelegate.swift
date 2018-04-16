//
//  RoutinesViewController+NSFetchResultsControllerDelegate.swift
//  Routines
//
//  Created by Tiago Mergulhão on 16/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

extension RoutinesViewController : NSFetchedResultsControllerDelegate {

    func setupFetchResultsController () -> NSFetchedResultsController<Routine> {

        let request : NSFetchRequest = Routine.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: CoreDataManager.shared.context,
            sectionNameKeyPath: "archived",
            cacheName: "Routines")

        controller.delegate = self

        return controller
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            tableView.insertRows(at: [indexPath].compactMap{$0}, with: .top)
        case .delete:
            tableView.deleteRows(at: [indexPath].compactMap{$0}, with: .top)
        case .update:
            guard let cell = tableView.cellForRow(at: indexPath!) as? RoutineTableViewCell else { return }
            let routine : Routine = fetchedResultsController.object(at: indexPath!)

            cell.configure(with: routine)
        case .move:
            tableView.deleteRows(at: [indexPath].compactMap{$0}, with: .top)
            tableView.insertRows(at: [newIndexPath].compactMap{$0}, with: .top)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        tableView.endUpdates()
        tableView.reloadData()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        let indexSet = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .top)
        case .delete:
            tableView.deleteSections(indexSet, with: .top)
        case .move, .update: break
        }
    }
}
