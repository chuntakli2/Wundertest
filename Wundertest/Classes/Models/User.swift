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
    @objc dynamic var id: Int = GKRandomSource.sharedRandom().nextInt()
    @objc dynamic var name: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var password: Data = Data()
    @objc dynamic var creationDate: Date = Date()
    @objc dynamic var lastUpdatedDate: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - Public Methods
    
}
