//
//  CoreDataManager+Entites.swift
//  Routines
//
//  Created by Tiago Mergulhão on 06/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

extension NSEntityDescription {

    static func object<T : NSManagedObject>(into context : NSManagedObjectContext) -> T {

        return insertNewObject(forEntityName: String(describing: T.self), into: context) as! T
    }
}

extension CoreDataManager {

    func archive(_ routine : Routine) {

        database.insertIntoArchived(routine, at: 0)
        database.removeFromActive(routine)

        saveContext()
    }

    func unarchive(_ routine : Routine) {

        database.insertIntoActive(routine, at: 0)
        database.removeFromArchived(routine)

        saveContext()
    }

    func remove(_ routine : Routine) {

        database.removeFromArchived(routine)
        context.delete(routine)
        
        saveContext()
    }

    func remove(_ item : Item, from routine : Routine) {

        routine.removeFromItems(item)
        context.delete(item)

        saveContext()
    }

    @discardableResult
    func insertRoutine() -> Routine {

        let routine : Routine = NSEntityDescription.object(into: context)

        database.insertIntoActive(routine, at: 0)

        return routine
    }

    @discardableResult
    func insertItem(into routine : Routine) -> Item {

        let item : Item = NSEntityDescription.object(into: context)

        routine.insertIntoItems(item, at: 0)

        return item
    }
}
