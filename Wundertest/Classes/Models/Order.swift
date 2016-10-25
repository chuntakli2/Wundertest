//
//  Order.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import RealmSwift

class Order: Object {
    dynamic var state: Int = -1
    dynamic var timestamp: Int = Date.getCurrentTimestampInMilliseconds()
}
