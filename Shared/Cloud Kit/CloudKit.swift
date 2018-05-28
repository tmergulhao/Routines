//
//  CloudKit.swift
//  Routines
//
//  Created by Tiago Mergulhão on 27/05/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import CloudKit

class CloudKitService {

    static var `default` = CloudKitService()

    var statusDefault = Default<Bool>(key: "Syncs through Cloud Kit")

    var isUsingCloudKit : Bool {
        get { return statusDefault.value ?? false }
        set (value) { statusDefault.value = value }
    }

    var container : CKContainer {
        return CKContainer(identifier: "iCloud.com.tmergulhao.Routines")
        // return CKContainer.default
    }

    var privateDatabase : CKDatabase {
        return container.privateCloudDatabase
    }

    init () {

        container.accountStatus { (status, error) in

            guard error == nil else {
                print(error!)
                return
            }

            self.respond(to: status)
        }
    }

    func respond(to status : CKAccountStatus) {

        switch (status, isUsingCloudKit) {
        case (.available, true):
            if !isUsingCloudKit {
                migrateData()
            } else {
//                sync()
            }

            try? sync()
            break
        default: // .noAccount, .restricted, .couldNotDetermine
            isUsingCloudKit = false
            break
        }
    }

    func migrateData () {

        isUsingCloudKit = true

        // try? push()
    }

    func manageConflict(between recordFound : CKRecord, and localValue : Routine) {

        if recordFound.modificationDate! > (localValue.lastEdited ?? localValue.createdAt ?? Date()) {

            localValue.imprint(with: recordFound)
            try? CoreDataManager.saveContext()

        } else if recordFound.modificationDate! < (localValue.lastEdited ?? localValue.createdAt ?? Date()) {

            localValue.configure(recordFound)

            privateDatabase.save(recordFound) {
                (record, error) in

                guard error == nil else {
                    print(error!)
                    return
                }
                print("Record updated")
            }
        }
    }

    func pushRecord(for routine : Routine) throws {

        let recordID = CKRecordID(recordName: routine.id!.uuidString)

        privateDatabase.fetch(withRecordID: recordID) {
            (possibleRecord, error) in

            if let record = possibleRecord {

                self.manageConflict(between: record, and: routine)
            } else {

                do {
                    try self.createRecord(for: routine)
                } catch {
                    print(error)
                }
            }
        }
    }

    func createRecord(for routine : Routine) throws {

        // UIApplication.shared.isNetworkActivityIndicatorVisible = false

        let encoder = CKRecordEncoder()
        let record = try encoder.encode(routine)

        privateDatabase.save(record) {
            (record, error) in

            guard error == nil else {
                print(error!)
                return
            }
            print("Record created and saved")
        }
    }

    func pull () throws {}

    func sync () throws {

        // UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let routines : Array<Routine> = try CoreDataManager.fetch()

        routines.forEach {

            routine in

            let recordID = CKRecordID(recordName: routine.id!.uuidString)

            privateDatabase.fetch(withRecordID: recordID) {
                (possibleRecord, error) in

                if let record = possibleRecord {

                    self.manageConflict(between: record, and: routine)
                } else {

                    do {
                        try self.createRecord(for: routine)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

extension Routine {

    func imprint(with record : CKRecord) {
        archival = record["archival"] as? Date
        archived = (record["archived"] as? NSNumber) == 1
        name = record["name"] as? String
        summary = record["summary"] as? String
        latestRecord = record["latestRecord"] as? Date

        lastEdited = Date()
    }

    func configure(_ record : CKRecord) {

        record["archival"] = archival as CKRecordValue?
        record["archived"] = archived as CKRecordValue
        record["name"] = name! as CKRecordValue
        record["summary"] = summary! as CKRecordValue
        record["latestRecord"] = latestRecord as CKRecordValue?
    }
}

