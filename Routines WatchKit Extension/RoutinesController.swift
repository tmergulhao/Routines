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

    @IBOutlet var lastUpdatedLabel: WKInterfaceLabel!
    let lastUpdated = Default<Date>(key: "Last updated on Watch")

    override func awake(withContext context: Any?) {

        super.awake(withContext: context)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        dateFormatter.locale = Locale(identifier: "en_US")

        let date = lastUpdated.value ?? Date()
        let formattedDateString = dateFormatter.string(from: date)

        lastUpdatedLabel.setText(formattedDateString)

//        let dateComponents = Calendar.current.dateComponents([.day], from: lastUpdated.value ?? Date(), to: Date())
//        let format = NSLocalizedString("Updated", comment: "")
//        lastUpdatedLabel.setText(String.localizedStringWithFormat(format, dateComponents.day!))

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
