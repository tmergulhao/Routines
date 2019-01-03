//
//  EditExercisesTableViewController.swift
//  Routines
//
//  Created by Tiago Mergulhão on 07/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit
import CoreData

extension String {

    func trim () -> String { return trimmingCharacters(in: .whitespacesAndNewlines) }
}

class EditExercisesTableViewController: UITableViewController {

    @IBOutlet weak var seriesField : UITextField!
    @IBOutlet weak var repetitionsField : UITextField!
    @IBOutlet weak var weightField : UITextField!

    @IBOutlet weak var identifierField : UITextField!
    @IBOutlet weak var nameField : UITextField!

    @IBOutlet weak var colorButton : UIButton!

    var color : UIColor = .clear

    var routine : Routine!
    var item : Item!

    @IBAction func saveButtonTapped(_ sender: Any) {

        if item == nil {

            let newItem : Item = NSEntityDescription
                .object(into: CoreDataManager.shared.context)

            newItem.id = UUID()

            item = newItem
        }

        guard let item = item else { return }

        item.lastEdited = Date()
        item.name = nameField.text?.trim()
        item.equipment = identifierField.text?.trim()
        item.color = color

        if let seriesText = seriesField.text?.trim(),
            let series = Int64(seriesText) {
            item.numberOfSeries = series
        }
        if let repetitionsText = repetitionsField.text?.trim(),
            let repetitions = Int64(repetitionsText) {
            item.repetitions = repetitions
        }
        if let weightLoadText = weightField.text?.trim(),
            let weightLoad = Double(weightLoadText) {
            item.weightLoad = weightLoad
        }

        routine.insertIntoItems(item, at: 0)

        do {
            try CoreDataManager.saveContext()
        } catch {
            
            informUser(about: error)
            return
        }

        dismiss(animated: true)
    }

    func informUser(about error : Error) {

        // TODO: Inform user about data sanitization

        let alert = UIAlertController(title: "Unable to save", message: "There is something wrong with your form. Please, correct the following mistakes: \(error.localizedDescription)", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true)
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        seriesField.becomeFirstResponder()

        guard let item = item else { return }

        navigationItem.title = "Edit Item"

        nameField.text = item.name
        identifierField.text = item.equipment

        seriesField.text = "\(item.numberOfSeries)"
        repetitionsField.text = "\(item.repetitions)"
        weightField.text = "\(item.weightLoad)"

        colorSelection(didSelect: item.color ?? .clear)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return false }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "Color Selection", let colorSelection = segue.destination as? ColorSelectionViewController {

            colorSelection.delegate = self
        }
    }
}
