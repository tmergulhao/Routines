//
//  AddRoutineViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 02/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit
import CoreData

class EditRoutineViewController : UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var summaryField: UITextField!

    var routine : Routine!

    @IBAction func saveButtonTapped(_ sender: Any) {

        if routine == nil {

            let newRoutine : Routine = NSEntityDescription
                .object(into: CoreDataManager.shared.context)

            newRoutine.createdAt = Date()
            newRoutine.id = UUID()

            routine = newRoutine
        } else {
            navigationItem.title = "Edit Routine"
        }

        routine.lastEdited = Date()
        routine.name = nameField.text?.trim()
        routine.summary = summaryField.text?.trim()

        do {
            try CoreDataManager.shared.saveContext()
        } catch {

            informUser(about: error)
            return
        }

        dismiss(animated: true)
    }

    func informUser(about error : Error) {
        // TODO: Inform user about data sanitization
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
