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

        updateDateLabel(for: lastUpdated.value)

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

        updateDateLabel(for: date)
    }

    func updateDateLabel(for date : Date?) {

        guard let date = date else {
            lastUpdatedLabel.setText("Never")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US")

        let formattedDateString = dateFormatter.string(from: date)

        lastUpdatedLabel.setText(formattedDateString)

//      let dateComponents = Calendar.current.dateComponents([.day], from: lastUpdated.value ?? Date(), to: Date())
//      let format = NSLocalizedString("Updated", comment: "")
//      lastUpdatedLabel.setText(String.localizedStringWithFormat(format, dateComponents.day!))
    }
}
