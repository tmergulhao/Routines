//
//  CoreDataManager+Serialize.swift
//  Routines
//
//  Created by Tiago Mergulhão on 23/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit

fileprivate var colors = ["blue", "green", "orange", "red", "teal"]
    .reduce(into: Dictionary<UIColor, String>(), {
        (dictionary : inout Dictionary<UIColor, String>, name : String) in
        guard let color = UIColor(named: name) else { return }
        dictionary[color] = name
    })

extension Routine : Encodable {

    enum CodingKeys : String, CodingKey {
        case archival, archived, createdAt, id, lastEdited, name, summary, items
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(archival, forKey: .archival)
        try container.encode(archived, forKey: .archived)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(id, forKey: .id)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(name, forKey: .name)
        try container.encode(summary, forKey: .summary)

        let items : Array<Item> = Array(self.items!) as! Array<Item>

        try container.encode(items, forKey: .items)
    }
}

extension Item : Encodable {

    enum CodingKeys : String, CodingKey {
        case color = "color_name"
        case equipment, id, lastEdited, name, numberOfSeries, repetitions, weightLoad
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(equipment, forKey: .equipment)
        try container.encode(id, forKey: .id)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(name, forKey: .name)
        try container.encode(numberOfSeries, forKey: .numberOfSeries)
        try container.encode(repetitions, forKey: .repetitions)
        try container.encode(weightLoad, forKey: .weightLoad)

        if let color = color, let colorName = colors[color] {
            try container.encode(colorName, forKey: .color)
        } else {
            let stringNil : String? = nil
            try container.encode(stringNil, forKey: .color)
        }
    }
}

extension CoreDataManager {

    // TODO: Generalize definition

    class func serializeRoutines() throws -> Data {

        let notArchived = NSPredicate(format: "archived == false")
        let routines : Array<Routine> = try fetch(with: nil, and: notArchived)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase

        return try encoder.encode(routines)
    }
}
