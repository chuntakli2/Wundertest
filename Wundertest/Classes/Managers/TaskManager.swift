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
    
    func getTask(taskId: Int, realm: Realm) -> Task? {
        let predicate = NSPredicate(format: "id = %d", taskId)
        return realm.objects(Task.self).filter(predicate).first
    }
    
    func create(task: Task, realm: Realm) {
        realm.beginWrite()
        realm.add(task, update: true)
        try! realm.commitWrite()
    }
    
    func update(task: Task, realm: Realm) {
        realm.beginWrite()
        realm.add(task, update: true)
        try! realm.commitWrite()
    }
    
    func delete(task: Task, realm: Realm) {
        realm.beginWrite()
        realm.delete(task)
        try! realm.commitWrite()
    }
}
