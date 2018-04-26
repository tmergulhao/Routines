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

        let sample = Sample.shared.routines

        try? CoreDataManager.load(sample)

        tableView.reloadData()
    }
}
