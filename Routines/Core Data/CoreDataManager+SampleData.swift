//
//  CoreDataManager+SampleData.swift
//  Routines
//
//  Created by Tiago Mergulhão on 06/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

extension CoreDataManager {

    @discardableResult
    class func load (_ codable : RoutineCodable) -> Routine {

        let routine : Routine = NSEntityDescription.object(into: shared.context)

        routine.configure(with: codable)

        codable.items?.forEach {

            (codable) in

            let item : Item = NSEntityDescription.object(into: shared.context)

            item.configure(with: codable)

            routine.addToItems(item)
        }

        codable.records?.forEach {

            (codable) in

            let record : Record = NSEntityDescription.object(into: shared.context)

            record.date = codable.date

            routine.addToRecords(record)
        }

        routine.latestRecord = codable.records?.first?.date

        return routine
    }

    @discardableResult
    class func load (_ codables : Array<RoutineCodable>) -> Array<Routine> {

        return codables.map { (codable) in return self.load(codable) }
    }
}
