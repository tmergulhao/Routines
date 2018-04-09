//
//  DataManager.swift
//  Routines
//
//  Created by Tiago Mergulhão on 02/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

extension Routine {

    static var active : Array<Routine> {
        return CoreDataManager.shared.database.active?.array as? Array<Routine> ?? []
    }

    static var archived : Array<Routine> {
        return CoreDataManager.shared.database.archived?.array as? Array<Routine> ?? []
    }
}

class CoreDataManager {

    static let shared = CoreDataManager()

    lazy var database : DatabaseView = {

        if let databases : Array<DatabaseView> = fetch(), databases.count != 0 {

            return databases[0]
        }

        let newDatabase : DatabaseView = NSEntityDescription.object(into: context)

        do {
            try saveContext()
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }

        return newDatabase
    }()

    func reloadData () {

        database = fetch()![0]
    }

    func fetch<T : NSFetchRequestResult>(with sortDescriptor : NSSortDescriptor? = nil) -> Array<T>? {

        do {
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            request.sortDescriptors = [sortDescriptor].compactMap { $0 }

            return try context.fetch(request)
        } catch {

            print(error)
        }

        return nil
    }

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var context : NSManagedObjectContext { return persistentContainer.viewContext }

    func saveContext () throws {

        if context.hasChanges { try context.save() }

        reloadData()
    }
}
