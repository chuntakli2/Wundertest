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
        if #available(iOS 10.0, *) {
            if let reminder = task.reminder {
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
            }
        } else {
            if let reminder = task.reminder {
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
}
