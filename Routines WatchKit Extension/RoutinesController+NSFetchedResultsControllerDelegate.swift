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

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        willActivate()
    }
}
