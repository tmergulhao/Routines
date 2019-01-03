//
//  WatchConnectivityManager.swift
//  Routines
//
//  Created by Tiago Mergulhão on 22/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchConnectivity
import CoreData

class WatchConnectivityManager : NSObject {

    static let watchSession = WCSession.default

    static var shared = WatchConnectivityManager()

    class func begin () {

        guard WCSession.isSupported() else { return }

        watchSession.delegate = self.shared

        watchSession.activate()
    }

    private class func cancelTransfers () {

        watchSession.outstandingFileTransfers.forEach { $0.cancel() }
    }

    class func send (_ data : Data) {

        guard watchSession.activationState == .activated else {
            WatchConnectivityManager.begin()
            return
        }

        let manager = FileManager.default
        let directory = manager.urls(for: .documentDirectory, in: .userDomainMask)

        guard let url = directory.first?.appendingPathComponent("Database.routine") else {
            print("Unable to get file directory url")
            return
        }

        do {
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }

        watchSession.transferFile(url, metadata: [:])
    }
}

extension WatchConnectivityManager : WCSessionDelegate {

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch Connection session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("Watch Connection session deactivated")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

        if let error = error {

            print(error.localizedDescription)
            return
        }

        let watchSession = WCSession.default

        if watchSession.isPaired && watchSession.isWatchAppInstalled {

            do {
                let data = try CoreDataManager.serializeRoutines()
                WatchConnectivityManager.send(data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func sessionWatchStateDidChange(_ session: WCSession) {

        if session.isPaired && session.isWatchAppInstalled {

            do {
                let data = try CoreDataManager.serializeRoutines()
                WatchConnectivityManager.send(data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func updateItem(with data : Data) throws {

        let decoder = JSONDecoder()
        let codable = try decoder.decode(ItemCodable.self, from: data)

        guard let item : Item = try CoreDataManager.fetch(with: codable.id!) else { return }

        if item.lastEdited! < codable.lastEdited! {
            item.weightLoad = codable.weightLoad

            try CoreDataManager.saveContext(updading: false)
        }
    }

    func makeRecordForRoutine(with data : Data, on date : Date) throws {

        let decoder = JSONDecoder()
        let codable = try decoder.decode(RoutineCodable.self, from: data)

        guard let routine : Routine = try CoreDataManager.fetch(with: codable.id!) else { return }

        if let latest = routine.latestRecord, Calendar.current.isDate(latest, equalTo: date, toGranularity: .day) { return }

        let record : Record = NSEntityDescription
            .object(into: CoreDataManager.shared.context)

        record.date = date

        routine.latestRecord = date
        routine.insertIntoRecords(record, at: 0)

        try CoreDataManager.saveContext(updading: false)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {

        if let type = userInfo["type"] as? String,
            type == "Item updated",
            let data = userInfo["data"] as? Data {

            try? updateItem(with: data)
        }

        if let type = userInfo["type"] as? String,
            type == "Routine record",
            let data = userInfo["data"] as? Data,
            let date = userInfo["date"] as? Date {

            try? makeRecordForRoutine(with: data, on: date)
        }
    }
}
