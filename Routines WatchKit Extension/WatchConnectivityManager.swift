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

    var delegate : WatchConnectivityManagerDelegate?

    class func begin () {

        guard WCSession.isSupported() else { return }

        watchSession.delegate = self.shared

        watchSession.activate()
    }

    class func updated(_ item : Item) {

        let encoder = JSONEncoder()

        guard let item = try? encoder.encode(item) else { return }

        watchSession.transferUserInfo([
            "type": "Item updated",
            "data": item
        ])
    }
}

protocol WatchConnectivityManagerDelegate {

    func watchConnectivity(_ manager : WatchConnectivityManager, didUpdate routines : Array<Routine>, at date : Date)

    func watchConnectivityStartedUpdating(_ manager : WatchConnectivityManager)
}

extension WatchConnectivityManager : WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {

        let string = String(data: messageData, encoding: .utf8)

        UserDefaults.standard.set(string, forKey: "Message Data")

        replyHandler(messageData)
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {

        delegate?.watchConnectivityStartedUpdating(self)

        do {
            let data = try Data(contentsOf: file.fileURL)
            let routines = try CoreDataManager.overrideFrom(serialized: data)

            let date = Date()

            var lastUpdated = Default<Date>(key: "Last updated on Watch")
            lastUpdated.value = date

            delegate?.watchConnectivity(self, didUpdate: routines, at: date)

        } catch {
            print(error.localizedDescription)
        }
    }
}
