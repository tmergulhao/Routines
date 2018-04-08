//
//  ExercisesTableViewController+EmptyStateViewControllerDelegate.swift
//  Routines
//
//  Created by Tiago Mergulhão on 07/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

extension ExercisesTableViewController : EmptyStateViewControllerDelegate {

    func emptyStateControllerDidReceivePrimaryAction(sender: Any?) {

        performSegue(withIdentifier: "Edit Item", sender: nil)
    }

    func configure(emptyState viewController: EmptyStateViewController, withIdentifier identifier: String) {

        viewController.primaryButton.setImage(UIImage(named: "Add"), for: .normal)
        viewController.titleLabel.text = "Add new exercise"
        viewController.summaryLabel.text = "Begin by adding a exercises to your routine"
        viewController.secondaryButton.isHidden = true
    }
}
