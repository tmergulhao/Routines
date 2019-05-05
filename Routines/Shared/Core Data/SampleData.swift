//
//  DataManager.swift
//  Routines
//
//  Created by Tiago Mergulhão on 02/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import Foundation

class Sample {

    static let shared = Sample()

    func load<T : Codable>() throws -> Array<T> {

        guard let path = Bundle.main.path(forResource: String(describing: T.self), ofType: "json") else { return [] }

        let url = URL(fileURLWithPath: path)

        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(Array<T>.self, from: data)
    }

    lazy var routines : Array<RoutineCodable> = {

        do {

            let values : Array<RoutineCodable> = try load()
            return values
        } catch {
            print(error.localizedDescription)
            return []
        }
    }()
}

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
