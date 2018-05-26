//
//  InterfaceController.swift
//  Routines WatchKit Extension
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchKit
import WatchConnectivity

class RoutinesController : WKInterfaceController {

    @IBOutlet weak var table : WKInterfaceTable!

    @IBOutlet var lastUpdatedLabel: WKInterfaceLabel!

    lazy var resultsController = setupFetchResultsController()

    let lastUpdated = Default<Date>(key: "Last updated on Watch")

    override func awake(withContext context: Any?) {

        super.awake(withContext: context)

        WatchConnectivityManager.shared.delegate = self

        updateDateLabel(
            for: lastUpdated.value,
            numberOfUpdates: WatchConnectivityManager.watchSession.outstandingUserInfoTransfers.count
        )

        try? resultsController.performFetch()

        updateTableContent(with: resultsController)
    }

    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {

        return resultsController.object(at: IndexPath(row: rowIndex, section: 0))
    }
}

extension RoutinesController : WatchConnectivityManagerDelegate {

    func watchConnectivityStartedUpdating(_ manager: WatchConnectivityManager) {

        lastUpdatedLabel.setText("Updating content…")
    }

    func watchConnectivity(_ manager: WatchConnectivityManager, didUpdate routines: Array<Routine>, at date: Date) {

        updateDateLabel(for: date, numberOfUpdates: nil)
    }

    func updateDateLabel(for date : Date?, numberOfUpdates : Int?) {

        let updateLabel : String!

        if let date = date {

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "en_US")

            updateLabel = dateFormatter.string(from: date)

        } else {

            updateLabel = "Never updated"
        }

        lastUpdatedLabel.setText(updateLabel)

        if let numberOfUpdates = numberOfUpdates {

            scheduleUpdatesInformation(for: numberOfUpdates, returningTo: updateLabel)
        }
    }

    func scheduleUpdatesInformation(for numberOfUpdates : Int, returningTo updateLabel : String) {

        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] (timer) in timer.invalidate()

            guard self != nil else { return }

            self!.animate(withDuration: 1) { self!.lastUpdatedLabel.setAlpha(0) }
        }

        Timer.scheduledTimer(withTimeInterval: 6, repeats: false) { [weak self] (timer) in timer.invalidate()

            guard self != nil else { return }

            self!.lastUpdatedLabel.setText("\(numberOfUpdates) queued updates")

            self!.animate(withDuration: 1) { self!.lastUpdatedLabel.setAlpha(1) }
        }

        Timer.scheduledTimer(withTimeInterval: 7, repeats: false) { [weak self] (timer) in timer.invalidate()

            guard self != nil else { return }

            self!.animate(withDuration: 1) { self!.lastUpdatedLabel.setAlpha(0) }
        }

        Timer.scheduledTimer(withTimeInterval: 8, repeats: false) { [weak self] (timer) in timer.invalidate()

            guard self != nil else { return }

            self!.lastUpdatedLabel.setText(updateLabel)

            self!.animate(withDuration: 1) { self!.lastUpdatedLabel.setAlpha(1) }
        }
    }
}
