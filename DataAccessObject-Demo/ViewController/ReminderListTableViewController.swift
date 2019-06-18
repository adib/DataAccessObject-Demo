//
//  ReminderListTableViewController.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 18/6/19.
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
}
