//
//  CoreDataManager+Serialize.swift
//  Routines
//
//  Created by Tiago Mergulhão on 23/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import WatchKit
#endif

extension UIColor {

    var keyRepresentation : String {
        return self.cgColor.components?.reduce("", { (result, component) -> String in
            return result + " \(component)"
        }) ?? ""
    }
}

fileprivate var colors = ["blue", "green", "orange", "red", "teal"]
    .reduce(into: Dictionary<String, String>(), {
        (dictionary : inout Dictionary<String, String>, name : String) in
        guard let key = UIColor(named: name)?.keyRepresentation else { return }
        dictionary[key] = name
    })

extension Routine : Encodable {

    enum CodingKeys : String, CodingKey {
        case archival, archived, createdAt, id, lastEdited, name, summary, items, records, latestRecord
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)


        try container.encode(archived, forKey: .archived)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(summary, forKey: .summary)
        try container.encode(latestRecord, forKey: .latestRecord)

        if let archival = archival {
            try container.encode(archival, forKey: .archival)
        }

        if let lastEdited = lastEdited {
            try container.encode(lastEdited, forKey: .lastEdited)
        }

        if let sequence = items, let items = Array(sequence) as? Array<Item> {
            try container.encode(items, forKey: .items)
        }

        if let sequence = records, let records = Array(sequence) as? Array<Record> {
            try container.encode(records, forKey: .records)
        }
    }
}

extension Routine : CKRecordRepresentable {

    public var recordTypeName : String { return "Routine" }
    public var recordName : String { return id!.uuidString }
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

        if let key = color?.keyRepresentation, let colorName = colors[key] {
            try container.encode(colorName, forKey: .color)
        } else {
            let stringNil : String? = nil
            try container.encode(stringNil, forKey: .color)
        }
    }
}

extension Item : CKRecordRepresentable {

    public var recordTypeName : String { return "Item" }
    public var recordName : String { return id!.uuidString }
}

extension Record : Encodable {

    enum CodingKeys : String, CodingKey {
        case date
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
    }
}

extension Record : CKRecordRepresentable {

    public var recordTypeName : String { return "Item" }
    public var recordName : String { return routine!.id!.uuidString + "\(date!)" }
}

extension CoreDataManager {

    // TODO: Generalize definition

    class func serialize(_ routine : Routine) throws -> Data {

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase

        return try encoder.encode(routine)
    }

    class func serializeRoutines() throws -> Data {

        let notArchived = NSPredicate(format: "archived == false")
        let routines : Array<Routine> = try fetch(with: nil, and: notArchived)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase

        return try encoder.encode(routines)
    }
}
