//
//  ItemCodable.swift
//  Routines
//
//  Created by Tiago Mergulhão on 27/05/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import Foundation

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
