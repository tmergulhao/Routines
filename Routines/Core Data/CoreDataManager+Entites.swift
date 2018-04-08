//
//  CoreDataManager+Entites.swift
//  Routines
//
//  Created by Tiago Mergulhão on 06/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData
import UIKit

extension Item {

    func configure(with item : ItemCodable, and machine : MachineCodable?) {

        numberOfSeries = Int64(item.numberOfSeries)
        repetitions = Int64(item.repetitions)
        weightLoad = item.weightLoad ?? 0.0

        name = item.exercise.name

        equipment = machine?.identifier
        color = UIColor(named: machine?.colorName ?? "green")
    }
}

extension NSEntityDescription {

    static func object<T : NSManagedObject>(into context : NSManagedObjectContext) -> T {

        return insertNewObject(forEntityName: String(describing: T.self), into: context) as! T
    }
}

extension CoreDataManager {

    func archive(_ routine : Routine) {

        database.insertIntoArchived(routine, at: 0)
        database.removeFromActive(routine)

        do {
            try saveContext()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }

    func unarchive(_ routine : Routine) {

        database.insertIntoActive(routine, at: 0)
        database.removeFromArchived(routine)

        do {
            try saveContext()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }

    func remove(_ routine : Routine) {

        database.removeFromArchived(routine)
        context.delete(routine)
        
        do {
            try saveContext()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }

    func remove(_ item : Item, from routine : Routine) {

        routine.removeFromItems(item)
        context.delete(item)

        do {
            try saveContext()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }

    @discardableResult
    func insertRoutine() -> Routine {

        let routine : Routine = NSEntityDescription.object(into: context)

        database.insertIntoActive(routine, at: 0)

        routine.date = Date()

        return routine
    }

    @discardableResult
    func insertItem() -> Item {

        let item : Item = NSEntityDescription.object(into: context)

        return item
    }
}
