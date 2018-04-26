//
//  RoutinesRowController.swift
//  Routines WatchKit App
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit

class ExerciseRowController: NSObject {
    @IBOutlet weak var machineNumberLabel : WKInterfaceLabel!
    @IBOutlet weak var machineNameLabel: WKInterfaceLabel!
    @IBOutlet weak var routineIndexCount: WKInterfaceLabel!

    @IBOutlet weak var repetitionLabel: WKInterfaceLabel!
    @IBOutlet weak var weightLoadLabel: WKInterfaceLabel!
    @IBOutlet weak var weightIconImage: WKInterfaceImage!
    
    func configure(item : ItemCodable) {

        if let equipment = item.equipment {
            machineNumberLabel.setText(equipment)
            machineNumberLabel.setTextColor(UIColor(named: item.colorName ?? ""))
        } else {
            machineNumberLabel.setText("n/a")
            machineNumberLabel.setTextColor(.darkGray)
        }

        machineNameLabel.setText(item.name)
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
