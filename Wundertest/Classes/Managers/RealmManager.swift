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
    
    fileprivate(set) lazy var realm: Realm = {
        let _realm = try! Realm(configuration: self.realmConfiguration)
        return _realm
    }()

    fileprivate var realmConfiguration: Realm.Configuration = {
        let _configuration = Realm.Configuration(schemaVersion: REALM_SCHEMA_VERSION, migrationBlock: { (migration: Migration, oldSchemaVersion) in
            if (oldSchemaVersion < REALM_SCHEMA_VERSION) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        })
        return _configuration
    }()

}
