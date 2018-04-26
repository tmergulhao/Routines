//
//  AppDelegate.swift
//  Routines
//
//  Created by Tiago Mergulhão on 31/03/18.
//  Copyright © 2018 Tiago Mergulhão. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        WatchConnectivityManager.begin()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        try? CoreDataManager.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? CoreDataManager.saveContext()
    }
}
