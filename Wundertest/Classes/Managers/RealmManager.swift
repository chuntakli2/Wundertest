//
//  RealmManager.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import RealmSwift

class RealmManager: NSObject {
    
    // MARK: - Singleton Methods
    
    static let sharedInstance: RealmManager = {
        let instance = RealmManager()
        return instance
    }()
    
    // MARK: - Initialisation
    
    override init() {
        // perform some initialization here
    }
    
    // MARK: - Accessors
    
    private(set) lazy var realm: Realm = {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        let _realm = try! Realm(configuration: config)
        return _realm
    }()
}
