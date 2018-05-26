//
//  RoutineDetailController.swift
//  Routines WatchKit Extension
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit

class RoutineDetailController : WKInterfaceController {

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

    @IBOutlet var routineNameLabel: WKInterfaceLabel!
    @IBOutlet var routineDescriptionLabel: WKInterfaceLabel!
    @IBOutlet var lastRecordLabel: WKInterfaceLabel!

    func updateLastRecord(for routine : Routine) {

        guard let record = routine.records?.firstObject as? Record,
            let date = record.date else {
            lastRecordLabel.setText("Never")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")

        let dateString = dateFormatter.string(from: date)

        lastRecordLabel.setText(dateString)
    }

    override func willActivate() {

        super.willActivate()

        routineNameLabel.setText(routine.name)
        routineDescriptionLabel.setText(routine.summary)

        updateLastRecord(for: routine)

        table.setNumberOfRows(items.count, withRowType: "Exercise")

        for i in 0..<items.count {

            let row = table.rowController(at: i) as! ExerciseRowController

            row.configure(item: items[i])
        }
    }

    var observation : NSKeyValueObservation?

    override func contextForSegue(withIdentifier: String) -> Any? {

        observation = routine.observe(\.records, options: .new) {
            (routine, change) in

            self.presentController(withName: "Complete routine", context: routine)
        }

        return routine
    }

//    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
//
//        let check = WKAlertAction(title: "Mark as Done", style: .default) {
//
//            if self.items.count == 1 {
//                WKInterfaceDevice.current().play(.notification)
//                self.dismiss()
//            }
//
//            self.items.remove(at: rowIndex)
//            table.removeRows(at: IndexSet(integer: rowIndex))
//        }
//
//        let cancel = WKAlertAction(title: "Cancel", style: .cancel) { return }
//
//        presentAlert(withTitle: "Mark as Done", message: "Remove item from the list for this session.", preferredStyle: .actionSheet, actions: [check, cancel])
//    }
}
