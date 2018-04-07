//
//  EditExercisesTableViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 07/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

extension String {

    func trim () -> String { return trimmingCharacters(in: .whitespacesAndNewlines) }
}

class EditExercisesTableViewController: UITableViewController {

    @IBOutlet weak var seriesField : UITextField!
    @IBOutlet weak var repetitionsField : UITextField!
    @IBOutlet weak var weightField : UITextField!

    @IBOutlet weak var identifierField : UITextField!
    @IBOutlet weak var nameField : UITextField!

    @IBOutlet var colorButtons : Array<UIButton>!

    var routine : Routine?
    var item : Item?

    var dataIsValid : Bool {

        guard let name = nameField.text?.trim(), name != "" else { return false }
        guard let identifier = identifierField.text?.trim(), identifier != "" else { return false }

        guard let numberOfSeriesString = identifierField.text?.trim(), let numberOfSeries = Int(numberOfSeriesString), numberOfSeries != 0 else { return false }
        guard let repetitionsString = identifierField.text?.trim(), let repetitions = Int(repetitionsString), repetitions != 0 else { return false }
        guard let weightString = weightField.text?.trim(), let _ = Int(weightString) else { return false }

        return true
    }

    func saveData () {

        if item == nil {
            item = CoreDataManager.shared.insertItem(into: routine!)
        } else {
            navigationItem.title = "Edit Routine"
        }

        item?.name = nameField.text?.trim()
        item?.machineIdentifier = identifierField.text?.trim()
        item?.colorName = "teal"

        item?.numberOfSeries = Int64(Int(seriesField.text!.trim())!)
        item?.repetitions = Int64(Int(repetitionsField.text!.trim())!)
        item?.weightLoad = Double(weightField.text!.trim())!

        CoreDataManager.shared.saveContext()

        dismiss(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {

        guard dataIsValid else { return }

        saveData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [nameField, identifierField, seriesField, repetitionsField, weightField]
            .forEach { (textField) in textField?.delegate = self }

        if item != nil {

            nameField.text = "\(item!.name!)"
            identifierField.text = "\(item!.machineIdentifier!)"

            seriesField.text = "\(item!.numberOfSeries)"
            repetitionsField.text = "\(item!.repetitions)"
            weightField.text = "\(item!.weightLoad)"
        }

        seriesField.becomeFirstResponder()
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return false }
}

extension EditExercisesTableViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        navigationItem.rightBarButtonItem?.isEnabled = dataIsValid

        return true
    }
}
