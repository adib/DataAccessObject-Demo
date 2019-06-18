//
//  ReminderItemTableViewCell.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 18/6/19.
//  Copyright © 2019 Basil Salad Software. All rights reserved.
//

import UIKit

class ReminderItemTableViewCell: UITableViewCell {

    var item: ReminderItemViewModel? {
        didSet {
            guard let record = item else {
                self.textLabel?.text = ""
                self.detailTextLabel?.text = ""
                return
            }
            if record.isCompleted {
                self.textLabel?.text = String.localizedStringWithFormat(NSLocalizedString("[Done] %@", comment: "Done item"), record.title ?? "")
            } else {
                self.textLabel?.text = record.title
            }
            
            self.detailTextLabel?.text = record.completionTimeString
        }
    }
    
    override func prepareForReuse() {
        self.textLabel?.text = ""
        self.detailTextLabel?.text = ""

        super.prepareForReuse()
    }

}
