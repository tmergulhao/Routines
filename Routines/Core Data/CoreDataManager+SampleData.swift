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

            if let sampleItems = sampleRoutine.items {

                for sampleItem in sampleItems {

                    let item : Item = NSEntityDescription.object(into: context)

                    item.numberOfSeries = Int64(sampleItem.numberOfSeries)
                    item.repetitions = Int64(sampleItem.repetitions)
                    item.weightLoad = sampleItem.weightLoad ?? 0.0

                    item.name = sampleItem.exercise.name

                    if let sampleMachineIdentifier = sampleItem.exercise.machineIdentifier,
                        let sampleMachine = sampleMachines[sampleMachineIdentifier] {

                        item.machineIdentifier = sampleMachine.identifier
                        item.colorName = sampleMachine.colorName
                    }

                    routine.addToItems(item)
                }
            }

            database.addToActive(routine)
        }

        try? saveContext()
    }
}
