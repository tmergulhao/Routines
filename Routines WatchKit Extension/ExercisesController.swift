//
//  InterfaceController.swift
//  Routines WatchKit Extension
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit

class ExercisesController: WKInterfaceController {

    @IBOutlet weak var table : WKInterfaceTable!

    var routine : Routine!

    var items : Array<Item>!

    func assignItems () {

        if let itemsSet = routine.items, let itemsArray = Array(itemsSet) as? Array<Item> {
            items = itemsArray
        } else {
            items = []
        }
    }

    override func awake(withContext context: Any?) {

        super.awake(withContext: context)

        routine = context as! Routine

        setTitle(routine.fullName)

        assignItems()
    }

    override func willActivate() {

        super.willActivate()

        table.setNumberOfRows(items.count, withRowType: "Exercise")

        for i in 0..<items.count {

            let row = table.rowController(at: i) as! ExerciseRowController

            row.configure(item: items[i])
            row.routineIndexCount.setText("\(i + 1)/\(items.count)")
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {

        let check = WKAlertAction(title: "Mark as Done", style: .default) {

            if self.items.count == 1 {
                WKInterfaceDevice.current().play(.notification)
                self.dismiss()
            }

            self.items.remove(at: rowIndex)
            table.removeRows(at: IndexSet(integer: rowIndex))
        }

        let cancel = WKAlertAction(title: "Cancel", style: .cancel) { return }

        presentAlert(withTitle: "Mark as Done", message: "Remove item from the list for this session.", preferredStyle: .actionSheet, actions: [check, cancel])
    }

    @IBAction func resetRoutine () {

        assignItems()

        willActivate()
    }
    @IBAction func exitRoutine() {

        dismiss()
    }
}
