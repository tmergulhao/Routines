//
//  RoutinesCodable.swift
//  Routines
//
//  Created by Tiago Mergulhão on 27/05/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import Foundation

struct RoutineCodable : Codable {

    var id : UUID?

    var archival : Date?
    var archived : Bool?

    var createdAt : Date
    var name : String
    var summary : String
    var lastEdited : Date
    var latestRecord : Date?

    var items : Array<ItemCodable>?
    var records : Array<RecordCodable>?
}
