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

    @IBOutlet var colorButtons : Array<UIButton>!

    var color : UIColor?

    @IBAction func didTapColorButton(_ sender: UIButton) {

        color = sender.backgroundColor

        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {

            for button in self.colorButtons {

                guard button != sender else { continue }

                button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                button.layer.opacity = 0.5
            }

            sender.transform = .identity
            sender.layer.opacity = 1.0

        }, completion: nil)
    }

    var routine : Routine!
    var item : Item!

    @IBAction func saveButtonTapped(_ sender: Any) {

        if item == nil {
            let newItem : Item = NSEntityDescription
                .object(into: CoreDataManager.shared.context)

            newItem.id = UUID()

            item = newItem
        } else {
            navigationItem.title = "Edit Routine"
        }

        guard let item = item else { return }

        item.lastEdited = Date()
        item.name = nameField.text?.trim()
        item.equipment = identifierField.text?.trim()
        item.color = color

        if let seriesText = seriesField.text?.trim(), let series = Int64(seriesText) {
            item.numberOfSeries = series
        }
        if let repetitionsText = repetitionsField.text?.trim(), let repetitions = Int64(repetitionsText) {
            item.repetitions = repetitions
        }
        if let weightLoadText = weightField.text?.trim(), let weightLoad = Double(weightLoadText) {
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

        if item != nil {

            nameField.text = item.name
            identifierField.text = item.equipment

            seriesField.text = "\(item.numberOfSeries)"
            repetitionsField.text = "\(item.repetitions)"
            weightField.text = "\(item.weightLoad)"

            color = item.color ?? .clear
        }

        for button in colorButtons {
            if button.backgroundColor != color {
                button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                button.layer.opacity = 0.5
            }
        }

        seriesField.becomeFirstResponder()
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return false }
}
