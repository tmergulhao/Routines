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
                weightLabel.setText("\(weightLoad!)")
                weightLabel.setTextColor(.white)
            } else {
                weightLabel.setText("n/a")
                weightLabel.setTextColor(.darkGray)
            }
        }
    }

    override func awake(withContext context: Any?) {

        guard let item = context as? ItemCodable else {
            dismiss()
            return
        }

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

        // TODO: Create a new update entity to send back to the phone
        // with references for the item UUID, the current date and
        // the new value
        // Conflicts will be mediated by the edit date

        dismiss()
    }
}

extension EditItemController : WKCrownDelegate {

    var crownSensitivity : Double { return 0.5 }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {

        // TODO: Improve experience on crown increments

        guard let rotationsPerSecond = crownSequencer?.rotationsPerSecond else { return }

        weightLoad = weightLoad + floor(rotationsPerSecond * crownSensitivity) * increment
    }
}
