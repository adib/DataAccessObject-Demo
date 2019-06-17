//
//  ReminderModelImp.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 17/6/19.
//  Copyright © 2019 Basil Salad Software. All rights reserved.
//

import Foundation
import CoreData
import ReminderDataModel


extension ReminderObj : ReminderItem { }

public extension ReminderObj {
    override func awakeFromInsert() {
        setPrimitiveValue(UUID(), forKey: "reminderID")
    }
}

public class ReminderDAOImpl: ReminderDAO {
    let managedObjectContext: NSManagedObjectContext
    init(_ context: NSManagedObjectContext) {
        managedObjectContext = context
    }

    func perform<Entity>(fetch: NSFetchRequest<Entity>, handler: @escaping ([Entity]) -> DataAccessCompletion, completion: ((Error?) -> Void)?) {
        let ctx = self.managedObjectContext
        ctx.perform {
            do {
                let result = try ctx.fetch(fetch)
                switch handler(result) {
                case .commit:
                    try ctx.save()
                case .rollback:
                    ctx.rollback()
                }
            } catch {
                if let completion = completion {
                    completion(error)
                }
            }
        }
    }

    public func listAllReminderItems(_ handler: @escaping ([ReminderItem]) -> DataAccessCompletion, _ completionStatus: ((Error?) -> Void)?) {
        let fetch: NSFetchRequest<ReminderObj> = ReminderObj.fetchRequest()
        self.perform(fetch: fetch, handler: handler, completion: completionStatus)
    }
    
    
    public func retrieveReminderItem(reminderID: UUID, _ handler: @escaping (ReminderItem?) -> DataAccessCompletion, _ completionStatus: ((Error?) -> Void)?) {
        let fetch: NSFetchRequest<ReminderObj> = ReminderObj.fetchRequest()
        fetch.predicate = NSPredicate.init(format: "%K == %@", #keyPath(ReminderObj.reminderID), reminderID as CVarArg)
        fetch.fetchLimit = 1
        self.perform(fetch: fetch, handler: { (result: [ReminderObj]) -> DataAccessCompletion in
            handler(result.first)
        }, completion: completionStatus)
    }
}
