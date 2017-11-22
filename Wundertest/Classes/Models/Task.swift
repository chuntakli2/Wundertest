//
//  Task.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import GameplayKit
import RealmSwift

class Task: Object {
    @objc dynamic var id: Int = GKRandomSource.sharedRandom().nextInt()
    @objc dynamic var title: String = ""
    @objc dynamic var dueDate: Date?
    @objc dynamic var reminder: Date?
    @objc dynamic var order: Int = 0
    @objc dynamic var orderTimestamp: Int = Date.getCurrentTimestampInMilliseconds()
    @objc dynamic var isCompleted: Bool = false
    @objc dynamic var creationDate: Date = Date()
    @objc dynamic var lastUpdatedDate: Date = Date()
    
    let userId = RealmOptional<Int>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Public Methods

}
