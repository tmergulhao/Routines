//
//  AddRoutineViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 02/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

class EditRoutineViewController : UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var summaryField: UITextField!

    var routine : Routine!

    @IBAction func saveButtonTapped(_ sender: Any) {

        if routine == nil {
            routine = CoreDataManager.shared.insertRoutine()
        } else {
            navigationItem.title = "Edit Routine"
        }

        routine.name = nameField.text?.trim()
        routine.summary = summaryField.text?.trim()

        do {
            try CoreDataManager.shared.saveContext()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }

        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if routine != nil {

            nameField.text = routine.name
            summaryField.text = routine.summary
        }

        nameField.becomeFirstResponder()
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return false }
}
