//
//  RoutinesRowController.swift
//  Routines WatchKit App
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit

class RoutineRowController: NSObject {

    @IBOutlet var lastRecordLabel: WKInterfaceLabel!
    @IBOutlet weak var nameLabel : WKInterfaceLabel!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var numberOfItemsLabel: WKInterfaceLabel!

    func configureDateLabel(for date : Date?) {

        guard let date = date, let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day else {
            lastRecordLabel.setText("Never")
            return
        }

        let format = NSLocalizedString("Last record", comment: "")
        let string = String.localizedStringWithFormat(format, days)

        lastRecordLabel.setText(string)
    }

    func configure(routine : Routine) {
        nameLabel.setText(routine.name)
        descriptionLabel.setText(routine.summary)

        configureDateLabel(for: routine.latestRecord)

        if let items = routine.items {
            numberOfItemsLabel.setText("\(items.count)")
            numberOfItemsLabel.setTextColor(.white)
        } else {
            numberOfItemsLabel.setText("Empty routine")
            numberOfItemsLabel.setTextColor(.gray)
        }
    }
}
