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
                let text = NSAttributedString(string: String(format: "%.2f", weightLoad!), attributes: [.font : monospacedFont])
                weightLabel.setAttributedText(text)
                weightLabel.setTextColor(.white)
            } else {
                weightLabel.setText("n/a")
                weightLabel.setTextColor(.darkGray)
            }
        }
    }

    var item : Item!

    let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 36.0, weight: .regular)

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

        // TODO: Update parent interface

        item.weightLoad = weightLoad
        item.lastEdited = Date()

        WatchConnectivityManager.updated(item)

        try? CoreDataManager.saveContext()

        dismiss()
    }

    var accumulator : Double = 0.0
}

extension EditItemController : WKCrownDelegate {

    var crownResistence : Double { return 0.1 }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {

        accumulator += rotationalDelta

        let crownTicks = (accumulator/crownResistence).rounded(.towardZero)

        weightLoad = weightLoad + crownTicks * increment

        accumulator = accumulator.truncatingRemainder(dividingBy: crownResistence)
    }
}
