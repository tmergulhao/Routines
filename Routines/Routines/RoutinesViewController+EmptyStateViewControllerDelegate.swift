//
//  RoutinesViewController+EmptyStateViewControllerDelegate.swift
//  Routines
//
//  Created by Tiago Mergulhão on 07/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

extension RoutinesViewController : EmptyStateViewControllerDelegate {

    func emptyStateControllerDidReceivePrimaryAction(sender: Any?) {

        performSegue(withIdentifier: "Edit Routine", sender: nil)
    }

    func emptyStateControllerDidReceiveSecondaryAction(sender: Any?) {

        CoreDataManager.shared.loadFromSample()

        tableView.reloadData()
    }
}
