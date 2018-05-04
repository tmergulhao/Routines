//
//  WatchConnectivityManager.swift
//  Routines
//
//  Created by Tiago Mergulhão on 22/04/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import WatchConnectivity

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
        let itemCodable = try decoder.decode(ItemCodable.self, from: data)

        // TODO: Use predicates to determine UUID

        guard let item : Item = (try CoreDataManager.fetch(with: nil, and: nil)).first(where: { (item : Item) -> Bool in
            return item.id == itemCodable.id
        }) else {
            return
        }

        if item.lastEdited! < itemCodable.lastEdited! {
            item.weightLoad = itemCodable.weightLoad

            try CoreDataManager.saveContext(updading: false)
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {

        if let type = userInfo["type"] as? String, type == "Item updated", let data = userInfo["data"] as? Data {

            try? updateItem(with: data)
        }
    }
}
