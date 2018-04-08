//
//  RoutineTableViewCell.swift
//  Routines
//
//  Created by Tiago Mergulhão on 07/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

class RoutineTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var summaryLabel : UILabel!
    @IBOutlet weak var countLabel : UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(with routine : Routine) {

        titleLabel.text = routine.name
        summaryLabel.text = routine.summary

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        dateFormatter.locale = Locale(identifier: "en_US")

        dateLabel.text = dateFormatter.string(from: routine.date ?? Date())
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
