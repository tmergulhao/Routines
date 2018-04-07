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

    static var machines : Dictionary<String,MachineCodable> = Sample.shared.machinesDictionary
    
    func configure(item : ItemCodable) {

        if let machineIdentifier = item.exercise.machineIdentifier {
            machineNumberLabel.setText(machineIdentifier)
            let machine = ExerciseRowController.machines[machineIdentifier]!
            machineNumberLabel.setTextColor(UIColor(named: machine.colorName))
        } else {
            machineNumberLabel.setText("n/a")
            machineNumberLabel.setTextColor(.darkGray)
        }

        machineNameLabel.setText(item.exercise.name)
        repetitionLabel.setText("\(item.repetitions)/\(item.numberOfSeries)")

        if let weightLoad = item.weightLoad {
            weightLoadLabel.setText("\(weightLoad)")
            weightLoadLabel.setTextColor(UIColor(named: "teal"))
        } else {
            weightIconImage.setTintColor(.darkGray)
            weightLoadLabel.setTextColor(.darkGray)
            weightLoadLabel.setText("n/a")
        }
    }
}
