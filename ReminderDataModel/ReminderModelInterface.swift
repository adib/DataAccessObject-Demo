//
//  ReminderModel.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 17/6/19.
//  Copyright © 2019 Basil Salad Software. All rights reserved.
//

import Foundation

public enum DataAccessCompletion {
    case commit
    case rollback
}

public protocol ReminderItem : class {
    var title: String? { get set }
    var completedTimestamp: Date? { get set }
    var reminderID: UUID? { get set }
}

public protocol ReminderDAO {
    func listAllReminderItems(_  handler:  @escaping ([ReminderItem]) -> DataAccessCompletion, _ completionStatus: ((Error?) -> Void)? ) 
    func retrieveReminderItem(reminderID: UUID, _ handler:  @escaping(ReminderItem?) -> DataAccessCompletion, _ completionStatus:  ((Error?) -> Void)?)
    func insertReminderItem( _ handler:  @escaping(ReminderItem) -> DataAccessCompletion, _ completionStatus:  ((Error?) -> Void)?)

}
