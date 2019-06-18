//
//  ReminderModelImp.swift
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

    func call<ResultType>(process: @escaping (_ context: NSManagedObjectContext) throws -> ResultType, handler: @escaping (ResultType) throws -> DataAccessCompletion, completion: ((Error?) -> Void)?) {
        let ctx = self.managedObjectContext
        ctx.perform {
            do {
                let result = try process(ctx)
                switch try handler(result) {
                case .commit:
                    try ctx.save()
                case .rollback:
                    ctx.rollback()
                }
                completion?(nil)
            } catch {
                if let completion = completion {
                    completion(error)
                }
            }
        }
    }

    func perform<Entity>(fetch: NSFetchRequest<Entity>, handler: @escaping ([Entity]) -> DataAccessCompletion, completion: ((Error?) -> Void)?) {
        self.call(process: {
            try $0.fetch(fetch)
        }, handler: handler, completion: completion)
    }

    public func listAllReminderItems(_ handler: @escaping ([ReminderItem]) -> DataAccessCompletion, _ completionStatus: ((Error?) -> Void)?) {
        let fetch: NSFetchRequest<ReminderObj> = ReminderObj.fetchRequest()
        self.perform(fetch: fetch, handler: handler, completion: completionStatus)
    }
    
    public func retrieveReminderItem(reminderID: UUID, _ handler: @escaping (ReminderItem?) -> DataAccessCompletion, _ completionStatus: ((Error?) -> Void)?) {
        let fetch: NSFetchRequest<ReminderObj> = ReminderObj.fetchRequest()
        fetch.predicate = NSPredicate.init(format: "%K == %@", #keyPath(ReminderObj.reminderID), reminderID as CVarArg)
        fetch.fetchLimit = 1
        self.perform(fetch: fetch, handler: { handler($0.first) }, completion: completionStatus)
    }
    
    public func insertReminderItem(_ handler: @escaping (ReminderItem) -> DataAccessCompletion, _ completionStatus: ((Error?) -> Void)?) {
        self.call(process: {ReminderObj.init(context: $0)}, handler: handler, completion: completionStatus)
    }
}


let persistentContainerQueue = DispatchQueue(label: "persistent-container")
var persistentContainerMap = [String:NSPersistentContainer]()


public func makeReminderDAO(file:URL, handler: @escaping (ReminderDAO) -> () ) {
    let returnDAO = {
        (container: NSPersistentContainer) in
        let ctx = container.newBackgroundContext()
        let dao = ReminderDAOImpl(ctx)
        handler(dao)
    }
    persistentContainerQueue.async {
        let key = file.absoluteString
        if let existingContainer = persistentContainerMap[key] {
            returnDAO(existingContainer)
            return
        }
        let myBundle = Bundle(for: ReminderDAOImpl.self)
        let modelFile = myBundle.url(forResource: "ReminderModel", withExtension: "momd")!
        let modelDescription = NSManagedObjectModel(contentsOf: modelFile)!
        let store = NSPersistentStoreDescription(url: file)
        store.type = NSSQLiteStoreType
        let newContainer = NSPersistentContainer(name: "Reminders", managedObjectModel: modelDescription)
        newContainer.persistentStoreDescriptions = [store]
        persistentContainerMap[key] = newContainer
        newContainer.loadPersistentStores(completionHandler: { (ps, err) in
            returnDAO(newContainer)
        })
    }
}
