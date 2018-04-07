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

    var routine : Routine?

    var dataIsValid : Bool {

        guard let nameText = nameField.text?.trim() else { return false }
        guard let summaryText = summaryField.text?.trim() else { return false }

        return nameText != "" && summaryText != ""
    }

    func saveData () {

        if routine == nil {
            routine = CoreDataManager.shared.insertRoutine()
        } else {
            navigationItem.title = "Edit Routine"
        }

        routine!.name = nameField.text?.trim()
        routine!.summary = summaryField.text?.trim()

        CoreDataManager.shared.saveContext()

        dismiss(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {

        guard dataIsValid else { return }

        saveData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.delegate = self
        summaryField.delegate = self

        if routine != nil {

            nameField.text = routine?.name
            summaryField.text = routine?.summary
        }

        nameField.becomeFirstResponder()
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return false }
}

extension EditRoutineViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        navigationItem.rightBarButtonItem?.isEnabled = dataIsValid

        return true
    }
}
