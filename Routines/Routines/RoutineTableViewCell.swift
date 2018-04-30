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
    @IBOutlet weak var itemsStack: UIStackView!

    func configure(with routine : Routine) {

        titleLabel.text = routine.name
        summaryLabel.text = routine.summary

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        dateFormatter.locale = Locale(identifier: "en_US")

        dateLabel.text = dateFormatter.string(from: routine.createdAt!)

        if let items = routine.items {

            itemsStack.isHidden = false

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                self.configureItemStack(for: items)
            }

            countLabel.text = "\(items.count)"
            countLabel.textColor = .black

        } else {

            itemsStack.isHidden = true

            countLabel.text = "n/a"
            countLabel.textColor = .lightGray
        }
    }

    func configureItemStack(for items : NSOrderedSet) {

        let difference = items.count - itemsStack.subviews.count

        if difference > 0 {

            for _ in 0..<difference {

                let view = UIView()
                view.layer.cornerRadius = 8.0
                let constraints = [view.heightAnchor.constraint(equalToConstant: 16.0),
                                   view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.0)]

                itemsStack.addSubview(view)
                NSLayoutConstraint.activate(constraints)
            }

        } else if difference < 0 {

            for _ in 0..<(-difference) {
                itemsStack.subviews.first?.removeFromSuperview()
            }
        }

        for (index, item) in items.enumerated() {
            itemsStack.subviews[index].backgroundColor = (item as? Item)?.color ?? .lightGray
        }

        itemsStack.setNeedsDisplay()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

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
