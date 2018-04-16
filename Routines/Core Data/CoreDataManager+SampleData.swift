//
//  CoreDataManager+SampleData.swift
//  Routines
//
//  Created by Tiago Mergulhão on 06/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CoreData

extension CoreDataManager {

    func loadFromSample () {

        let routines = Sample.shared.routines

        routines.forEach {

            (codable) in

            let routine : Routine = NSEntityDescription.object(into: context)

            routine.configure(with: codable)

            guard let items = codable.items else { return }

            items.forEach {

                (codable) in

                let item : Item = NSEntityDescription.object(into: context)

                item.configure(with: codable)

                routine.addToItems(item)
            }
        }

        do {
            try saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
}
