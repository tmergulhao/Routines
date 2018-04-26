//
//  CoreDataManager+SampleData.swift
//  Routines
//
//  Created by Tiago Mergulhão on 06/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

extension CoreDataManager {

    class func load (_ routines : Array<RoutineCodable>) throws {

        routines.forEach {

            (codable) in

            let routine : Routine = NSEntityDescription.object(into: shared.context)

            routine.configure(with: codable)

            guard let items = codable.items else { return }

            items.forEach {

                (codable) in

                let item : Item = NSEntityDescription.object(into: shared.context)

                item.configure(with: codable)

                routine.addToItems(item)
            }
        }

        try saveContext()
    }
}
