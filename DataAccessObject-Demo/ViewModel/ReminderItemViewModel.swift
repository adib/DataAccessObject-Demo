//
//  ReminderItemViewModel.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 18/6/19.
//  Copyright © 2019 Basil Salad Software. All rights reserved.
//

import Foundation
import ReminderDataModel

class ReminderItemViewModel: NSObject {
    
    static let completionTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        return df
    }()
    
    var title: String?
    var recordID: UUID?
    var completionTimestamp: Date?
    var isCompleted: Bool {
        get {
            return completionTimestamp != nil
        }
    }
    
    var completionTimeString: String {
        get {
            guard let ts = completionTimestamp else {
                return ""
            }
            return ReminderItemViewModel.completionTimeFormatter.string(from: ts)
        }
    }
}


extension ReminderItemViewModel {
    func populateFrom(reminderItem item: ReminderItem) {
        self.title = item.title
        self.recordID = item.reminderID
        self.completionTimestamp = item.completedTimestamp
    }
    
    convenience init(reminderItem: ReminderItem) {
        self.init()
        populateFrom(reminderItem: reminderItem)
    }
}
