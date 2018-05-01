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

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        guard url.pathExtension == "routine" else { return false }

        // TODO: Inform user it was not able to import routines from file

        do {

            let data = try Data(contentsOf: url)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            if let codable = try? decoder.decode(RoutineCodable.self, from: data) {
                CoreDataManager.load(codable)
                try CoreDataManager.saveContext()
            }

            if let codable = try? decoder.decode(Array<RoutineCodable>.self, from: data) {
                CoreDataManager.load(codable)
                try CoreDataManager.saveContext()
            }

        } catch {

            print(error.localizedDescription)
            return false
        }

        if let navigation = window?.rootViewController as? UINavigationController,
            let routineViewController = navigation.viewControllers.first as? RoutinesViewController {

            navigation.popToRootViewController(animated: true)
            routineViewController.tableView.reloadData()
        }

        return true
    }
}
