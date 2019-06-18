//
//  ReminderListTableViewController.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 18/6/19.
//  Copyright © 2019 Basil Salad Software. All rights reserved.
//

import UIKit
import ReminderDataModel

class ReminderListTableViewController: UITableViewController {

    var reminderItems: ReminderListViewModel?
    
    var reminderDAO: ReminderDAO? {
        didSet {
            self.reloadData()
        }
    }
    
    func reloadData() {
        guard let dao = self.reminderDAO else {
            return
        }
        dao.listAllReminderItems({ (loadedItems) -> DataAccessCompletion in
            let reminderItems = ReminderListViewModel(items: loadedItems)
            DispatchQueue.main.async {
                self.reminderItems = reminderItems
                self.tableView.reloadData()
            }
            return .rollback
        }, nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    // MARK: - Actions

    
    @IBAction func addReminderItem(_ sender: Any) {
        guard let dao = self.reminderDAO else {
            return
        }

        let alertCtrl = UIAlertController(title: NSLocalizedString("Add Reminder", comment: "Reminder Alert"), message: "Specify Reminder Data", preferredStyle: .alert)
        alertCtrl.addTextField {
            $0.placeholder = NSLocalizedString("Reminder title", comment: "New reminder placeholder")
            $0.returnKeyType = .done
        }
        let reminderTitleTextField = alertCtrl.textFields?.first!
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: "Alert Action"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let itemTitle = reminderTitleTextField?.text
            dao.insertReminderItem({ (item: ReminderItem) -> DataAccessCompletion in
                item.title = itemTitle
                return .commit
            }, { (error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.reloadData()
                    }
                }
            })
        }))
        self.present(alertCtrl, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let itemList = self.reminderItems else {
            return 0
        }
        return itemList.itemCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let itemList = self.reminderItems else {
            return UITableViewCell()
        }
        let row = indexPath.row
        let item = itemList.item(atIndex: row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderItemCell", for: indexPath) as! ReminderItemTableViewCell
        cell.item = item
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dao = self.reminderDAO, let items = self.reminderItems else {
            return
        }
        let row = indexPath.row
        let itemModel = items.item(atIndex: row)
        let completionDate = Date()
        dao.retrieveReminderItem(reminderID: itemModel.recordID!, { (obj) -> DataAccessCompletion in
            obj!.completedTimestamp = completionDate
            return .commit
        }) { (error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.reloadData()
                }
            }
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
