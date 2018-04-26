//
//  CoreDataManager+Entites.swift
//  Routines
//
//  Created by Tiago Mergulhão on 06/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData
import UIKit

extension Routine {

    func configure(with codable : RoutineCodable) {

        name = codable.name
        summary = codable.summary
        createdAt = codable.createdAt
        archival = codable.archival
        lastEdited = codable.lastEdited

        archived = codable.archived ?? false
        id = codable.id ?? UUID()
    }

    var fullName : String {
        return name! + " (" + summary! + ")"
    }
}

extension Item {

    func configure(with codable : ItemCodable) {

        numberOfSeries = Int64(codable.numberOfSeries)
        repetitions = Int64(codable.repetitions)
        weightLoad = codable.weightLoad
        name = codable.name
        equipment = codable.equipment

        lastEdited = codable.lastEdited ?? Date()
        id = codable.id ?? UUID()
        color = UIColor(named: codable.colorName ?? "")
    }
}

extension NSEntityDescription {

    static func object<T : NSManagedObject>(into context : NSManagedObjectContext) -> T {

        return insertNewObject(forEntityName: String(describing: T.self), into: context) as! T
    }
}
