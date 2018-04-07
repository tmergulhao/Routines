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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.

        let session = WCSession.default

        session.activate()

        session.sendMessage(["Update data" : Date()], replyHandler: { (dictionary) in
            print(dictionary)
        }) { (error) in
            print(error)
        }
    }

    lazy var routines : Array<RoutineCodable> = Sample.shared.routines
    
    override func willActivate() {

        super.willActivate()

        table.setNumberOfRows(routines.count, withRowType: "Routine")

        for i in 0..<routines.count {
            let row = table.rowController(at: i) as! RoutineRowController

            row.configure(routine: routines[i])
        }
    }

    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return routines[rowIndex]
    }

}
