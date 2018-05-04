//
//  EditItemController.swift
//  Routines WatchKit Extension
//
//  Created by Tiago Mergulhão on 21/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit

class EditItemController : WKInterfaceController {

    @IBOutlet weak var weightLabel : WKInterfaceLabel!

    override func willActivate() {

        super.willActivate()

        crownSequencer.focus()
        crownSequencer.delegate = self
    }

    var weightLoad : Double! {
        didSet {

            if weightLoad < 0 {
                weightLoad = 0
            }

            if weightLoad > 0 {
                weightLabel.setText(String(format: "%.2f", weightLoad!))
                weightLabel.setTextColor(.white)
            } else {
                weightLabel.setText("n/a")
                weightLabel.setTextColor(.darkGray)
            }
        }
    }

    var item : Item!

    override func awake(withContext context: Any?) {

        guard let item = context as? Item else {
            dismiss()
            return
        }

        self.item = item

        weightLoad = item.weightLoad
    }

    let increment : Double = 0.25

    @IBAction func decreaseWeightLoad() {
        weightLoad = weightLoad - increment
    }
    @IBAction func increaseWeightLoad() {
        weightLoad = weightLoad + increment
    }

    @IBAction func updateWeightLoad() {

        item.weightLoad = weightLoad
        item.lastEdited = Date()

        WatchConnectivityManager.updated(item)

        try? CoreDataManager.saveContext()

        dismiss()
    }

    var accumulator : Double = 0.0
}

extension EditItemController : WKCrownDelegate {

    var crownSensitivity : Double { return 0.3 }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {

        accumulator += rotationalDelta

        let crownTicks = (accumulator/crownSensitivity).rounded(.towardZero)

        weightLoad = weightLoad + crownTicks * increment

        accumulator = accumulator.truncatingRemainder(dividingBy: crownSensitivity)
    }
}
