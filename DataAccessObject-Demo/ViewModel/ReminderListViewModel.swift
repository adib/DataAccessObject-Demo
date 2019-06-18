//
//  ReminderListViewModel.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 18/6/19.
//  Copyright © 2019 Basil Salad Software. All rights reserved.
//

import Foundation
import ReminderDataModel

class ReminderListViewModel: NSObject {
    var items = [ReminderItemViewModel]()
    var itemCount: Int {
        return items.count
    }
    
    func item(atIndex i: Int) -> ReminderItemViewModel {
        return items[i]
    }
}


extension ReminderListViewModel {
    convenience init(items: [ReminderItem]) {
        self.init()
        self.items = items.map(ReminderItemViewModel.init(reminderItem:))
    }
}
