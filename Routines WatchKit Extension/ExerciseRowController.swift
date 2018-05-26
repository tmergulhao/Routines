//
//  RoutinesRowController.swift
//  Routines WatchKit App
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit

class ExerciseRowController: NSObject {
    @IBOutlet weak var identifierLabel : WKInterfaceLabel!
    @IBOutlet weak var nameLabel: WKInterfaceLabel!

    @IBOutlet weak var repetitionLabel: WKInterfaceLabel!
    @IBOutlet weak var weightLoadLabel: WKInterfaceLabel!
    @IBOutlet weak var weightIconImage: WKInterfaceImage!
    
    func configure(item : Item) {

        if let equipment = item.equipment, equipment != "" {
            identifierLabel.setText(item.equipment)
            identifierLabel.setTextColor(item.color)
        } else {
            identifierLabel.setText("n/a")
            identifierLabel.setTextColor(.darkGray)
        }

        nameLabel.setText(item.name)
        repetitionLabel.setText("\(item.repetitions)/\(item.numberOfSeries)")

        if item.weightLoad != 0.0 {
            weightLoadLabel.setText("\(item.weightLoad)")
            weightLoadLabel.setTextColor(UIColor(named: "teal"))
        } else {
            weightIconImage.setTintColor(.darkGray)
            weightLoadLabel.setTextColor(.darkGray)
            weightLoadLabel.setText("n/a")
        }
    }
}
