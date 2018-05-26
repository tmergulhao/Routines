//
//  WorkoutController.swift
//  Routines WatchKit Extension
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit

class WorkoutController : WKInterfaceController {

    var routine : Routine!

    var items : Array<Item>!

    var numberOfItems : Int = 0

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

        assignItems()

        numberOfItems = items.count

        guard let item = items.first else { dismiss(); return }

        self.item = item

        updateProgress()

        style(for: item)
    }

    var count : Int = 0
    let maxFrame : Int = 299

    var item : Item?

    @IBAction func skipItem () {

        guard items.count >= 2 else {

            presentAlert(
                withTitle: "This is your last item",
                message: "You cannot skip to another on the last item.",
                preferredStyle: .alert,
                actions: [])

            return
        }

        let skipped = items.remove(at: 0)
        items.append(skipped)

        let item = items.first!

        self.item = item

        style(for: item)
    }

    @IBAction func markAsDone () {

        guard items.count >= 2 else {

            WatchConnectivityManager.record(self.routine)

            dismiss()

            return
        }

        items.remove(at: 0)

        let item = items.first!

        self.item = item

        style(for: item)

        updateProgress()
    }

    @IBOutlet var identifierLabel: WKInterfaceLabel!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var repetitionsLabel: WKInterfaceLabel!
    @IBOutlet var weightLabel: WKInterfaceLabel!
    @IBOutlet var weightDescriptiveLabel: WKInterfaceLabel!

    func style(for item : Item) {

        if let equipment = item.equipment, equipment != "" {
            identifierLabel.setText(equipment)
            identifierLabel.setTextColor(item.color)
        } else {
            identifierLabel.setText("n/a")
            identifierLabel.setTextColor(.darkGray)
        }

        nameLabel.setText(item.name)
        repetitionsLabel.setText("\(item.repetitions)/\(item.numberOfSeries)")

        if item.weightLoad != 0.0 {
            weightDescriptiveLabel.setTextColor(.teal)
            weightLabel.setTextColor(.teal)
            weightLabel.setText("\(item.weightLoad)")
        } else {
            weightDescriptiveLabel.setTextColor(.darkGray)
            weightLabel.setTextColor(.darkGray)
            weightLabel.setText("n/a")
        }
    }

    @IBOutlet var progressLabel: WKInterfaceLabel!

    @IBOutlet var doneProgressGroup: WKInterfaceGroup!
    @IBOutlet var notDoneProgressGroup: WKInterfaceGroup!

    func updateProgress () {

        let done = numberOfItems - items.count + 1

        progressLabel.setText("\(done) of \(numberOfItems)")

        let relativeWidth = CGFloat(done) / CGFloat(numberOfItems)

        doneProgressGroup.setRelativeWidth(relativeWidth, withAdjustment: 0.0)
        notDoneProgressGroup.setRelativeWidth(1.0 - relativeWidth, withAdjustment: 0.0)
    }

    var observation : NSKeyValueObservation?

    @IBAction func editItem() {

        guard let item = item else { return }

        observation = item.observe(\.weightLoad, options: .new) {
            (item, change) in
            self.style(for: item)
        }

        presentController(withName: "Edit item", context: item)
    }
}
