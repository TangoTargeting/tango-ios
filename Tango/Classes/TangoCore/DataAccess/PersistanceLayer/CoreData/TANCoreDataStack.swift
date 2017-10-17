//
//  TANCoreDataStack.swift
//  Tango
//
//  Created by Raul Hahn on 14/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import CoreData

final class TANCoreDataStack {
    init() {
        
        // subscribe to notifications sent by main and background NSManagedObjectContext's on save.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TANCoreDataStack.mainContextChanged(notification:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: self.managedObjectContext)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TANCoreDataStack.bgContextChanged(notification:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: self.backgroundManagedObjectContext)
    }
    
    // MARK: - Core Data stack
    
    // Extracted documents directory NSURL getter. NSPersistentStoreCoordinator uses it to create NSPersistentStore at given location.
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    // Extracted NSManagedObjectModel getter is used to initialize NSPersistentStoreCoordinator with our model.
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL =  Bundle(for: Tango.self).url(forResource: "Tango", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // We create NSPersitentStoreCoordinator with model. Then we retrieve url of our documents directory. Finally we add a persitent store of certain type to NSPersitentStoreCoordinator at documents directory.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Tango.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: url,
                                               options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                         NSInferMappingModelAutomaticallyOption: true])
        } catch {
            // Report any error we got.
            dLogError(message: "CoreData error \(error), \(String(describing: error._userInfo))")
        }
        return coordinator
    }()
    
    // We create a 'background' NSManagedObjectContext in a private queue and attach it to our NSPersistentStoreCoordinator. This context is used to perform syncronisation and write operations.
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.persistentStoreCoordinator = coordinator
        return privateManagedObjectContext
    }()
    
    // Create a 'view' NSManagedObjectContext in a main queue and attach it to our NSPersistentStoreCoordinator. This context is used to fetch data to be displayed on UI.
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainManagedObjectContext.persistentStoreCoordinator = coordinator
        return mainManagedObjectContext
    }()
    
    // This stack uses good old merging contexts triggered on save notifications. In these methods we perform this merging.
    @objc func mainContextChanged(notification: NSNotification) {
        backgroundManagedObjectContext.perform { [weak self] in
            self?.backgroundManagedObjectContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
    
    @objc func bgContextChanged(notification: NSNotification) {
        managedObjectContext.perform{ [weak self] in
            self?.managedObjectContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
    
    // MARK: - Core Data methods
    
    func saveMainContext() {
        let context = managedObjectContext
        context.perform { 
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let error = error as NSError
                    dLogError(message: "Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func saveContext(context: NSManagedObjectContext) {
        context.perform { 
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let error = error as NSError
                    dLogError(message: "Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    // use this method to create a new managed object and after that set the properties for each AnyClass type. And save it to core data
    func createManagedObjectForClassName(entityName: String) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: entityName,
                                                   into: managedObjectContext)
    }
    
    func saveObject(managedObject: NSManagedObject) {
        managedObject.managedObjectContext?.perform({[weak weakSelf = self] in
            if managedObject.hasChanges {
                if let managedObjectContext = managedObject.managedObjectContext {
                    weakSelf?.saveContext(context: managedObjectContext)
                }
            }
        })
    }
    
    func deleteObject(managedObject: NSManagedObject) {
        managedObject.managedObjectContext?.perform({[weak weakSelf = self] in
            if let managedObjectContext = managedObject.managedObjectContext {
                managedObjectContext.delete(managedObject)
                weakSelf?.saveContext(context: managedObjectContext)
            }
        })
    }
    
    func deleteObjects(managedObjects: [NSManagedObject]) {
        for (_, object) in managedObjects.enumerated() {
            deleteObject(managedObject: object)
        }
    }
    
    func deleteAllData(entityName: String) {
        let context = managedObjectContext
        context.perform { [weak weakSelf = self] in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try weakSelf?.persistentStoreCoordinator.execute(deleteRequest, with: context)
            } catch let error as NSError {
                dLogError(message: "Could not delete batch. \(error.localizedDescription)")
            }
        }
    }
    
    func fetchRecordsFor(entityName: String) -> [NSManagedObject] {
        return fetchRecordsFor(entityName: entityName, predicate: nil)
    }
    
    func fetchRecordsFor(entityName: String, sortDescriptors: [NSSortDescriptor]) -> [NSManagedObject] {
        var result:[NSManagedObject] = []
        let context = managedObjectContext
        context.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
                fetchRequest.sortDescriptors = sortDescriptors
            do {
                result = try context.fetch(fetchRequest)
            } catch let error as NSError {
                dLogError(message:"Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
        return result
    }
    
    func fetchRecordsFor(entityName: String, predicate: NSPredicate?) -> [NSManagedObject] {
        var result:[NSManagedObject] = []
        let context = managedObjectContext
        context.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            fetchRequest.predicate = predicate
            do {
                result = try context.fetch(fetchRequest)
            } catch let error as NSError {
                dLogError(message:"Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
        return result
    }
    
    func fetchRecord(entityName: String, predicate:NSPredicate) -> NSManagedObject? {
        var result: NSManagedObject?
        let context = managedObjectContext
        context.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            fetchRequest.predicate = predicate
            do {
                result = try context.fetch(fetchRequest).first
            } catch let error as NSError {
                dLogError(message:"Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
        return result
    }
    
// ==================================================================================================
    
//    func testSaveTag(tagName: String) {
//        let className = String(describing: CampaignTargetsTags.self)
//        let newManagedObjectTag = createManagedObjectForClassName(entityName: className)
//        if let campaignTags = newManagedObjectTag as? CampaignTargetsTags {
//            campaignTags.tagName = tagName
//            saveObject(managedObject: campaignTags)
//        }
//    }
    
    // MARK: Methods that redirects call (remove this when we add functionality to DB)
    
    func updateDeviceWithJSON(jsonDictionary: JSONDictionary) {
        // here we should update DB and like that also the currentDevice object from singletone
        if let receivedDevice: TANDevice = decode(dictionary: jsonDictionary) {
            TANDeviceManager.sharedInstance.updateCurrentDevice(receivedDevice) // THis should not be an singleton if we add core data.
        }
    }
    
// ==================================================================================================

}
