//
//  SplitViewDelegate.swift
//  Routines
//
//  Created by Tiago Mergulhão on 02/05/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

class SplitViewDelegate : NSObject, UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {

        if let navigation = secondaryViewController as? UINavigationController, let detail = navigation.topViewController as? ExercisesTableViewController, detail.routine == nil {
            return true
        }

        return false
    }
}
