//
//  DataManager.swift
//  Routines
//
//  Created by Tiago Mergulhão on 02/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    class func fetch<T : NSFetchRequestResult>(with sortDescriptor : NSSortDescriptor? = nil, and predicate : NSPredicate? = nil) throws -> Array<T> {

        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.sortDescriptors = [sortDescriptor].compactMap { $0 }
        request.predicate = predicate

        return try shared.context.fetch(request)
    }

    fileprivate lazy var container: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.name = "Shared context"

        return container
    }()

    var context : NSManagedObjectContext { return container.viewContext }
}

#if os(iOS)

extension CoreDataManager {
    class func saveContext (updading shouldUpdateWatch : Bool = false) throws {

        if shared.context.hasChanges {
            try shared.context.save()

            if shouldUpdateWatch {

                let data = try serializeRoutines()
                WatchConnectivityManager.send(data)
            }
        }
    }
}

#else

extension CoreDataManager {
    class func saveContext () throws {
        if shared.context.hasChanges { try shared.context.save() }
    }
}

#endif
