//
//  TaskManagerTests.swift
//  Wundertest
//
//  Created by Eddie Li on 27/10/16.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Wundertest

class TaskManagerTests: XCTestCase {
    
    fileprivate var realm: Realm!

    override func setUp() {
        super.setUp()
        var config = Realm.Configuration.defaultConfiguration
        config.inMemoryIdentifier = self.name
        try! realm = Realm.init(configuration: config)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetTasksFromLocal() {
        XCTAssertEqual(self.realm.objects(Task.self).count, 0, "Should be empty in the database")
        TaskManager.sharedInstance.create(task: Task(), realm: self.realm) // Create a task and save into database
        let tasks = TaskManager.sharedInstance.getTasksFrom(realm: self.realm) // Should return a task from sdatabase
        XCTAssertGreaterThan(tasks.count, 0, "GetTasksFromLocal should return a task from database")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
