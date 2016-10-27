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
    
    func testGetTasks() {
        XCTAssertEqual(self.realm.objects(Task.self).count, 0, "Should be empty in the database")
        TaskManager.sharedInstance.create(task: Task(), realm: self.realm) // Create a task and save into database
        XCTAssertGreaterThan(TaskManager.sharedInstance.getTasksFrom(realm: self.realm).count, 0, "Should return something from database")
    }
    
    func testCreateTask() {
        XCTAssertEqual(self.realm.objects(Task.self).count, 0, "Should be empty in the database")
        TaskManager.sharedInstance.create(task: Task(), realm: self.realm) // Create a task and save into database
        XCTAssertEqual(TaskManager.sharedInstance.getTasksFrom(realm: self.realm).count, 1, "Should return only ONE task from database")
    }
    
    func testGetTask() {
        XCTAssertEqual(self.realm.objects(Task.self).count, 0, "Should be empty in the database")
        TaskManager.sharedInstance.create(task: Task(), realm: self.realm) // Create a task and save into database
        let tasks = TaskManager.sharedInstance.getTasksFrom(realm: self.realm) // Should return a new created task from database
        XCTAssertEqual(TaskManager.sharedInstance.getTasksFrom(realm: self.realm).count, 1, "Should return only ONE task from database")
        let newCreatedTask = tasks.first
        let task = TaskManager.sharedInstance.getTask(taskId: newCreatedTask!.id, realm: self.realm) // Get the task with taskId
        XCTAssertEqual(newCreatedTask, task, "Should be the same task")
    }
    
    func testDeleteTask() {
        XCTAssertEqual(self.realm.objects(Task.self).count, 0, "Should be empty in the database")
        TaskManager.sharedInstance.create(task: Task(), realm: self.realm) // Create a task and save into database
        let tasks = TaskManager.sharedInstance.getTasksFrom(realm: self.realm) // Should return a new created task from database
        XCTAssertEqual(tasks.count, 1, "Should return only ONE task from database")
        TaskManager.sharedInstance.delete(task: (tasks.first)!, realm: self.realm) // Delete the task from database
        XCTAssertEqual(TaskManager.sharedInstance.getTasksFrom(realm: self.realm).count, 0, "Should be empty in the database again")
    }

    func testCompleteTaskAndGetCompletedTasks() {
        XCTAssertEqual(self.realm.objects(Task.self).count, 0, "Should be empty in the database")
        TaskManager.sharedInstance.create(task: Task(), realm: self.realm) // Create a task and save into database
        let tasks = TaskManager.sharedInstance.getTasksFrom(realm: self.realm) // Should return a new created task from database
        XCTAssertEqual(tasks.count, 1, "Should return only ONE task from database")
        let isCompletedState = (tasks.first)!.isCompleted
        XCTAssertEqual(isCompletedState, false, "isCompleted state should be FALSE for new created task")
        TaskManager.sharedInstance.update(taskId: (tasks.first)!.id, isCompleted: !isCompletedState, order: 0, realm: self.realm) // Completed the task
        XCTAssertEqual(TaskManager.sharedInstance.getCompletedTasksFrom(realm: self.realm).count, 1, "Should return ONE completed task from database")
    }
    
    func testGetIncompletedTasks() {
        XCTAssertEqual(self.realm.objects(Task.self).count, 0, "Should be empty in the database")
        TaskManager.sharedInstance.create(task: Task(), realm: self.realm) // Create a task and save into database
        XCTAssertEqual(TaskManager.sharedInstance.getIncompletedTasksFrom(realm: self.realm).count, 1, "Should return ONE incompleted task from database")
    }
    
    func testUpdateTaskContent() {
        XCTAssertEqual(self.realm.objects(Task.self).count, 0, "Should be empty in the database")
        TaskManager.sharedInstance.create(task: Task(), realm: self.realm) // Create a task and save into database
        let tasks = TaskManager.sharedInstance.getTasksFrom(realm: self.realm) // Should return a new created task from database
        XCTAssertEqual(TaskManager.sharedInstance.getTasksFrom(realm: self.realm).count, 1, "Should return only ONE task from database")
        let newCreatedTask = tasks.first
        let newTitle = "Testing Title"
        let newDueDate = Date()
        TaskManager.sharedInstance.update(taskId: newCreatedTask!.id, title: newTitle, dueDate: newDueDate, realm: self.realm)
        let updatedTasks = TaskManager.sharedInstance.getTasksFrom(realm: self.realm) // Should return a new updated task from database
        XCTAssertEqual(TaskManager.sharedInstance.getTasksFrom(realm: self.realm).count, 1, "Should return only ONE task from database")
        let updatedTask = updatedTasks.first
        XCTAssertEqual(updatedTask?.title, newTitle, "Should be same title")
        XCTAssertEqual(updatedTask?.dueDate, newDueDate, "Should be same due date")
    }

    func testUpdateTaskOrder() {
        XCTAssertEqual(self.realm.objects(Task.self).count, 0, "Should be empty in the database")
        TaskManager.sharedInstance.create(task: Task(), realm: self.realm) // Create a task and save into database
        let tasks = TaskManager.sharedInstance.getTasksFrom(realm: self.realm) // Should return a new created task from database
        XCTAssertEqual(TaskManager.sharedInstance.getTasksFrom(realm: self.realm).count, 1, "Should return only ONE task from database")
        let newCreatedTask = tasks.first
        let newOrder = 3
        TaskManager.sharedInstance.update(taskId: newCreatedTask!.id, order: newOrder, realm: self.realm)
        let updatedTasks = TaskManager.sharedInstance.getTasksFrom(realm: self.realm) // Should return a new updated task from database
        XCTAssertEqual(TaskManager.sharedInstance.getTasksFrom(realm: self.realm).count, 1, "Should return only ONE task from database")
        let updatedTask = updatedTasks.first
        XCTAssertEqual(updatedTask?.order, newOrder, "Should be same order")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
