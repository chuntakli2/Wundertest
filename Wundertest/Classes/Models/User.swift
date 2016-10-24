//
//  User.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import GameplayKit
import RealmSwift

class User: Object {
    dynamic var id: Int = GKRandomSource.sharedRandom().nextInt()
    dynamic var name: String = ""
    dynamic var email: String = ""
    dynamic var password: Data = Data()
    dynamic var creationDate: Date = Date()
    dynamic var lastUpdatedDate: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - Public Methods
    
}
