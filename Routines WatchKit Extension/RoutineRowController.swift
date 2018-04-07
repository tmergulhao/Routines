//
//  RoutinesRowController.swift
//  Routines WatchKit App
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit

class RoutineRowController: NSObject {
    @IBOutlet weak var nameLabel : WKInterfaceLabel!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var numberOfItemsLabel: WKInterfaceLabel!

    func configure(routine : RoutineCodable) {
        nameLabel.setText(routine.name)
        descriptionLabel.setText(routine.summary)

        if let items = routine.items {
            numberOfItemsLabel.setText("\(items.count)")
            numberOfItemsLabel.setTextColor(.white)
        } else {
            numberOfItemsLabel.setText("Empty routine")
            numberOfItemsLabel.setTextColor(.gray)
        }

    }
}
