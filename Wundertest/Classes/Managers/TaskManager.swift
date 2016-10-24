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
    
    func getTasksFromLocal(realm: Realm) -> Results<Task> {
        let tasks = realm.objects(Task.self)
        return tasks
    }
    
    func createNewTask(task: Task, realm: Realm) {
        
    }
    
}
