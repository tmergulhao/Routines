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
        createdAt = codable.date

        lastEdited = Date()
        id = UUID()
    }
}

extension Item {

    func configure(with codable : ItemCodable) {

        numberOfSeries = Int64(codable.numberOfSeries)
        repetitions = Int64(codable.repetitions)
        weightLoad = codable.weightLoad ?? 0.0
        name = codable.name

        lastEdited = Date()
        id = UUID()

        equipment = codable.equipment
        color = UIColor(named: codable.colorName ?? "green")
    }
}

extension NSEntityDescription {

    static func object<T : NSManagedObject>(into context : NSManagedObjectContext) -> T {

        return insertNewObject(forEntityName: String(describing: T.self), into: context) as! T
    }
}
