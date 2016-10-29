//
//  TaskManager.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UserNotifications
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
    
    func getTasks(from realm: Realm) -> Results<Task> {
        let tasks = realm.objects(Task.self).sorted(byProperty: "order", ascending: true)
        return tasks
    }
    
    func getIncompletedTasks(sortBy type: SortType = .order, from realm: Realm) -> Results<Task> {
        let predicate = NSPredicate(format: "isCompleted == false")
        var key = "order"
        switch type {
        case .order:
            key = "order"
        case .createdDate:
            key = "creationDate"
        case .alphabeticalOrder:
            key = "title"
        }
        return self.getTasks(from: realm).filter(predicate).sorted(byProperty: key, ascending: (type != .createdDate))
    }
    
    func getCompletedTasks(from realm: Realm) -> Results<Task> {
        let predicate = NSPredicate(format: "isCompleted == true")
        return self.getTasks(from: realm).filter(predicate)
    }
    
    func getTask(taskId: Int, realm: Realm) -> Task? {
        let predicate = NSPredicate(format: "id = %d", taskId)
        return realm.objects(Task.self).filter(predicate).first
    }
    
    func create(task: Task, realm: Realm) {
        realm.beginWrite()
        realm.add(task, update: true)
        try! realm.commitWrite()
        self.createLocalNotification(with: task)
    }
    
    func update(taskId: Int, title: String, dueDate: Date?, reminder: Date?, realm: Realm) {
        if let task = self.getTask(taskId: taskId, realm: realm) {
            realm.beginWrite()
            task.title = title
            task.dueDate = dueDate
            task.reminder = reminder
            task.lastUpdatedDate = Date()
            try! realm.commitWrite()
            self.createLocalNotification(with: task)
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
            
            if (isCompleted) {
                self.removeLocalNotification(with: task)
            } else {
                self.createLocalNotification(with: task)
            }
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
        self.removeLocalNotification(with: task)
        realm.beginWrite()
        realm.delete(task)
        try! realm.commitWrite()
    }
    
    func exportTasksToCSV(sortBy type: SortType = .alphabeticalOrder, realm: Realm) -> URL {
        var tasksData = "\"Task ID\";\"Task Title\";\"Due Date\";\"State\";\"Creation Date\"\n"
        let taskFormat = "\"%d\";\"%@\";\"%@\";\"%@\";\"%@\"\n"
        for incompletedTask in self.getIncompletedTasks(sortBy: type, from: realm) {
            let id = incompletedTask.id
            let title = incompletedTask.title
            let dueDate = self.generateDateString(from: incompletedTask.dueDate)
            let state = "Incomplete"
            let creationDate = self.generateDateString(from: incompletedTask.creationDate)
            let taskData = String(format: taskFormat, id, title, dueDate, state, creationDate)
            tasksData.append(taskData)
        }
        for completedTask in self.getCompletedTasks(from: realm) {
            let id = completedTask.id
            let title = completedTask.title
            let dueDate = self.generateDateString(from: completedTask.dueDate)
            let state = "Completed"
            let creationDate = self.generateDateString(from: completedTask.creationDate)
            let taskData = String(format: taskFormat, id, title, dueDate, state, creationDate)
            tasksData.append(taskData)
        }
        
        let fileManager = FileManager.default
        let cachesDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let tasksDirectoryURL = cachesDirectoryURL.appendingPathComponent("Tasks")
        try! fileManager.createDirectory(at: tasksDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        let fileName = String(format: "Exported_by_%@_%@.csv", ((type == .createdDate) ? "creation_date" : "alphabetical_order"), self.generateDateString(from: Date()))
        let tasksCSVFileName = fileName
        let tasksCSVFileURL = tasksDirectoryURL.appendingPathComponent(tasksCSVFileName)
        try! tasksData.write(toFile: tasksCSVFileURL.path, atomically: true, encoding: .utf8)
        
        return tasksCSVFileURL
    }
    
    // MARK: Private Methods
    
    private func removeLocalNotification(with task: Task) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(format: "%d", task.id)])
        } else {
            if let scheduledLocalNotifications = UIApplication.shared.scheduledLocalNotifications {
                for scheduledLocalNotification in scheduledLocalNotifications {
                    if (scheduledLocalNotification.category == String(format: "%d", task.id)) {
                        UIApplication.shared.cancelLocalNotification(scheduledLocalNotification)
                        break
                    }
                }
            }
        }
    }
    
    private func createLocalNotification(with task: Task) {
        self.removeLocalNotification(with: task)
        if let reminder = task.reminder {
            guard (reminder.timeIntervalSince1970 >= Date().timeIntervalSince1970) else { return }
            if #available(iOS 10.0, *) {
                let calendar = Calendar.current
                let year = calendar.component(.year, from: reminder)
                let month = calendar.component(.month, from: reminder)
                let day = calendar.component(.day, from: reminder)
                let hour = calendar.component(.hour, from: reminder)
                let minute = calendar.component(.minute, from: reminder)
                
                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString("reminder.title", comment: "")
                content.body = String(format: "Time to finish your task: %@", task.title)
                
                var dateComponents = DateComponents()
                dateComponents.year = year
                dateComponents.month = month
                dateComponents.day = day
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: String(format: "%d", task.id), content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            } else {
                let notification = UILocalNotification()
                notification.alertTitle = NSLocalizedString("reminder.title", comment: "")
                notification.alertBody = String(format: "Time to finish your task: %@", task.title)
                notification.fireDate = reminder
                notification.timeZone = NSTimeZone.system
                notification.repeatInterval = .init(rawValue: 0)
                notification.category = String(format: "%d", task.id)
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        }
    }
    
    private func generateDateString(from date: Date?) -> String {
        if let date = date {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            return String(format: "%d-%d-%d", day, month, year)
        }
        return ""
    }
}
