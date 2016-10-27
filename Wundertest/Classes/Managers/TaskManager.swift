//
//  TaskManager.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import RealmSwift

class TaskManager: NSObject {
    typealias Callback = (Swift.Error?) -> Void
    
    // MARK: - Singleton Methods
    
    static let sharedInstance: TaskManager = {
        let instance = TaskManager()
        return instance
    }()
    
    // MARK: - Initialisation
    
    override init() {
        // perform some initialization here
    }
    
    // MARK: - Accessors
    
    // MARK: - Public Methods
    
    func getTasksFrom(realm: Realm) -> Results<Task> {
        let tasks = realm.objects(Task.self).sorted(byProperty: "order", ascending: true)
        return tasks
    }
    
    func getIncompletedTasksFrom(realm: Realm) -> Results<Task> {
        let predicate = NSPredicate(format: "isCompleted == false")
        return self.getTasksFrom(realm: realm).filter(predicate)
    }
    
    func getCompletedTasksFrom(realm: Realm) -> Results<Task> {
        let predicate = NSPredicate(format: "isCompleted == true")
        return self.getTasksFrom(realm: realm).filter(predicate)
    }
    
    func getTask(taskId: Int, realm: Realm) -> Task? {
        let predicate = NSPredicate(format: "id = %d", taskId)
        return realm.objects(Task.self).filter(predicate).first
    }
    
    func create(task: Task, realm: Realm) {
        realm.beginWrite()
        realm.add(task, update: true)
        try! realm.commitWrite()
    }
    
    func update(taskId: Int, title: String, dueDate: Date?, realm: Realm) {
        if let task = self.getTask(taskId: taskId, realm: realm) {
            realm.beginWrite()
            task.title = title
            task.dueDate = dueDate
            task.lastUpdatedDate = Date()
            try! realm.commitWrite()
        }
    }
    
    func update(taskId: Int, isCompleted: Bool, order: Int, realm: Realm) {
        if let task = self.getTask(taskId: taskId, realm: realm) {
            realm.beginWrite()
            task.isCompleted = isCompleted
            task.lastUpdatedDate = Date()
            task.order = order
            task.orderTimestamp = Date.getCurrentTimestampInMilliseconds()
            try! realm.commitWrite()
        }
    }
    
    func update(taskId: Int, order: Int, realm: Realm) {
        if let task = self.getTask(taskId: taskId, realm: realm) {
            realm.beginWrite()
            task.order = order
            task.orderTimestamp = Date.getCurrentTimestampInMilliseconds()
            try! realm.commitWrite()
        }
    }
    
    func delete(task: Task, realm: Realm) {
        realm.beginWrite()
        realm.delete(task)
        try! realm.commitWrite()
    }
}
