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

    func load<T : Codable>() -> Array<T>? {

        guard let path = Bundle.main.path(forResource: String(describing: T.self), ofType: "json") else { return nil }

        let url = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: url) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try? decoder.decode(Array<T>.self, from: data)
    }

    lazy var routines : Array<RoutineCodable> = { return load() ?? [] }()

    lazy var machines : Array<MachineCodable> = { return load() ?? [] }()

    lazy var machinesDictionary : Dictionary<String,MachineCodable> = {
        return machines.reduce(into: [:], { (dictionary : inout Dictionary<String,MachineCodable>, machine : MachineCodable) in
            dictionary[machine.identifier] = machine
        })
    }()
}
