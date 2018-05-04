//
//  RoutinesController+NSFetchedResultsControllerDelegate.swift
//  Routines WatchKit Extension
//
//  Created by Tiago Mergulhão on 30/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

extension RoutinesController : NSFetchedResultsControllerDelegate {

    func setupFetchResultsController () -> NSFetchedResultsController<Routine> {

        let request : NSFetchRequest = Routine.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: CoreDataManager.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil)

        controller.delegate = self

        return controller
    }

    func updateTableContent(with controller : NSFetchedResultsController<Routine>) {

        let count = controller.fetchedObjects?.count ?? 0

        table.setNumberOfRows(count, withRowType: "Routine")

        for rowIndex in 0..<count {
            if let row = table.rowController(at: rowIndex) as? RoutineRowController {
                let routine = controller.object(at: IndexPath(row: rowIndex, section: 0))
                row.configure(routine: routine)
            }
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        // TODO: Better the update sequence
        return

        switch type {
        case .update:
            let row = table.rowController(at: newIndexPath!.row) as! RoutineRowController
            if let routine = anObject as? Routine {
                row.configure(routine: routine)
            }
        case .delete:
            table.removeRows(at: IndexSet(integer: indexPath!.row))
        case .insert:
            table.insertRows(at: IndexSet(integer: newIndexPath!.row), withRowType: "Routine")
            let row = table.rowController(at: newIndexPath!.row) as! RoutineRowController

            if let routine = anObject as? Routine {
                row.configure(routine: routine)
            }
        case .move:
            updateTableContent(with: controller as! NSFetchedResultsController<Routine>)
        }
    }
}
