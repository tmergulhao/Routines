//
//  ExercisesTableViewController+Navigation.swift
//  Routines
//
//  Created by Tiago Mergulhão on 29/05/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

extension ExercisesTableViewController {

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        if identifier == "Edit Item" && !routine.archived { return true }

        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "Edit Item",
            let navigation = segue.destination as? UINavigationController,
            let editItem = navigation.topViewController as? EditExercisesTableViewController {

            editItem.item = sender as? Item
            editItem.routine = routine
        }
    }
}
