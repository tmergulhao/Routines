//
//  CoreDataManager+SampleData.swift
//  Routines
//
//  Created by Tiago Mergulhão on 06/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

extension CoreDataManager {

    func loadFromSample () {

        let sampleRoutines = Sample.shared.routines
        let sampleMachines = Sample.shared.machinesDictionary

        for sampleRoutine in sampleRoutines {

            let routine : Routine = NSEntityDescription.object(into: context)

            routine.name = sampleRoutine.name
            routine.summary = sampleRoutine.summary
            routine.date = sampleRoutine.date

            if let sampleItems = sampleRoutine.items {

                for sampleItem in sampleItems {

                    let item : Item = NSEntityDescription.object(into: context)

                    let sampleMachineIdentifier = sampleItem.exercise.machineIdentifier
                    let sampleMachine = sampleMachines[sampleMachineIdentifier ?? ""]

                    item.configure(with: sampleItem, and: sampleMachine)

                    routine.addToItems(item)
                }
            }

            database.addToActive(routine)
        }

        try? saveContext()
    }
}
