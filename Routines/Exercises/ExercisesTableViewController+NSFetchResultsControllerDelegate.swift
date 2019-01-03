//
//  ExercisesTableViewController+NSFetchResultsControllerDelegate.swift
//  Routines
//
//  Created by Tiago Mergulhão on 16/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

extension ExercisesTableViewController : NSFetchedResultsControllerDelegate {

    func setupResultsController (for routine : Routine) -> NSFetchedResultsController<Item> {

        let request : NSFetchRequest<Item> = CoreDataManager.request()

        request.predicate = NSPredicate(format: "routine = %@", routine)
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: CoreDataManager.shared.context,
            sectionNameKeyPath: nil,
            cacheName: "\(routine.name!) items")

        controller.delegate = self

        return controller
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath].compactMap{$0}, with: .top)
        case .delete:
            tableView.deleteRows(at: [indexPath].compactMap{$0}, with: .top)
        case .update:
            tableView.reloadRows(at: [indexPath].compactMap{$0}, with: .automatic)
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
