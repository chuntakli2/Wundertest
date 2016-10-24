//
//  UserManager.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import RealmSwift

class UserManager: NSObject {
    typealias Callback = (Swift.Error?) -> Void
    
    // MARK: - Singleton Methods
    
    static let sharedInstance: UserManager = {
        let instance = UserManager()
        return instance
    }()
    
    // MARK: - Initialisation
    
    override init() {
        // perform some initialization here
    }
    
    // MARK: - Accessors
    
    // MARK: - Public Methods
    
}

