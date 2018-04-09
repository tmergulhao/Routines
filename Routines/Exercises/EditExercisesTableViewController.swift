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

    var color : UIColor = UIColor(named: "green")!

    @IBAction func didTapColorButton(_ sender: UIButton) {

        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {

            for button in self.colorButtons {

                guard button != sender else { continue }

                button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                button.layer.opacity = 0.5
            }

            sender.transform = .identity
            sender.layer.opacity = 1.0

            self.color = sender.backgroundColor!

        }, completion: nil)
    }

    var routine : Routine!
    var item : Item!

    @IBAction func saveButtonTapped(_ sender: Any) {

        if item == nil {
            item = CoreDataManager.shared.insertItem()
        } else {
            navigationItem.title = "Edit Routine"
        }

        guard let item = item else { return }

        item.name = nameField.text?.trim()
        item.equipment = identifierField.text?.trim()
        item.color = color

        item.numberOfSeries = Int64(Int(seriesField.text!.trim())!)
        item.repetitions = Int64(Int(repetitionsField.text!.trim())!)
        item.weightLoad = Double(weightField.text!.trim())!

        routine.insertIntoItems(item, at: 0)

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
