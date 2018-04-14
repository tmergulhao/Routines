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

        for sampleRoutine in sampleRoutines {

            let routine : Routine = NSEntityDescription.object(into: context)

            routine.name = sampleRoutine.name
            routine.summary = sampleRoutine.summary
            routine.date = sampleRoutine.date

            if let sampleItems = sampleRoutine.items {

                for sampleItem in sampleItems {

                    let item : Item = NSEntityDescription.object(into: context)

                    item.configure(with: sampleItem)

                    routine.addToItems(item)
                }
            }

            database.addToActive(routine)
        }

        try? saveContext()
    }
}
