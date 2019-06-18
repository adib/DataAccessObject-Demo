//
//  AppDelegate.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 17/6/19.
//  Copyright © 2019 Basil Salad Software. All rights reserved.
//

import UIKit
import CoreData
import ReminderDataModel
import CoreDataModelImp

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reminderDAO: ReminderDAO? {
        didSet {
            if let window = self.window, let navCtrl = window.rootViewController as? UINavigationController {
                if let reminderList = navCtrl.viewControllers.first as? ReminderListTableViewController {
                    reminderList.reminderDAO = reminderDAO
                }
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let baseFolder = appSupport.appendingPathComponent("RemindersData", isDirectory: true)
        try! fm.createDirectory(at: baseFolder, withIntermediateDirectories: true, attributes: nil)
        let dataFile = baseFolder.appendingPathComponent("Reminders.sqlite")
        makeReminderDAO(file: dataFile) { (dao) in
            DispatchQueue.main.async {
                self.reminderDAO = dao
            }
        }
        return true
    }
}

