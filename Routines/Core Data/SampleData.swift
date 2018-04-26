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
