//
//  Struct.swift
//  Routines
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import Foundation

struct MachineCodable : Codable {
    var identifier : String
    var colorName : String
}

struct ExerciseCodable : Codable {
    var name : String
    var machineIdentifier : String?
}

struct ItemCodable : Codable {
    var exercise : ExerciseCodable
    var numberOfSeries : Int
    var repetitions : Int
    var weightLoad : Double?
}

struct RoutineCodable : Codable {
    var name : String
    var summary : String
    var items : Array<ItemCodable>?
}

extension RoutineCodable {
    var fullName : String {
        return name + " (" + summary + ")"
    }
}
