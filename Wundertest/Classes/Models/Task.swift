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
    dynamic var id: Int = GKRandomSource.sharedRandom().nextInt()
    dynamic var title: String = ""
    dynamic var dueDate: Date = Date()
    dynamic var order: Int = -1
    dynamic var isCompleted: Bool = false
    dynamic var creationDate: Date = Date()
    dynamic var lastUpdatedDate: Date = Date()
    
    let userId = RealmOptional<Int>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Public Methods

}
