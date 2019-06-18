//
//  AppDelegate.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 17/6/19.
//  Copyright © 2019 Basil Salad Software. All rights reserved.
//  https://cutecoder.org
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

