//
//  InterfaceController.swift
//  Routines WatchKit Extension
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit
import WatchConnectivity

class RoutinesController : WKInterfaceController {

    @IBOutlet weak var table : WKInterfaceTable!

    lazy var resultsController = setupFetchResultsController()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.

        let session = WCSession.default

        session.activate()

        session.sendMessage(["Update data" : Date()], replyHandler: { (dictionary) in
            print(dictionary)
        }) { (error) in
            print(error.localizedDescription)
        }

        try? resultsController.performFetch()
    }
    
    override func willActivate() {

        super.willActivate()

        let count = resultsController.fetchedObjects?.count ?? 0

        table.setNumberOfRows(count, withRowType: "Routine")

        for rowIndex in 0..<count {
            let row = table.rowController(at: rowIndex) as! RoutineRowController

            row.configure(routine: resultsController.object(at: IndexPath(row: rowIndex, section: 0)))
        }
    }

    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return resultsController.object(at: IndexPath(row: rowIndex, section: 0))
    }
}

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
