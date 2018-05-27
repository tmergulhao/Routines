//
//  CoreDataManager+Decodable.swift
//  Routines
//
//  Created by Tiago Mergulhão on 26/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import Foundation

extension CoreDataManager {

    // TODO: Generalize definition

    @discardableResult
    class func overrideFrom(serialized data : Data) throws -> Array<Routine> {

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let routinesCodable = try decoder.decode(Array<RoutineCodable>.self, from: data)

        let oldValues : Array<Routine> = try fetch()
        oldValues.forEach(shared.context.delete(_:))

        let routines = load(routinesCodable)

        try saveContext()

        return routines
    }
}
