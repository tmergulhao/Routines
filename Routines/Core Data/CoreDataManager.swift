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
}

#if os(iOS)

extension CoreDataManager {
    class func saveContext () throws {

        if shared.context.hasChanges {
            try shared.context.save()

            let data = try serializeRoutines()
            WatchConnectivityManager.shared.send(data)
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
