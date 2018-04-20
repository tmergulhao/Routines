//
//  InterfaceController.swift
//  Routines WatchKit Extension
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit

class RoutineController: WKInterfaceController {

    var routine : RoutineCodable!

    var items : Array<ItemCodable>!

    var numberOfItems : Int = 0

    @IBOutlet weak var imageView : WKInterfaceImage!

    override func awake(withContext context: Any?) {

        super.awake(withContext: context)

        routine = context as! RoutineCodable

        items = routine.items

        numberOfItems = items.count

        setTitle(routine.fullName)
    }

    override func willActivate() {

        super.willActivate()

        guard let item = items.first else { dismiss(); return }

        self.item = item

        updateProgress()
        style(for: item)

        imageView.setImageNamed("Metronome/frame-")

        resetMetronome()
    }

    var count : Int = 0
    let maxFrame : Int = 299

    override func willDisappear() {

        super.willDisappear()
    }

    var item : ItemCodable?

    @IBAction func skipItem () {

        if let item = items.first {

            if let item = self.item {
                items.append(item)
            }

            self.item = item
            items.remove(at: 0)

            style(for: item)
        } else {

            presentAlert(withTitle: "This is your last item", message: "You cannot skip to another on the last item.", preferredStyle: .alert, actions: [])
        }
    }

    @IBAction func markAsDone () {

        if let item = items.first {

            self.item = item
            items.remove(at: 0)

            updateProgress()
            style(for: item)

        } else {

            dismiss()
        }
    }

    @IBOutlet var identifierLabel: WKInterfaceLabel!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var repetitionsLabel: WKInterfaceLabel!
    @IBOutlet var weightLabel: WKInterfaceLabel!
    @IBOutlet var weightImage: WKInterfaceImage!

    func style(for item : ItemCodable) {

        if let equipment = item.equipment {
            identifierLabel.setText(equipment)
            identifierLabel.setTextColor(UIColor(named: item.colorName!))
        } else {
            identifierLabel.setText("n/a")
            identifierLabel.setTextColor(.darkGray)
        }

        nameLabel.setText(item.name)
        repetitionsLabel.setText("\(item.repetitions)/\(item.numberOfSeries)")

        if let weightLoad = item.weightLoad {
            weightLabel.setText("\(weightLoad)")
            weightLabel.setTextColor(UIColor(named: "teal"))
        } else {
            weightImage.setTintColor(.darkGray)
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

    @IBAction func endRoutine() { dismiss() }

    @IBAction func resetMetronome(_ sender: Any? = nil) {

        imageView.startAnimatingWithImages(in: NSRange(location: 0, length: 299), duration: 40, repeatCount: -1)
    }
}
