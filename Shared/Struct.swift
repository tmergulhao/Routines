//
//  Struct.swift
//  Routines
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import Foundation

struct ItemCodable : Codable {
    var numberOfSeries : Int
    var repetitions : Int
    var weightLoad : Double?

    var colorName : String?
    var equipment : String?
    var name : String
}

struct RoutineCodable : Codable {
    var name : String
    var summary : String
    var items : Array<ItemCodable>?
    var date : Date
}

extension RoutineCodable {
    var fullName : String {
        return name + " (" + summary + ")"
    }
}
