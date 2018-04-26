//
//  CoreDataManager+Decodable.swift
//  Routines
//
//  Created by Tiago Mergulhão on 26/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import Foundation

struct RoutineCodable : Codable {

    var archival : Date?
    var archived : Bool?
    var id : UUID?

    var createdAt : Date
    var name : String
    var summary : String
    var lastEdited : Date

    var items : Array<ItemCodable>?
}

struct ItemCodable : Codable {

    var colorName : String?
    var equipment : String?
    var lastEdited : Date?
    var id : UUID?

    var name : String
    var numberOfSeries : Int
    var repetitions : Int
    var weightLoad : Double
}

extension CoreDataManager {

    // TODO: Generalize definition

    class func overrideFrom(serialized data : Data) throws {

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let routinesCodable = try decoder.decode(Array<RoutineCodable>.self, from: data)

        let oldValues : Array<Routine> = try fetch()
        oldValues.forEach(shared.context.delete(_:))

        try load(routinesCodable)
    }
}
