//
//  ExercisesTableViewCell.swift
//  Routines
//
//  Created by Tiago Mergulhão on 07/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

class ExercisesTableViewCell : UITableViewCell {

    @IBOutlet weak var identifierLabel : UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var repetitionLabel: UILabel!
    @IBOutlet weak var weightLoadLabel: UILabel!
    @IBOutlet weak var weightLoadDescriptiveLabel: UILabel!

    func configure(item : Item) {

        if let equipment = item.equipment, equipment != "" {
            identifierLabel.text = item.equipment
            identifierLabel.textColor = item.color
        } else {
            identifierLabel.text = "n/a"
            identifierLabel.textColor = .darkGray
        }

        nameLabel.text = item.name
        repetitionLabel.text = "\(item.repetitions)/\(item.numberOfSeries)"

        if item.weightLoad != 0.0 {
            weightLoadLabel.text = "\(item.weightLoad)"
            weightLoadDescriptiveLabel.textColor = .black
            weightLoadLabel.textColor = .black
        } else {
            weightLoadDescriptiveLabel.textColor = .darkGray
            weightLoadLabel.textColor = .darkGray
            weightLoadLabel.text = "n/a"
        }
    }
}
